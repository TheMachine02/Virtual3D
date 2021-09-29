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
define	VX_PIXEL_SHADER_JP			0
define	VX_PIXEL_SHADER_VEC0			3
define	VX_PIXEL_SHADER_VEC1			6
define	VX_PIXEL_SHADER_OFFSET			9
define	VX_PIXEL_SHADER_LUT_OFFSET		12
define	VX_PIXEL_SHADER_ASSEMBLY_SIZE		15
; compiled code
define	VX_PIXEL_SHADER_ASSEMBLY		20
; lenght LUT
define	VX_PIXEL_SHADER_LUT			84
define	VX_PIXEL_SHADER_LENGHT			1364 ; 20+64+1280

align 4
vxPixelShaderExitLUT:
 db	0
 dl	vxPixelShaderExit
vxShaderCompileEntry:
 dl	0
 
vxShader:
; include standard shader
include	"shader/texture.asm"
include	"shader/gouraud.asm"
include	"shader/lightning.asm"
include	"shader/alpha.asm"

.init:
	ld	hl, VX_PIXEL_SHADER_CACHE
	ld	(vxShaderCompileEntry), hl
	ld	a, -1
	ld	(VX_SHADER_STATE), a
	ld	ix, .default
; fallback
	
.compile:
; ix is the shader to compile
; return hl = compiled shader
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
	ld	hl, .fragment_copy
	ld	c, 3
	ldir
; we should jump after the lea (fragment_setup)
	ld	(iy+VX_PIXEL_SHADER_JP), de
	push	de
	ld	c, 25
	ldir
	ld	hl, -15
	add	hl, de
	ld	(iy+VX_PIXEL_SHADER_OFFSET), hl
; we need to compute the copy size
	ld	hl, 15 - VX_VRAM_CACHE
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
	ld	l, c
	ld	(iy+0), b
	ld	(iy+1), hl
	ld	l, a
	ld	(iy+4), b
	ld	(iy+5), hl
	lea	iy, iy+8
	djnz	.write_lut_negative
; handle null lenght
	pop	de
; we want the lea
	dec	de
	dec 	de
	dec	de
	ld	(iy+0), b
	ld	(iy+1), de
; iy divised by four is important here
	push	iy	
	lea	iy, iy+4
; now the other part of the lut
	ld	e, 0
	ld	b, 160
.write_lut_positive:
	inc	e
	ld	l, a
	ld	(iy+0), e
	ld	(iy+1), hl
	ld	l, c
	ld	(iy+4), e
	ld	(iy+5), hl
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

.fragment_copy:
 	lea	iy, iy+VX_REGISTER_SIZE
.fragment_setup:
	exx
	ld	hl, (iy+VX_REGISTER1)	; lut adress
	ld	de, (iy+VX_REGISTER0)	; screen adress
	add	hl, de
	add	hl, hl
	add	hl, hl
	nop
	ld	a, (hl)			; fetch correct size
	inc	hl
	ld	ix, (hl)		; fetch jump \o/
	ld	hl, (iy+VX_REGISTER3)
	exx
	ld	hl, (iy+VX_REGISTER2)	; v
	ld	b, a
	jp	(ix)
 
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
	lea	hl, ix+VX_PIXEL_SHADER_ASSEMBLY
	ld	de, VX_VRAM_CACHE
	ld	bc, (ix+VX_PIXEL_SHADER_ASSEMBLY_SIZE)
	ldir
	pop	de
	pop	bc
	ret
