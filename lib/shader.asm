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

define	VX_PIXEL_SHADER_CACHE_MAX		4	; (default is 0, allowed 3 more)
define	VX_PIXEL_SHADER_CACHE_SIZE		3072	; 2648

; control block
virtual at 0
	VX_PIXEL_SHADER_JP:		rb	3	; jump inside the shader code
	VX_PIXEL_SHADER_VEC0:		rb	3	; first SMC
	VX_PIXEL_SHADER_VEC1:		rb	3	; second SMC
	VX_PIXEL_SHADER_OFFSET:		rb	3	; offset SMC
	VX_PIXEL_SHADER_LUT_OFFSET:	rb	3	; LUT start
	VX_PIXEL_SHADER_DUDY:		rb	3	; DUDY SMC offset
	VX_PIXEL_SHADER_DVDY:		rb	3	; DVDY SMC offset
	VX_PIXEL_SHADER_ASSEMBLY_SIZE:	rb	3	; size of total pixel shader
	VX_PIXEL_SHADER_ASSEMBLY:	rb	64
	align	4
	VX_PIXEL_SHADER_LUT:		rb	1280	; LUT table
	VX_PIXEL_SHADER_LENGHT:		rb	1280	; middle of LUT
end virtual

align 4
vxPixelShaderExitLUT:
;  db	0
 dl	vxPixelShaderExit
 db	0
vxShaderCompileEntry:
 dl	0
 
vxShader:
; include standard shader

.init:
	ld	hl, VX_PIXEL_SHADER_CACHE
	ld	(vxShaderCompileEntry), hl
	ld	a, -1
	ld	(VX_SHADER_STATE), a
	ld	ix, vxPixelShader.default
; fallback
	
.compile:
; ix is the shader to compile/allocate
; return hl = compiled shader
; please note uniform should be matched to this shader
	ld	iy, (vxShaderCompileEntry)
; check VX_PIXEL_SHADER_CACHE_MAX
	ld	de,  VX_PIXEL_SHADER_CACHE + VX_PIXEL_SHADER_CACHE_MAX*VX_PIXEL_SHADER_CACHE_SIZE
	lea	hl, iy+0
	or	a, a
	sbc	hl, de
	jp	z, .error
	ld	bc, (ix+VX_SHADER_SIZE)		; load size
	lea	hl, ix+VX_SHADER_CODE		; load shader
	ld	de, VX_VRAM_CACHE		; set VRAM cache first so we can have actual offset
	ldir					; copy the assembly included
	ld	hl, .fragment
	ld	c, .fragment_setup - .fragment
	ldir
; we should jump after the lea (fragment_setup)
	push	hl
	push	de
	ld	hl, .fragment_jump - .fragment_setup
	add	hl, de
	ld	(iy+VX_PIXEL_SHADER_JP), hl
	pop	de
	pop	hl
	push	de
	ld	c, .fragment_end - .fragment_setup
	ldir
	ld	hl, -.fragment_end+.VROF
	add	hl, de
	ld	(iy+VX_PIXEL_SHADER_OFFSET), hl
	
	ld	hl, -.fragment_end+.DUDY
	add	hl, de
	ld	(iy+VX_PIXEL_SHADER_DUDY), hl
	
	ld	hl, -.fragment_end+.DVDY
	add	hl, de
	ld	(iy+VX_PIXEL_SHADER_DVDY), hl
	
; we need to compute the copy size
	ld	hl, -VX_VRAM_CACHE+.fragment_end -.VROF
	add	hl, de
	ld	(iy+VX_PIXEL_SHADER_ASSEMBLY_SIZE), hl
; bc is zero here
	ld	c, (ix+VX_SHADER_DATA1)
	ld	hl, VX_VRAM_CACHE - 2
	add	hl, bc
	ld	(iy+VX_PIXEL_SHADER_VEC0), hl
	add	hl, bc
	ld	(iy+VX_PIXEL_SHADER_VEC1), hl
; now, compute the LUT table
	lea	iy, iy+VX_PIXEL_SHADER_LUT
	ld	hl, VX_VRAM_CACHE
	ld	a, l
	add	a, c
; c is two pixel, a is one pixel
	ld	c, l
	ld	b, 160
.write_lut_negative:
	ld	h, b
	ld	l, c
;	ld	(iy+0), b
	ld	(iy+0), hl	; + 1 
	ld	l, a
;	ld	(iy+4), b
	ld	(iy+4), hl	; + 1
	lea	iy, iy+8
	djnz	.write_lut_negative
; handle null lenght
	pop	de
; we want the lea
	dec	de
	dec 	de
	dec	de
;	ld	(iy+0), b
	ld	d, b
	ld	(iy+0), de
; iy divised by four is important here
	push	iy	
	lea	iy, iy+4
; now the other part of the lut
	ld	e, 0
	ld	b, 160
.write_lut_positive:
	inc	e
	ld	l, a
	ld	h, e
;	ld	(iy+0), e
	ld	(iy+0), hl
	ld	l, c
;	ld	(iy+4), e
	ld	(iy+4), hl
	lea	iy, iy+8
	djnz	.write_lut_positive
; copy and quit
	pop	hl
	ld	iy, (vxShaderCompileEntry)
	ld	(iy+VX_PIXEL_SHADER_LUT_OFFSET), hl
	ld	a, (iy+VX_PIXEL_SHADER_LUT_OFFSET+2)
; divide by 4
	srl	a
	rr	h
	rr	l
	srl	a
	rr	h
	rr	l
; alignement issue ?
	jr	c, .error
	ld	(iy+VX_PIXEL_SHADER_LUT_OFFSET), hl
	ld	(iy+VX_PIXEL_SHADER_LUT_OFFSET+2), a
	push	iy
	ld	hl, VX_VRAM_CACHE
	lea	de, iy+VX_PIXEL_SHADER_ASSEMBLY
	ld	c, 64
	ldir
	ld	bc, VX_PIXEL_SHADER_CACHE_SIZE
	add	iy, bc
	ld	(vxShaderCompileEntry), iy
	pop	hl
	ret
.error:
	scf
	sbc	hl, hl
	ret

.fragment:
; per-span fragment setup
; exactly 28 bytes, 93 cycles (counting out bound jp $ and fetch within normal RAM)
; register format :
; iy+0, jp $000000 (also end marker)
; iy+2, length/2 for djnz
; iy+4, screen VRAM adress
; iy+7 and iy+10, u&v value
; total : 13 bytes
	lea	iy, iy+VX_GPR_REGISTER_SIZE
.fragment_setup:
	exa
; fixed v = v + dv, with u on upper byte
; we only need to reload b (bc is loaded with DVDY, an sampler only use b)
.DVDY:=$+1
	ld	b, $00
	add	ix, bc
	lea	hl, ix+0
	exx
; a is the u integer part, copy it to hl'
.DUDY:=$+1
	adc	a, $00
.fragment_jump:
; NOTE : we need to reset the v integer part to zero, else if previous v was < 255
; we might overflow into $dx and completely destroy our poor texture sampler
; reset both the upper byte which is the texture with mbase and h with zero
	ld	hl, i
	ld	l, a
	exa
	ld	de, (iy+VX_GPR_REGISTER_VRAM)
; offseting to account interpolating from left or right (later inside setup code)
.VROF:=$
	nop
	exx
; iy point to an in LUT jp to the correct area
	ld	b, (iy+VX_GPR_REGISTER_LENGTH+1)
	jp	(iy)
.fragment_end:=$
	
; ; per-span fragment setup
; ; exactly 28 bytes, 95? cycles (counting out bound jp $ and fetch within normal RAM)
; ; advance in register file
; ; register format :
; ; iy+0, jp $000000 (also end marker)
; ; iy+4, length/2 for djnz
; ; iy+5, screen VRAM adress
; ; total : 8 bytes
; 	lea	iy, iy+VX_GPR_REGISTER_SIZE
; 	exa
; ; fixed v = v + dv, with u on upper byte
; ; .DVDY:=$+1
; ; 	ld	bc, $CC
; ; we only need to reload b (bc load DVDY)
; .DVDY_H:=$+1
; 	ld	b, $CC
; 	add	ix, bc
; 	lea	hl, ix+0
; 	exx
; ; a is the u integer part, copy it to hl'
; .DUDY:=$+1
; 	adc	a, $CC
; ; NOTE : we need to reset the v integer part to zero, else if previous v was < 255
; ; we might overflow into $dx and completely destroy our poor texture sampler
; ; reset both the upper byte which is the texture with mbase and h with zero
; 	ld	hl, i
; 	ld	l, a
; 	exa
; .fragment_setup:
; ; screen adress
; 	ld	de, (iy+VX_GPR_REGISTER_VRAM)
; ; offseting to account interpolating from left or right (later inside setup code)
; 	exx
; ; iy point to an in LUT jp to the correct area
; 	ld	b, (iy+VX_GPR_REGISTER_LENGTH)
; 	jp	(iy)

  
.load:
; ix is full compiled shader adress (fetched from material)
; save de, bc
	push	bc
	push	de
	ld	a, ixh
	ld	(VX_SHADER_STATE), a
 	ld	hl, (ix+VX_PIXEL_SHADER_JP)
	ld	(vxShaderJumpWrite), hl
	ld	hl, (ix+VX_PIXEL_SHADER_VEC0)
	ld	(vxShaderAdress0Write), hl
	ld	hl, (ix+VX_PIXEL_SHADER_VEC1)
	ld	(vxShaderAdress1Write), hl
	ld	hl, (ix+VX_PIXEL_SHADER_OFFSET)
	ld	(vxShaderAdress2Write), hl
	ld	hl, (ix+VX_PIXEL_SHADER_LUT_OFFSET)
	ld	(vxShaderAdress3Write), hl
	inc	hl
	inc	hl
	ld	(vxShaderAdress4Write), hl
	ld	hl, (ix+VX_PIXEL_SHADER_DUDY)
	ld	(vxShaderAdress5Write), hl
	ld	hl, (ix+VX_PIXEL_SHADER_DVDY)
	ld	(vxShaderAdress6Write), hl
	lea	hl, ix+VX_PIXEL_SHADER_ASSEMBLY
	ld	de, VX_VRAM_CACHE
	ld	bc, (ix+VX_PIXEL_SHADER_ASSEMBLY_SIZE)
	ldir
	pop	de
	pop	bc
	ret
