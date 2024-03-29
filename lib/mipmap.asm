; Virtual-3D library, version 1.0
;
; MIT License
; 
; Copyright (c) 2017 - 2021 TheMachine02
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; mipmapping :

vxVariableShading:
; this work as a POC, the actual speed gain is NOT here due to the nop, we need to adjust jump table
.rate:
	ld	a, (VX_SHADER_STATE)
	cp	a, ( VX_PIXEL_SHADER_CACHE shr 8 ) and 255
	ret	nz
	ld	hl, (iy+VX_FDVDX)
; push zero into the upper dx
	res	7, h
	add	hl, hl
	ld	a, (iy+VX_FDUDX+1)
	adc	a, a
	ld	c, a
	xor	a, h
	jr	z, .vrs_common
	inc	a
	jr	z, .vrs_common
; reset previous shader to normal
.vrs_write_zero:
	ld	hl, VX_PIXEL_SHADER_CODE
	ld	de, VX_PIXEL_SHADER_CODE+10
	ld	bc, 10
	ldir
	ld	hl, .djnz_single
	ld	c, 2
	ldir
	ret
.vrs_common:
	ld	(iy+VX_FDVDX), hl
	ld	(iy+VX_FDUDX+1), c
	ld	hl, VX_PIXEL_SHADER_CODE+7
	ld	de, VX_PIXEL_SHADER_CODE+10
	ld	a, $D9
	ld	(de), a
	inc	de
	ld	bc, 3
	ldir
	ld	hl, .djnz_dual
	ld	c, 2
	ldir
; then put some zero nop here
	ld	hl, VIRTUAL_NULL_RAM
	ld	c, 6
	ldir
	ret

.dummy:
	rb	20
.djnz_single:
	djnz	.dummy
	
.dummy_2:
	rb	14
.djnz_dual:
	djnz	.dummy_2
	
vxMipmap:

.gradient:
; FIXME : we dont truly have the correct gradient on Y, since it is gradient along longest edge
; float mipmap_level(in vec2 texture_coordinate)
; {
;     // The OpenGL Graphics System: A Specification 4.2
;     //  - chapter 3.9.11, equation 3.21
;     vec2  dx_vtc        = dFdx(texture_coordinate);
;     vec2  dy_vtc        = dFdy(texture_coordinate);
;     float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
;     return 0.5 * log2(delta_max_sqr);
; }
; we'll do this, only take 8 bits of the derivative
; mipmap level :
; 256x256 : lvl 0, 256K
; 128x128 : lvl 1, 16K
; 64x64   : lvl 2, 4K
; 32x32   : lvl 3, 1K
; 16x16   : lvl 4, 256
	ld	a, (iy+VX_FDUDX+1)
	bit	7, a
	jr	z, $+3
	cpl
	ld	b, a
	ld	c, a
	mlt	bc
	ld	a, (iy+VX_FDVDX+1)
	bit	7, a
	jr	z, $+3
	cpl
	ld	h, a
	ld	l, a
	mlt	hl
	add	hl, bc
	ex	de, hl
	ld	a, (iy+VX_FDUDY+1)
	bit	7, a
	jr	z, $+3
	cpl
	ld	b, a
	ld	c, a
	mlt	bc
	ld	a, (iy+VX_FDVDY+1)
	bit	7, a
	jr	z, $+3
	cpl
	ld	h, a
	ld	l, a
	mlt	hl
	add	hl, bc
; hl = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
; 	sbc	hl, de
; 	add	hl, de
; 	jr	nc, $+3
; 	ex	de, hl
; 	ld	a, h
; 	or	a, a
; 	ld	a, l
; 	jr	z, $+4
; 	scf
; 	sbc	a, a
; hl = mix(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
	add	hl, de
	srl	h
	ld	a, l
	jr	z, $+4
	scf
	sbc	a, a
	rra
	ld	hl, VX_LOG_LUT
	adc	a, l
	ld	l, a
	ld	a, (hl)
	or	a, a
	jr	nz, .mipmap_level_lod
.mipmap_level_zero:
	ld	a, $D3
	ld	(vxPrimitiveTextureRaster.SMC0), a
	ret
.mipmap_level_lod:
	ld	b, a
; a is the mipmap level
; get u&v offseting table
; we'll after it need to offset the delta's
	ld	hl, VX_MIPMAP_LUT
	dec	a
	add	a, a
	add	a, h
	ld	h, a
	ld	l, (iy+VX_REGISTER_U0)
	ld	e, (hl)
	inc	h
	ld	l, (iy+VX_REGISTER_V0)
	ld	d, (hl)
; NOTE : this overwrite Y1, but it is uneeded at this point
	ld	(iy+VX_REGISTER_U0), de
; set the smc for texture map
	ld	a, $D2
	ld	(vxPrimitiveTextureRaster.SMC0), a
; scale the delta's
	ld	a, b
	ld	de, (iy+VX_FDUDX)
	ld	hl, (iy+VX_FDVDX)
.mipmap_level_scale_dx:
	sra	h
	rr	l
	sra	d
	rr	e
	djnz	.mipmap_level_scale_dx
	ld	(iy+VX_FDVDX), hl
	ld	(iy+VX_FDUDX), de
	ld	de, (iy+VX_FDUDY)
	ld	hl, (iy+VX_FDVDY)
	ld	b, a
.mipmap_level_scale_dy:
	sra	h
	rr	l
	sra	d
	rr	e
	djnz	.mipmap_level_scale_dy
	ld	(iy+VX_FDVDY), hl
	ld	(iy+VX_FDUDY), de
	ret

; up to -2 negative bias
 db 0
 db 0
align 256
VX_LOG_LUT:
 db 0
 db 0
 db 1
 db 1
 db 1
 db 1
 db 1
 db 1
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 2
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4

 
 rb	64
 TMP:
 rb	64
 

; 	ld	bc, (iy+VX_FDUDX)
; 	bit	7, b
; 	jr	z, .gradient_abs_dudx
; 	xor	a, a
; 	sub	a, c
; 	ld	c, a
; 	sbc	a, a
; 	sub	a, b
; 	ld	b, a
; .gradient_abs_dudx:
; 	ld	a, c
;  	ld	h, b
;  	ld	l, b
;  	mlt	hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	mlt	bc
;  	add	hl, bc
;  	add	hl, bc
;  	ld	b, a
;  	ld	c, a
;  	mlt	bc
;  	ld	c, b
;  	ld	b, 0
;  	add	hl, bc
;  	ex	de, hl
;  	ld	bc, (iy+VX_FDVDX)
;  	bit	7, b
;  	jr	z, .gradient_abs_dvdx
;  	xor	a, a
;  	sub	a, c
;  	ld	c, a
;  	sbc	a, a
;  	sub	a, b
;  	ld	b, a
;  .gradient_abs_dvdx:
;  	ld	a, c
;  	ld	h, b
;  	ld	l, b
;  	mlt	hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	mlt	bc
;  	add	hl, bc
;  	add	hl, bc
;  	ld	b, a
;  	ld	c, a
;  	mlt	bc
;  	ld	c, b
;  	ld	b, 0
;  	add	hl, bc
;  	add	hl, de
;  	push	hl
;  	
;  	ld	bc, (iy+VX_FDUDY)
;  	bit	7, b
;  	jr	z, .gradient_abs_dudy
;  	xor	a, a
;  	sub	a, c
;  	ld	c, a
;  	sbc	a, a
;  	sub	a, b
;  	ld	b, a
;  .gradient_abs_dudy:
;  	ld	a, c
;  	ld	h, b
;  	ld	l, b
;  	mlt	hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	mlt	bc
;  	add	hl, bc
;  	add	hl, bc
;  	ld	b, a
;  	ld	c, a
;  	mlt	bc
;  	ld	c, b
;  	ld	b, 0
;  	add	hl, bc
;  	ex	de, hl
;  	ld	bc, (iy+VX_FDVDY)
;  	bit	7, b
;  	jr	z, .gradient_abs_dvdy
;  	xor	a, a
;  	sub	a, c
;  	ld	c, a
;  	sbc	a, a
;  	sub	a, b
;  	ld	b, a
;  .gradient_abs_dvdy:
;  	ld	a, c
;  	ld	h, b
;  	ld	l, b
;  	mlt	hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	add	hl, hl
;  	mlt	bc
;  	add	hl, bc
;  	add	hl, bc
;  	ld	b, a
;  	ld	c, a
;  	mlt	bc
;  	ld	c, b
;  	ld	b, 0
;  	add	hl, bc
;  	add	hl, de
;  	pop	de

; 	ld	hl, (iy+VX_FDUDY)
; 	bit	7, (iy+VX_FDVDY+1)
; 	jr	z, $+4
; 	dec.s	hl
; 	ld	(iy+VX_FDUDY), hl
; 	ld	hl, (iy+VX_FDUDX)
; 	bit	7, (iy+VX_FDVDX+1)
; 	jr	z, $+4
; 	dec.s	hl
; 	ld	(iy+VX_FDUDX), hl
