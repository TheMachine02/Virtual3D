define	VX_DEPTH_FAR_CULL	65536 * 6

; 402 -- 882 :: 900

VX_GEOMETRY_SHADER_COPY:

; relocate the shader to fast VRAM ($E30800)

relocate VX_GEOMETRY_SHADER_CODE

vxGeometryShader:
; input : iy=data, bc=size
	ld	hl, (vxGeometryBatchID)
	ld	ix, (vxSubmissionQueue)
	ld	a, (hl)
	and	a, VX_FORMAT_STRIDE
	ld	(vxGeometryFormat), a
	ld	a, l
	ld	(vxGeometryBatch), a
	inc	hl
	ld	de, (hl)
	ld	(vxGeometryBuffer), de
	ld	hl, VX_VERTEX_RZ
	add	hl, de
	ld	(vxGeometryBufferRZ), hl
vxGeometryLoop:
	push	bc
vxGeometryBuffer=$+1
	ld	de, $000000

	ld	hl, (iy+VX_TRIANGLE_I2)
	add	hl, de
	push	hl
	ld	hl, (iy+VX_TRIANGLE_I1)
	add	hl, de
	ex	de, hl
	ld	bc, (iy+VX_TRIANGLE_I0)
	add	hl, bc
	pop	bc

	ld	a, (bc)
	and	(hl)
	ex	de, hl
	and	(hl)
	jr	nz, vxGeometryDiscard
	ld	a, (bc)
	or	a, (hl)
	ex	de, hl
	or	a, (hl)
	jr	z, vxGeometryNClip
vxGeometryNext:
	jr	c, vxGeometryDiscard
; compute depth and submit polygon to list (ix)
vxGeometryBufferRZ=$+1
	ld	bc, $000000
; index 0 - rz
	ld	hl, (iy+VX_TRIANGLE_I0)
	add	hl, bc
	ld	de, (hl)
; index 1 - rz	
	ld	hl, (iy+VX_TRIANGLE_I1)
	add	hl, bc
	ld	hl, (hl)
	add	hl, de
	ex	de, hl
; index 2 - re
	ld	hl, (iy+VX_TRIANGLE_I2)
	add	hl, bc
	ld	hl, (hl)
	adc	hl, de
; no div - way too slow !
	jp	p, vxGeometryDepthClamp
	or	a, a
	sbc	hl, hl
vxGeometryDepthClamp:
; depth culling
; 	ld	de, VX_DEPTH_FAR_CULL
; 	sbc	hl, de
; 	jr	nc, vxGeometryDiscard
; 	add	hl, de
; write everything to tmp buffer
	ld	(ix+VX_GEOMETRY_DEPTH), hl
; fill depth bucket
	ex	de, hl
	ld	hl, VX_DEPTH_BUCKET+8
	ld	a, l
	ld	l, e
	add	a, (hl)
	ld	(hl), a
	jr	nc, vxGeometryBucket
	inc	h
	inc	(hl)
vxGeometryBucket:
	ld	(ix+VX_GEOMETRY_INDEX), iy
vxGeometryBatch=$+3
	ld	(ix+VX_GEOMETRY_ID), $00
	lea	ix, ix+VX_GEOMETRY_SIZE
vxGeometryDiscard:
vxGeometryFormat=$+2
	lea	iy, iy+16
	pop	bc
	djnz	vxGeometryLoop
	dec	c
	jr	nz, vxGeometryLoop
	ret
vxGeometryNClip:
; hl : vertex 0
; de : vertex 1
; bc : vertex 2
	inc	hl
	inc	de
	inc	bc
	push	hl
	push	bc
	ld	a, (bc)
	inc	hl
	ld	hl, (hl)
	ex	de, hl
	inc	hl
	ld	bc, (hl)
	ex	de, hl
	or	a, a
	sbc	hl, bc
	sra	h
	rr l
	ld	c, h
	ex	de, hl
	dec	hl
	sub	a, (hl)
	ld	d, a
	ld	a, 0
	jr	nc, $+3
	sub a, e
	bit 7, c
	jr z, $+3
	sub a, d
	mlt	de
	add	a, d
	ld	d, a
	ld	a, (hl)
	inc	hl
	ld	c, (hl)
	pop	hl
	inc	hl
	ld	hl, (hl)
	or	a, a
	sbc	hl, bc
	sra	h
	rr l
	ld	c, h
	ld	b, l
	pop	hl
	sub	a, (hl)
	ld	l, a
	ld	h, b
	ld	a, 0
	jr nc,$+3
	sub a, h
	bit	7, c
	jr z, $+3
	sub a, l
	mlt	hl
	add	hl, de
	dec	hl
	add	a, h
	rla
	jp	vxGeometryNext

endrelocate
