define	VX_DEPTH_CLAMP		8388608

VX_PRIMITIVE_ASM_COPY:

; relocate the shader to fast VRAM ($E30800)

relocate VX_PRIMITIVE_ASM_CODE

vxPrimitiveAssembly:
; 600 cc bfc / accept
; 500 cc bfc / reject
; 200 cc clip reject
.setup:
; input : iy=data, bc=size
	ld	(.SP_RET), sp
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
	ld	hl, (vxGeometryBatchID)
	ld	ix, (vxSubmissionQueue)
	ld	a, (hl)
	and	a, VX_FORMAT_STRIDE
	ld	(.STR), a
	ld	a, l
	ld	(.MTR), a
	inc	hl
; this is the VBO
	ld	bc, (hl)
; preload the first value, it is use as stream end mark
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
	ld	de, VX_DEPTH_CLAMP
	add	hl, de
; heavy but we'll need de later, so save it. Stack is also clobbered
	ld	(.DPH), hl
; we have hl and bc to do the bfc
	ld	hl, VX_VIEW_MLTX shr 2
	ld	l, (iy+VX_TRIANGLE_N0)		; between -64 and 64
	add	hl, hl
	add	hl, hl
	ld	de, (hl)
	ld	hl, VX_VIEW_MLTY shr 2
	ld	l, (iy+VX_TRIANGLE_N1)
	add	hl, hl
	add	hl, hl
	ld	hl, (hl)
	add	hl, de
	ex	de, hl
	ld	hl, VX_VIEW_MLTZ shr 2
	ld	l, (iy+VX_TRIANGLE_N2)
	add	hl, hl
	add	hl, hl
	ld	hl, (hl)
	add	hl, de
	ld	de, (iy+VX_TRIANGLE_N3)
	add	hl, de
	add	hl, hl
	jr	nc, .discard
.DPH:=$+1
	ld	de, $CCCCCC
	ld	(ix+VX_GEOMETRY_DEPTH), de
	ld	hl, VX_DEPTH_BUCKET + $08
	ld	a, l
	ld	l, e
	add	a, (hl)
	ld	(hl), a
	jr	nc, .overflow
	inc	h
	inc	(hl)
.overflow:
	ld	(ix+VX_GEOMETRY_INDEX), iy
.MTR:=$+3
	ld	(ix+VX_GEOMETRY_ID), $CC
	lea	ix, ix+VX_GEOMETRY_SIZE
.discard:
.STR:=$+2
	lea	iy, iy+$1C
	ld	hl, (iy+VX_TRIANGLE_I0)
	bit	0, l
	jr	z, .pack
.SP_RET:=$+1
	ld	sp, $CCCCCC
	ret
; a (signed) time bc (know is advance), so we can use a LUT table to perform this multiplication at a quite low cost (128 values*3 to compute, we can even push them at cost of 2 bytes + 3 write)
; TODO optimize this with pushing value instead of ld (ix+0)' them
.view_mlt:
	or	a, a
	sbc	hl, hl
	ld	b, 17
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
; advance ix
	ld	bc, 1024 - (17*4*4) - 4
	add	ix, bc
	or	a, a
	sbc	hl, hl
	ld	b, 16
; negate de to do negative mlt
	sbc	hl, de
	ex	de, hl
	or	a, a
	sbc	hl, hl
.view_mlt_neg:
	add	hl, de
	ld	(ix-0), hl
	add	hl, de
	ld	(ix-4), hl
	add	hl, de
	ld	(ix-8), hl
	add	hl, de
	ld	(ix-12), hl
	lea	ix, ix-16
	djnz	.view_mlt_neg
	ret
	
VX_PRIMITIVE_ASM_SIZE:=$-VX_PRIMITIVE_ASM_CODE
endrelocate

  align	1024
VX_VIEW_MLTX:
  rb	1024
VX_VIEW_MLTY:
  rb	1024
VX_VIEW_MLTZ:
  rb	1024
