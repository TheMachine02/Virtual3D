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

vxMipmap:
; this work as a POC, the actual speed gain is NOT here due to the nop, we need to adjust jump table
.vrs:
	ld	bc, (iy+VX_FDUDX)
	bit	7, b
	jr	z, .vrs_abs_du
	xor	a, a
	sub	a, c
	ld	c, a
	sbc	a, a
	sub	a, b
	ld	b, a
.vrs_abs_du:
	ld	hl, (iy+VX_FDVDX)
	bit	7, h
	jr	z, .vrs_abs_dv
	xor	a, a
	sub	a, l
	ld	l, a
	sbc	a, a
	sub	a, h
	ld	h, a
.vrs_abs_dv:
	ld	a, h
	or	a, b
	jr	nz, .vrs_write_zero
	ld	a, l
	or	a, c
	cp	a, $81
	jr	nc, .vrs_write_zero
; 	cp	a, $41
; 	jr	nc, .vrs_write_half
; 	ld	a, 11111111b
; 	jr	.vrs_common
.vrs_write_half:
	ld	a, 10110101b
.vrs_common:
	ld	(vxShaderUniform0+1), a
	ld	hl, (iy+VX_FDVDX)
	add	hl, hl
	ld	(iy+VX_FDVDX), l
	ld	(iy+VX_FDVDX+1), h
	ld	hl, (iy+VX_FDUDX)
	add	hl, hl
	ld	(iy+VX_FDUDX), l
	ld	(iy+VX_FDUDX+1), h
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
	jr	.vrs_adjust
.vrs_write_zero:
	ld	hl, VX_PIXEL_SHADER_CODE
	ld	de, VX_PIXEL_SHADER_CODE+10
	ld	bc, 10
	ldir
	ld	hl, .djnz_single
	ld	c, 2
	ldir	
.vrs_adjust:
	bit	7, (iy+VX_FDVDX+1)
	ret	z
	ld	hl, (iy+VX_FDUDX)
	dec.s	hl
	ld	(iy+VX_FDUDX), hl
	ret

.dummy:
	rb	20
.djnz_single:
	djnz	.dummy
	
.dummy_2:
	rb	14
.djnz_dual:
	djnz	.dummy_2
	
.generate:
; generate LUT table for mipmapping ?
; 256x256 : lvl 0
; 128x128 : lvl 1, 16K
; 64x64   : lvl 2, 4K
; 32x32   : lvl 3, 1K
; 16x16   : lvl 4, 256
; each texel is the average of the four texel of the precedent level
; we also need to offset the v coordinate by the necessary value
; LUT table does : U >> lvl + U offset and V >> lvl + V offset
	ret

.gradient:
; apply LUT table
; scale delta's (y & x)

; float
; mip_map_level(in vec2 texture_coordinate)
; {
;     // The OpenGL Graphics System: A Specification 4.2
;     //  - chapter 3.9.11, equation 3.21
;  
;     vec2  dx_vtc        = dFdx(texture_coordinate);
;     vec2  dy_vtc        = dFdy(texture_coordinate);
;     float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
;  
;     //return max(0.0, 0.5 * log2(delta_max_sqr) - 1.0);
;     return 0.5 * log2(delta_max_sqr);
; }
; we'll do this, only take 8 bits of the derivative
; 0,5*log2(max( (dFdxU*dFdxU) + (dFdxV*dFdxV) , (dFdyU*dFdyU)+(dFdyV*dFdyV)))	
	ld	bc, (iy+VX_FDUDX)
	bit	7, b
	jr	z, .gradient_abs_dudx
	xor	a, a
	sub	a, c
	ld	c, a
	sbc	a, a
	sub	a, b
	ld	b, a
.gradient_abs_dudx:
	ld	a, c
	ld	h, b
	ld	l, b
	mlt	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, bc
	ld	b, a
	ld	c, a
	mlt	bc
	ld	c, b
	ld	b, 0
	add	hl, bc
	ex	de, hl
	ld	bc, (iy+VX_FDVDX)
	bit	7, b
	jr	z, .gradient_abs_dvdx
	xor	a, a
	sub	a, c
	ld	c, a
	sbc	a, a
	sub	a, b
	ld	b, a
.gradient_abs_dvdx:
	ld	a, c
	ld	h, b
	ld	l, b
	mlt	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, bc
	ld	b, a
	ld	c, a
	mlt	bc
	ld	c, b
	ld	b, 0
	add	hl, bc
	add	hl, de
	push	hl
	
	ld	bc, (iy+VX_FDUDY)
	bit	7, b
	jr	z, .gradient_abs_dudy
	xor	a, a
	sub	a, c
	ld	c, a
	sbc	a, a
	sub	a, b
	ld	b, a
.gradient_abs_dudy:
	ld	a, c
	ld	h, b
	ld	l, b
	mlt	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, bc
	ld	b, a
	ld	c, a
	mlt	bc
	ld	c, b
	ld	b, 0
	add	hl, bc
	ex	de, hl
	ld	bc, (iy+VX_FDVDY)
	bit	7, b
	jr	z, .gradient_abs_dvdy
	xor	a, a
	sub	a, c
	ld	c, a
	sbc	a, a
	sub	a, b
	ld	b, a
.gradient_abs_dvdy:
	ld	a, c
	ld	h, b
	ld	l, b
	mlt	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, bc
	ld	b, a
	ld	c, a
	mlt	bc
	ld	c, b
	ld	b, 0
	add	hl, bc
	add	hl, de
	pop	de
	or	a, a
	sbc	hl, de
	add	hl, de
	jr	c, $+3
	ex	de, hl
; hl is max(dot,dot)
	ld	a, h
	ld	hl, VX_LOG_LUT
	ld	l, a
	ld	a, (hl)
	srl	a
	ld	b, a
	jr	z, .mipmap_skip_lut
; a is the mipmap level
; get u&v offseting table
; we'll after it need to offset the delta's
	ld	hl, VX_MIPMAP_LUT
	dec	a
	add	a, a
	add	a, h
	ld	h, a
	ld	l, (iy+VX_REGISTER_U0)
	ld	a, (hl)
	ld	(iy+VX_REGISTER_U0), a
	inc	h
	ld	l, (iy+VX_REGISTER_V0)
	ld	a, (hl)
	ld	(iy+VX_REGISTER_V0), a
.mipmap_skip_lut:
	ld	a, b
	or	a, a
	ld	a, $D3
	jr	z, $+4
	ld	a, $D2
	ld	(vxPrimitiveTextureRaster.SMC0), a
	ld	(vxPrimitiveTextureRaster.SMC1), a
	ld	a, b
	ld	de, (iy+VX_FDUDX)
	ld	hl, (iy+VX_FDVDX)
	or	a, a
	jr	z, .mipmap_scale_0_skip
.mipmap_scale_0:
	sra	h
	rr	l
	sra	d
	rr	e
	djnz	.mipmap_scale_0
.mipmap_scale_0_skip:
	ld	(iy+VX_FDVDX), hl
	bit	7, h
	jr	z, $+4
	dec.s	de	
	ld	(iy+VX_FDUDX), de
	
	ld	de, (iy+VX_FDUDY)
	ld	hl, (iy+VX_FDVDY)
	or	a, a
	jr	z, .mipmap_scale_1_skip
	ld	b, a
.mipmap_scale_1:
	sra	h
	rr	l
	sra	d
	rr	e
	djnz	.mipmap_scale_1
.mipmap_scale_1_skip:
	ld	(iy+VX_FDVDY), hl
	bit	7, h
	jr	z, $+4
	dec.s	de	
	ld	(iy+VX_FDUDY), de
	ret
	
vxMipmapLevel:
; about 400 cycles more
; get mipmap level from delta's
; log2(min(max(abs(dFdxU),abs(dFdyU)),max(abs(dFdxV),abs(dFdyV)))
	ld	de, (iy+VX_FDUDX)
	bit	7, d
	jr	z, .abs_s0
	xor	a, a
	sub	a, e
	ld	e, a
	sbc	a, a
	sub	a, d
	ld	d, a
.abs_s0:
	ld	hl, (iy+VX_FDUDY)
	bit	7, h
	jr	z, .abs_s1
	xor	a, a
	sub	a, l
	ld	l, a
	sbc	a, a
	sub	a, h
	ld	h, a
.abs_s1:
	ex.s	de, hl
; both abs() are de and hl, compare them
	or	a, a
	sbc	hl, de
	add	hl, de
; if hl > de : p, else m
	jp	p, .cc0
	ex	de, hl
.cc0:
; hl is the lowest of both
; save it for later
	push	hl
	ld	de, (iy+VX_FDVDY)
	bit	7, d
	jr	z, .abs_s2
	xor	a, a
	sub	a, e
	ld	e, a
	sbc	a, a
	sub	a, d
	ld	d, a
.abs_s2:
	ld	hl, (iy+VX_FDVDX)
	bit	7, h
	jr	z, .abs_s3
	xor	a, a
	sub	a, l
	ld	l, a
	sbc	a, a
	sub	a, h
	ld	h, a
.abs_s3:
	ex.s	de, hl
; both abs() are de and hl, compare them
	or	a, a
	sbc	hl, de
	add	hl, de
; if hl > de : nc, else c
	jp	p, .cc1
	ex	de, hl
.cc1:
	pop	de
; compare now de and hl
; keep the lowest
	or	a, a
	sbc	hl, de
	add	hl, de
	jp	p, .cc2
	ex	de, hl
.cc2:
; hl is the lowest
; take log2 of hl (8.8)
	ld	a, h
	ld	hl, VX_LOG_LUT
	ld	l, a
; we got the mipmap level
	ld	a, (hl)
	add	a, 2
; based on mipmap level : we need to scale the delta's to be closer to 1 and scale the starting u & v > LUT table
	ld	(vxShaderUniform0+1), a
.adjust:
	bit	7, (iy+VX_FDVDY+1)
	jr	z, .adj0
	ld	hl, (iy+VX_FDUDY)
	dec.s	hl
	ld	(iy+VX_FDUDY), hl
.adj0:
	bit	7, (iy+VX_FDVDX+1)
	ret	z
	ld	hl, (iy+VX_FDUDX)
	dec.s	hl
	ld	(iy+VX_FDUDX), hl
	ret


align 256
VX_LOG_LUT:
 db 0
 db 0
 db 1
 db 1
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
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 
 rb	64
 TMP:
 rb	64
 
