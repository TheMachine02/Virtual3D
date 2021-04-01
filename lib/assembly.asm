define	VX_DEPTH_TEST		$01
define	VX_DEPTH_BITS		24
define	VX_DEPTH_MIN		0
define	VX_DEPTH_MAX		16777216
define	VX_DEPTH_OFFSET		8388608
define	VX_VIEW_MLT_OFFSET	132

align	256
VX_DEPTH_BUCKET_L:
	rb	512
VX_DEPTH_BUCKET_H:
	rb	512
VX_DEPTH_BUCKET_U:
	rb	512

align	256
VX_VIEW_MLTX:
	rb	256
VX_VIEW_MLTY:
	rb	256
VX_VIEW_MLTZ:
	rb	256

VX_PRIMITIVE_ASM_COPY:
; relocate the shader to fast VRAM ($E30800)
relocate VX_PRIMITIVE_ASM_CODE

vxPrimitiveAssembly:
; 4079 cc setup
; 546/554 cc bfc / accept
; 476 cc bfc / reject
; 212 cc clip reject
.setup:
; input : iy=data, bc=size
	ld	(.SP_RET0), sp
; lut setup
.mlt_generate:
; now the view vector
; we'll need to generate actual LUT table for bc * a (signed)
; bc is know is advance, but we have 3 table for -64 to 64
	ld	de, (vxWorldEye)
	ld	hl, VX_VIEW_MLTX + VX_VIEW_MLT_OFFSET
	call	.view_mlt
	ld	de, (vxWorldEye+3)
	ld	hl, VX_VIEW_MLTY + VX_VIEW_MLT_OFFSET
	call	.view_mlt
	ld	de, (vxWorldEye+6)
	ld	hl, VX_VIEW_MLTZ + VX_VIEW_MLT_OFFSET
	call	.view_mlt
; setup the various SMC
; geometry format STR
; geometry material MTR
	ld	hl, (vxPrimitiveMaterial)
	ld	ix, (vxSubmissionQueue)
	ld	a, (hl)
	and	a, VX_FORMAT_STRIDE
	ld	(.STR), a
	ld	a, l
	ld	(.MTR), a
	inc	hl
; this is the VBO
	ld	bc, (hl)
; preload the first value, it is used as stream end mark
	ld	hl, (iy+VX_TRIANGLE_I0)
	ld	sp, VX_VERTEX_RZ
.pack:
	add	hl, bc
	ld	a, (hl)
	add	hl, sp
	ld	de, (hl)
	ld	hl, (iy+VX_TRIANGLE_I1)
	add	hl, bc
	and	a, (hl)
	add	hl, sp
	ld	hl, (hl)
	add	hl, de
	ex	de, hl
	ld	hl, (iy+VX_TRIANGLE_I2)
	add	hl, bc
	and	a, (hl)
	jr	nz, .discard
	add	hl, sp
	ld	hl, (hl)
	add	hl, de
	add	hl, hl
	add	hl, hl
	ld	de, VX_DEPTH_OFFSET
	add	hl, de
; write both the ID in the lower 8 bits and the depth in the upper 16 bits, we'll sort on the full 24 bit pair so similar material will be 'packed' together at best without breaking sorting
	ld	(ix+VX_GEOMETRY_DEPTH), hl
; we have hl and bc to do the bfc
	ld	hl, VX_VIEW_MLTX
	ld	l, (iy+VX_TRIANGLE_N0)		; between -32 and 32
	ld	de, (hl)
	inc	h				; hl = VX_VIEW_MLTY
	ld	l, (iy+VX_TRIANGLE_N1)
	ld	hl, (hl)
	add	hl, de
	ex	de, hl
	ld	hl, VX_VIEW_MLTZ
	ld	l, (iy+VX_TRIANGLE_N2)
	ld	hl, (hl)
	add	hl, de
	ld	de, (iy+VX_TRIANGLE_N3)
	add	hl, de
	add	hl, hl
	jr	nc, .discard
.MTR:=$+1
	ld	hl, VX_DEPTH_BUCKET_L or $CC
	ld	(ix+VX_GEOMETRY_ID), l
	ld	a, (hl)
	add	a, VX_GEOMETRY_SIZE shr 1
	ld	(hl), a
	inc	h
	jr	nc, .overflow_l
	inc	(hl)
.overflow_l:
	inc	h
	ld	l, (ix+VX_GEOMETRY_DEPTH+1)
	ld	a, (hl)
	add	a, VX_GEOMETRY_SIZE shr 1
	ld	(hl), a
	inc	h
	jr	nc, .overflow_h
	inc	(hl)
.overflow_h:
	inc	h
	ld	l, (ix+VX_GEOMETRY_DEPTH+2)
	ld	a, (hl)
	add	a, VX_GEOMETRY_KEY_SIZE
	ld	(hl), a
	jr	nc, .overflow_u
	inc	h
	inc	(hl)
.overflow_u:
	ld	(ix+VX_GEOMETRY_INDEX), iy
	lea	ix, ix+VX_GEOMETRY_SIZE
.discard:
.STR:=$+2
	lea	iy, iy+$1C
	ld	hl, (iy+VX_TRIANGLE_I0)
	bit	0, l
	jp	z, .pack
.SP_RET0:=$+1
	ld	sp, $CCCCCC
	ret
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
	ld	b, 8
.view_mlt_pos:
	dec	sp
	push	hl
	add	hl, de
	dec	sp
	push	hl
	add	hl, de
	dec	sp
	push	hl
	add	hl, de
	dec	sp
	push	hl
	add	hl, de
	djnz	.view_mlt_pos
	ld	sp, ix
	ld	b, 8
.view_mlt_neg:
	add	hl, de
	dec	sp
	push	hl
	add	hl, de
	dec	sp
	push	hl
	add	hl, de
	dec	sp
	push	hl
	add	hl, de
	dec	sp
	push	hl
	djnz	.view_mlt_neg
.SP_RET1:=$+1
	ld	sp, $CCCCCC
	ret

VX_PRIMITIVE_ASM_SIZE:=$-VX_PRIMITIVE_ASM_CODE
endrelocate
