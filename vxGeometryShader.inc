#define	VX_INDEX0	0
#define	VX_INDEX1	3
#define	VX_INDEX2	6

#define	VX_GEOMETRY_DEPTH	0
#define	VX_GEOMETRY_INDEX	3
#define	VX_GEOMETRY_ID		6

#define	VX_GEOMETRY_SHADER_DATA		$E30800
#define	VX_GEOMETRY_SHADER_CODE		$E30800

vxGeometryShader:
	push	bc
vxBufferOffset=$+1
	ld	de, $000000

	ld	hl, (iy+VX_INDEX2)
	add	hl, de
	push	hl
	ld	hl, (iy+VX_INDEX1)
	add	hl, de
	ex	de, hl
	ld	bc, (iy+VX_INDEX0)
	add	hl, bc
	pop	bc

	ld	a, (bc)
	and	(hl)
	ex	de, hl
	and	(hl)
	jr	nz, vxGeometryDiscard
	ld	a, (bc)
	or	(hl)
	ex	de, hl
	or	(hl)
	jr	nz, vxGeometryPass
	call	vxNClip
	jr	c, vxGeometryDiscard
vxGeometryPass:
; compute depth and submit polygon to list (ix)
vxBufferOffsetAddRZ:
	ld	bc, $000000
; index 0 - rz
	ld	hl, (iy+VX_INDEX0)
	add	hl, bc
	ld	de, (hl)
; index 1 - rz	
	ld	hl, (iy+VX_INDEX1)
	add	hl, bc
	ld	hl, (hl)
	add	hl, de
	ex	de, hl
; index 2 - re
	ld	hl, (iy+VX_INDEX2)
	add	hl, bc
	ld	hl, (hl)
	adc	hl, de
; no div - way too slow !
	jp	p, vxGeometryDepthClamp
	or	a, a
	sbc	hl, hl
vxGeometryDepthClamp:
; write everything to tmp buffer
	ld	(ix+VX_GEOMETRY_DEPTH), hl
; fill depth bucket
	ex	de, hl
	ld	hl, VX_DEPTH_BUCKET+7
	ld	a, l
	ld	l, e
	add	a, (hl)
	ld	(hl), a
	jr	nc, vxGeometryBucket
	inc	h
	inc	(hl)
vxGeometryBucket:
	ld	(ix+VX_GEOMETRY_INDEX), iy
vxBatchOffset=$+1
	ld	a, $00
	ld	(ix+VX_GEOMETRY_ID), a
vxGeometryDiscard:
vxFormatOffset=$+2
	lea	iy, iy+16
	pop	bc
	djnz	vxGeometryShader
	dec	c
	jr	nz, vxGeometryShader
	ret


vxNClip:
; vec e0 = v1 - v0;
; vec e1 = v2 - v0;
; return e0.x * e1.y - e0.y * e1.x > 0 ? 1 : 0;
;
;	(x1-x0)*(y2-y1) - (y1-y0)*(x2-x1)
;
; we'll compute (y1-y0)*(x2-x1)+(y2-y1)*(x0-x1)
	inc	hl \ inc bc \ inc de

	push	hl
	push	bc

	ld	a, (bc)
	inc	hl
	ld	hl, (hl)
	ex	de, hl
	inc	hl
	ld	bc, (hl)
	ex	de, hl
; hl-bc is x0-x1
	or	a, a
	sbc	hl, bc
	sra	h \ rr l
	ld	c, h
	ex	de, hl
	dec	hl
	sub	a, (hl)
	ld	d, a
	ld	a, 0
	jr	nc, $+3 \ sub a, e
	bit 7, c \ jr z, $+3 \ sub a, d
	mlt	de
	add	a, d
	ld	d, a		
; bc and hl need a restore
; (y1-y0)*(x2-x1)
;  a - (hl)*hl-bc
	ld	a, (hl)
	inc	hl
;	ld	bc, (hl)
	ld	c, (hl)	; b still hold correct value
	pop	hl	; pop bc
	inc	hl
	ld	hl, (hl)
	or	a, a
	sbc	hl, bc
	sra	h \ rr l
	ld	c, h
	ex	de, hl
	ex	(sp), hl	; save previous de
	sub	a, (hl)
	ld	d, a
	ld	a, 0
	jr	nc, $+3 \ sub a, e
	bit 7, c \ jr z, $+3 \ sub a, d
	mlt	de
	add	a, d
	ld	d, a		
; do de + temp_value
	pop	hl
	add	hl, de
	dec	hl
	rl	h
	ret



#comment
	ld	ix, (iy+VX_INDEX0)
	add	ix, bc
	ld	hl, (ix+VX_VERTEX_RZ)
	ld	ix, (iy+VX_INDEX1)
	add	ix, bc
	ld	de, (ix+VX_VERTEX_RZ)
	add	hl, de
	ld	ix, (iy+VX_INDEX2)
	add	ix, bc	; shouldn't carry
	ld	de, (ix+VX_VERTEX_RZ)
	adc	hl, de
	jp	p, vxAvgDepthPositive
	or	a, a
	sbc	hl, hl
vxAvgDepthPositive:

#endcomment