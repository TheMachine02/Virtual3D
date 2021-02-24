define	VX_DEPTH_BUCKET		$D03200
define	VX_DEPTH_TEST		$01
define	VX_DEPTH_BITS		24
define	VX_DEPTH_MIN		0
define	VX_DEPTH_MAX		16777215
define	VX_DEPTH_OFFSET		8388608

VX_PRIMITIVE_ASM_COPY:

; relocate the shader to fast VRAM ($E30800)

relocate VX_PRIMITIVE_ASM_CODE

vxPrimitiveAssembly:
; 4628 cc setup
; 580 cc bfc / accept
; 473 cc bfc / reject
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
	ld	ix, VX_VIEW_MLTX
	call	.view_mlt
	ld	de, (vxWorldEye+3)
	ld	ix, VX_VIEW_MLTY
	call	.view_mlt
	ld	de, (vxWorldEye+6)
	ld	ix, VX_VIEW_MLTZ
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
	ld	de, VX_DEPTH_OFFSET
	add	hl, de
; heavy but we'll need de later, so save it. Stack is also clobbered
	ld	(.DPH), hl
; we have hl and bc to do the bfc
	ld	hl, VX_VIEW_MLTX shr 1
	ld	l, (iy+VX_TRIANGLE_N0)		; between -32 and 32
	add	hl, hl
	ld	de, (hl)
	ld	hl, VX_VIEW_MLTY shr 1
	ld	l, (iy+VX_TRIANGLE_N1)
	add	hl, hl
	ld	hl, (hl)
	add	hl, de
	ex	de, hl
	ld	hl, VX_VIEW_MLTZ shr 1
	ld	l, (iy+VX_TRIANGLE_N2)
	add	hl, hl
	ld	hl, (hl)
	add	hl, de
	ld	de, (iy+VX_TRIANGLE_N3)
	add	hl, de
	add	hl, hl
	jr	nc, .discard
.DPH:=$+1
	ld	de, $CCCCCC
.MTR:=$+1
	ld	e, $CC
;	ld	(ix+VX_GEOMETRY_ID), e
; write both the ID in the lower 8 bits and the depth in the upper 16 bits, we'll sort on the full 24 bit pair so similar material will be 'packed' together at best without breaking sorting
	ld	(ix+VX_GEOMETRY_DEPTH), de
	ld	hl, VX_DEPTH_BUCKET + VX_GEOMETRY_SIZE
	ld	a, l
	ld	l, e
	add	a, (hl)
	ld	(hl), a
	jr	nc, .overflow
	inc	h
	inc	(hl)
.overflow:
	ld	(ix+VX_GEOMETRY_INDEX), iy
	lea	ix, ix+VX_GEOMETRY_SIZE
.discard:
.STR:=$+2
	lea	iy, iy+$1C
	ld	hl, (iy+VX_TRIANGLE_I0)
	bit	0, l
	jr	z, .pack
.SP_RET0:=$+1
	ld	sp, $CCCCCC
	ret
; a (signed) time bc (know is advance), so we can use a LUT table to perform this multiplication at a quite low cost (64 values*3 to compute, we can even push them at cost of 2 bytes + 3 write)
; TODO optimize this with pushing value instead of ld (ix+0)' them
.view_mlt:
	ld	(.SP_RET1), sp
	or	a, a
	sbc	hl, hl
; start at 128+ix with value 32 * de, count as -de each times
	ld	b, 8
.view_mlt_pos:
	ld	(ix+0), hl
	add	hl, de
	ld	(ix+4), hl
	add	hl, de
	ld	(ix+8), hl
	add	hl, de
	ld	(ix+12), hl
	add	hl, de
	lea	ix, ix+16
	djnz	.view_mlt_pos
; start at ix + 512
	ld	bc, 512 - (8*4*4)
	add	ix, bc
	lea	hl, ix+0
	ld	sp, hl
	or	a, a
	sbc	hl, hl
	ld	b, 8
; negate de to do negative mlt
	sbc	hl, de
	ex	de, hl
	or	a, a
	sbc	hl, hl
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

  align	512
VX_VIEW_MLTX:
  rb	1024
VX_VIEW_MLTY:
  rb	1024
VX_VIEW_MLTZ:
  rb	1024
