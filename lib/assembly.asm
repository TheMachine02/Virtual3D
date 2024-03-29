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

define	VX_DEPTH_TEST		$01
define	VX_DEPTH_BITS		24
define	VX_DEPTH_MIN		0
define	VX_DEPTH_MAX		16777216
define	VX_DEPTH_OFFSET		8388608
define	VX_VIEW_MLT_OFFSET	128

; NOTE : the 1536 bytes need to be aligned and we need inc h to be valid for all the table
align	2048
VX_DEPTH_BUCKET_L:
	rb	512
VX_DEPTH_BUCKET_H:
	rb	512
VX_DEPTH_BUCKET_U:
	rb	512

VX_PRIMITIVE_ASM_COPY:
; relocate the shader to fast VRAM ($E30800)
relocate VX_PRIMITIVE_ASM_CODE

vxPrimitiveAssembly:
; 3884 cc setup
;  623 cc bfc accept
;  458 cc bfc reject
;  212 cc clip reject
.setup:
; input : iy = stream, also expect so global variable to be correctly set
	lea	iy, iy+VX_STREAM_HEADER_SIZE
; lut setup
.mlt_generate:
; now the view vector
; we'll need to generate actual LUT table for bc * a (signed)
; bc is know is advance, but we have 3 table for -64 to 64
	ld	de, (vxView_t)
	ld	hl, VX_VIEW_MLTX + VX_VIEW_MLT_OFFSET - 1
	call	.view_mlt
	ld	de, (vxView_t+3)
	ld	hl, VX_VIEW_MLTY + VX_VIEW_MLT_OFFSET - 1
	call	.view_mlt
	ld	de, (vxView_t+6)
	ld	hl, VX_VIEW_MLTZ + VX_VIEW_MLT_OFFSET - 1
	call	.view_mlt
; preload the first value, it is used as stream end mark
	ld	de, (iy+VX_TRIANGLE_I0)
	dec	e
	ret	z
	ld	hl, VX_VIEW_MLTX
	ld	i, hl
; setup the various SMC
; geometry format STR
; geometry material MTR
; also set the geometry depth offset here
	ld	hl, (vxPrimitiveDepth)
	ld	(.DEO), hl
	ld	hl, (vxPrimitiveMaterial)
	ld	ix, (vxPrimitiveQueue)
	ld	a, (hl)
	and	a, VX_FORMAT_STRIDE
	ld	(.STR), a
	ld	a, l
	ld	(.MTR), a
	ld	(.MTRU), a
	inc	hl
; this is the VBO
	ld	(.SP_RET0), sp
	ld	hl, (hl)
	ld	sp, hl
	ld	bc, VX_VERTEX_RZ
	ex	de, hl
.pack:
	inc	l
	add	hl, sp
	ld	a, (hl)
	add	hl, bc
	ld	de, (hl)
	ld	hl, (iy+VX_TRIANGLE_I1)
	add	hl, sp
	and	a, (hl)
	add	hl, bc
	ld	hl, (hl)
	add	hl, de
	ex	de, hl
	ld	hl, (iy+VX_TRIANGLE_I2)
	add	hl, sp
	and	a, (hl)
	jr	nz, .discard
.backface_cull:
	exx
; switch to shadow for the bfc
	ld	hl, i
; between -31 and 31 pre multiplied by 4
	ld	l, (iy+VX_TRIANGLE_N0)
	ld	de, (hl)
; fetch VX_VIEW_MLTY
	inc	h
	ld	l, (iy+VX_TRIANGLE_N1)
	ld	bc, (hl)
; fetch VX_VIEW_MLTZ
	inc	h
	ld	l, (iy+VX_TRIANGLE_N2)
	ld	hl, (hl)
	add	hl, bc
	add	hl, de
	ld	de, (iy+VX_TRIANGLE_N3)
	add	hl, de
	add	hl, hl
	exx
	jr	nc, .discard
	add	hl, bc
	ld	hl, (hl)
	add	hl, de
; NOTE : we already have a x3 factor here, so actual scaling to get the two precision bit of 16 + 2.6 or extra bit of 16 + 1.7 isn't truly needed
.DEO=$+1
	ld	de, VX_DEPTH_OFFSET
	add	hl, de
; we'll also set the depth into de
	ex	de, hl
.MTR:=$+1
	ld	hl, VX_DEPTH_BUCKET_H or $CC
	ld	e, l
; write both the ID in the lower 8 bits and the depth in the upper 16 bits, we'll sort on the full 24 bit pair so similar material will be 'packed' together at best without breaking sorting
	ld	(ix+VX_GEOMETRY_DEPTH), de
	ld	l, d
	ld	a, (hl)
	add	a, VX_GEOMETRY_SIZE
	ld	(hl), a
	inc	h
	jr	c, .overflow_h
.continue_h:
	inc	h
; we can't acess deu quickly here, so do a slow read
	ld	l, (ix+VX_GEOMETRY_DEPTH+2)
	ld	a, (hl)
	add	a, VX_GEOMETRY_KEY_SIZE
	ld	(hl), a
	jr	c, .overflow_u
.continue_u:
	ld	(ix+VX_GEOMETRY_INDEX), iy
	lea	ix, ix+VX_GEOMETRY_SIZE
.discard:
.STR:=$+2
	lea	iy, iy+$1C
	ld	hl, (iy+VX_TRIANGLE_I0)
	dec	l
	jr	nz, .pack
.SP_RET0:=$+1
	ld	sp, $CCCCCC
	ld	de, (vxPrimitiveQueue)
	lea	hl, ix+0
	ld	(vxPrimitiveQueue), hl
	or	a, a
	sbc	hl, de
	ex	de, hl
; write the material value to the bucket list
.MTRU:=$+1
	ld	hl, VX_DEPTH_BUCKET_L or $CC
	ld	a, (hl)
	add	a, e
	ld	(hl), a
	inc	h
	ld	a, (hl)
	adc	a, d
	ld	(hl), a
; return de : number of triangle * GEOMETRY_SIZE
	ret
; out of bound in bucket handle
; those occurs only every ~42 triangles within each bucket size
.overflow_h:
	inc	(hl)
	jr	.continue_h
.overflow_u:
	inc	h
	inc	(hl)
	jr	.continue_u
; a (signed) time bc (know is advance), so we can use a LUT table to perform this multiplication at a quite low cost (64 values*3 to compute, we can even push them at cost of 2 bytes + 3 write)
.view_mlt:
	ld	(.SP_RET1), sp
	ld	sp, hl
	ld	ix, 256 - VX_VIEW_MLT_OFFSET
	add	ix, sp
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	b, 6
.view_mlt_pos:
	push	hl
	dec	sp
	add	hl, de
	push	hl
	dec	sp
	add	hl, de
	push	hl
	dec	sp
	add	hl, de
	push	hl
	dec	sp
	add	hl, de
	push	hl
	dec	sp
	add	hl, de
	djnz	.view_mlt_pos
	push	hl
; get to hl = 0 to start the negative span
	add	hl, de
	ld	sp, ix
	ld	b, 6
.view_mlt_neg:
	add	hl, de
	push	hl
	dec	sp
	add	hl, de
	push	hl
	dec	sp
	add	hl, de
	push	hl
	dec	sp
	add	hl, de
	push	hl
	dec	sp
	add	hl, de
	push	hl
	dec	sp
	djnz	.view_mlt_neg
	add	hl, de
	push	hl
.SP_RET1:=$+1
	ld	sp, $CCCCCC
	ret

VX_PRIMITIVE_ASM_SIZE:=$-VX_PRIMITIVE_ASM_CODE
end relocate
