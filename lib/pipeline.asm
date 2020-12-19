include	"shader/vertex.asm"

define	VX_GEOMETRY_QUEUE		$D10000	; 4*4096 (16K)
define	VX_VERTEX_BUFFER		$D08000	; 16*2048 (32K)

define	vxDepthSortTemp		$E30014

define	VX_MAX_TRIANGLE			4096
define	VX_MAX_VERTEX			2048
define	VX_BATCH_DATA		$D03500

; TODO : create geometry shader in submission
; Better vertex shader with decoupled projection
; Put all the code in fast ram, use sha256

vxSubmissionQueue:
 dl	0
vxGeometrySize:
 dl	0
vxPrimitiveMaterial:
 dl	0
vxModelViewCache:
 db	0,0,0
 db	0,0,0
 db	0,0,0
 dl	0,0,0
vxModelWorld:
 db	0,0,0
 db	0,0,0
 db	0,0,0
 dl	0,0,0
vxTModelWorld:
 db	0,0,0
 db	0,0,0
 db	0,0,0
 dl	0,0,0
vxLightUniform:
 db	0,0,0
 db	0,0,0
 dw	0,0,0
vxAnimationKey:
 db	0
vxTexturePage:
 dl	0
vxPosition:
 dl	0,0,0
 db	0
vxWorldEye:
 dl	0,0,0
 db	0

vxModelViewReverse:
 db	0,0,0
 db	0,0,0
 db	0,0,0
 dl	0,0,0

vxQueueSubmit:
; various reset blahblah
	ld	hl, (VX_LCD_BUFFER)
	ld	(vxSubmissionQueue), hl
	ld	iy, VX_GEOMETRY_QUEUE
	ld	hl, VX_DEPTH_BUCKET
	ld	de, VX_DEPTH_BUCKET+1
	ld	bc, 511
	ld	(hl), $00
	ldir
	ld	hl, VX_REGISTER_INTERPOLATION_COPY
	ld	de, VX_REGISTER_INTERPOLATION_CODE
	ld	bc, VX_REGISTER_INTERPOLATION_SIZE
	ldir
; this is ugly at best
	ld	hl, (vxShaderJump)
	ld	(vxShaderJumpWrite), hl
	ld	hl, (vxShaderAdress0)
	ld	(vxShaderAdress0Write), hl
	ld	hl, (vxShaderAdress1)
	ld	(vxShaderAdress1Write), hl
	ld	hl, (vxShaderAdress2)
	ld	(vxShaderAdress2Write), hl
; reset geometry size >>> change to endpoint writing instead of looping ? TODO
	ld	bc, (vxGeometrySize)
	or	a, a
	sbc	hl, hl
	ld	(vxGeometrySize), hl
	ld	a, b
	or	c
	ret	z
	ld	a, c
	dec	bc
	inc	b
	ld	c, b
	ld	b, a
vxPrimitiveDeferred:
	push	bc
	ld	hl, VX_MATERIAL_DATA
	ld	l, (iy+VX_GEOMETRY_ID)
	ld	a, (hl)
	inc	hl
	ld	bc, (hl)			; subcache
	pea	iy+4
	ld	iy, (iy+VX_GEOMETRY_INDEX)	; read triangle data
	call	vxPrimitiveRenderTriangle
	pop	iy
	pop	bc
	djnz	vxPrimitiveDeferred
	dec	c
	jr	nz, vxPrimitiveDeferred
	ret 
	
vxQueueGeometry:
; hl : vertex source
;  a : material ID
; bc : triangle source
; ix : worldview matrix
; iy : modelworld matrix
	push	bc
	ex	de, hl
	ld	hl, VX_MATERIAL_DATA
	ld	l, a
	ld	(vxPrimitiveMaterial), hl
	inc	hl
	ld	bc, (hl)
	inc	hl
	inc	hl
	inc	hl
	ld	hl, (hl)
	ex	de, hl
	call	vxVertexStream		; stream vertex data to cache
	pop	iy			; polygon list
	ret	c			; quit the stream if carry set (bounding box test failed)
; copy geometry shader
	ld	hl, VX_PRIMITIVE_ASM_COPY
	ld	de, VX_PRIMITIVE_ASM_CODE
	ld	bc, VX_PRIMITIVE_ASM_SIZE
	ldir
; continue processing
	ld	bc, (iy+VX_STREAM_HEADER_COUNT)
	ld	a, c
	dec	bc
	inc	b
	ld	c, b
	ld	b, a
	lea	iy, iy+VX_STREAM_HEADER_SIZE
	cce	ge_pri_assembly
;would be nice to encode the format within
	call	vxPrimitiveAssembly
	ccr	ge_pri_assembly
; need to update count & queue position
; simple : new-previous / 8
	ld	de, (vxSubmissionQueue)
	lea	hl, ix+0
	ld	(vxSubmissionQueue), hl
	or	a, a
	sbc	hl, de
	sra	h
	rr	l
	sra	h
	rr	l
	sra	h
	rr	l
	ld	bc, (vxGeometrySize)
	add	hl, bc
	ld	(vxGeometrySize), hl
	ret

vxVertexStream:
; hl - vertex source, bc - vertex cache, ix worldview0 matrix, iy modelworld0 matrix (should be an model matrix)
; de is the vertex shader program
; vertex source have size at the begining
; support animation
	push	bc
	push	hl
; load shader first
	ex	de, hl
	ld	de, VX_VERTEX_SHADER_CODE
	ld	bc, VX_VERTEX_SHADER_SIZE
	ldir
; transform the worldview with the modelworld matrix to have the global modelview matrix
; modelviewcache = modelworld0 * worldview0
	ld	hl, vxModelViewCache
	call	vxMatrixTransform		; (hl) = (iy)*(ix)
; modelview=modelviewcache
	ld	de, vxModelView
	ld	bc, VX_MATRIX_SIZE
	ldir
; modelViewReverseTranslate = modelViewTranslate * transpose(modelview)
; equivalent to eye position in worldspace (worldpos)
	push	iy

	ld	hl, vxModelView
	ld	de, vxModelViewReverse
	ld	bc, VX_MATRIX_SIZE
	ldir
	ld	ix, vxModelViewReverse
	call	vxMatrixTranspose

	ld	de, 0
	ld	hl, (ix+VX_MATRIX_TZ)
	ld	(ix+VX_MATRIX_TZ), de
	add	hl, hl
	add	hl, hl
	ld	(vxWorldEye-1+4), hl
	ld	hl, (ix+VX_MATRIX_TY)
	ld	(ix+VX_MATRIX_TY), de
	add	hl, hl
	add	hl, hl
	ld	(vxWorldEye-1+2), hl
	ld	hl, (ix+VX_MATRIX_TX)
	ld	(ix+VX_MATRIX_TX), de
	add	hl, hl
	add	hl, hl
	ld	(vxWorldEye-1), hl

	ld	iy, vxWorldEye
	call	vxfTransform
	ld	de, vxWorldEye
	call	vxfPositionExtract

	call	vxVertexShader.write_uniform
	
	pop	iy
; modelworld=modelworld0
; tmodelworld=transpose(modelworld)
	lea	hl, iy+0
	ld	de, vxModelWorld
	ld	bc, VX_MATRIX_SIZE
	ldir
	lea	hl, iy+0
	ld	c, VX_MATRIX_SIZE
	ldir
	ld	ix, vxTModelWorld
	call	vxMatrixTranspose
; light=lightuniform*transpose(modelworld)
; do light*matrix (hl) = (iy)*(ix)
	ld	hl, vxLight
	ld	iy, vxLightUniform
	call	vxMatrixLightning
; load up shader data
	pop	iy
; iy = source, ix = matrix
	ld	a, (iy+VX_STREAM_HEADER_OPTION)
	ld	bc, (iy+VX_STREAM_HEADER_COUNT)
	lea	iy, iy+VX_STREAM_HEADER_SIZE
; iy+0 are options, so check those. Here, only bounding box is interesting.
	and	VX_STREAM_HEADER_BBOX
	call	nz, vxVertexStreamBox
	pop	de
	ret	c
	cce	ge_vtx_transform
	ld	a, c
	dec	bc
	inc	b
	ld	c, b
	ld	b, a
; de = cache, iy = source, ix = matrix, bc = size
vxVertexStreamLoop:
	push	bc
; read first source value, if value=32768, then compute bone
	ld	bc, (iy+0)
	ld	a, b
	xor	VX_ANIMATION_BONE/256
	or	a, c
; wasn't a bone in source, so read vertex
; call vertex shader
	jr	z, vxVertexLoadBone
	call	vxVertexCompute
	pop	bc
	djnz	vxVertexStreamLoop
	dec	c
	jr	nz, vxVertexStreamLoop
	ccr	ge_vtx_transform
	or	a, a
	ret
vxVertexLoadBone:
; more complex stuff here. Need to restore initial matrix & do a multiplication with the correct bone key matrix
; once done, only advance in the source, not the cache
	push	de
	lea	iy, iy+VX_ANIMATION_HEADER_SIZE
	push	iy
	ld	a, (vxAnimationKey)
	ld	e, a
	ld	d, VX_ANIMATION_MATRIX_SIZE
	mlt	de
	add	iy, de	; correct animation matrix
; modelview = bonemodel*modelview
	ld	hl, vxModelView
	ld	ix, vxModelViewCache
	call	vxMatrixTransform	; (hl)=(iy)*(ix)
; I have the correct modelview matrix in shader cache area
; next one is reduced matrix without translation, since it will only be a direction vector mlt. However, the light vector position also need to be transformed by the transposed matrix
	call	vxVertexShader.write_uniform
; light = lightuniform*transpose(bonemodel*modelworld)
	ld	ix, vxModelWorld
	lea	hl, ix+VX_MATRIX_SIZE
	call	vxMatrixMlt
	lea	ix, ix+VX_MATRIX_SIZE
	call	vxMatrixTranspose
	ld	hl, vxLight
	ld	iy, vxLightUniform
	call	vxMatrixLightning
	pop	iy
	ld	a, (iy-1)
	ld	e, a
	ld	d, VX_ANIMATION_MATRIX_SIZE
	mlt	de
	add	iy, de
	pop	de
	pop	bc
	jp	vxVertexStreamLoop

vxVertexStreamBox:
	push	bc
; check the bounding box
	ld	de, VX_PATCH_VERTEX_POOL
	ld	a, $FF
	ld	b, 8
vxVertexBoxLoop:
	push	bc
	push	af
	ld	bc, (iy+0)
	call	vxVertexCompute
	lea	iy, iy-3
	ld	hl, -16
	add	hl, de
	pop	af
	and	a, (hl)
	pop	bc
	djnz	vxVertexBoxLoop
	pop	bc
	ret	z
	scf
	ret

vxQueueDepthSort:
	ld	bc, (vxGeometrySize)
	ld	a, b
	or	a, c
	ret	z
	cce	ge_z_sort
	ld	hl, VX_QUEUE_BUFFER
	ld	de, VX_VERTEX_SHADER_CODE
	ld	bc, VX_QUEUE_SORT_SIZE
	ldir
	jp	VX_VERTEX_SHADER_CODE

VX_QUEUE_BUFFER:=$
relocate VX_VERTEX_SHADER_CODE
; sort the current submission queue
	ld	ix, (vxSubmissionQueue)
	ld	hl, (vxDepthSortTemp)
	ld	(vxCmdReadBuffer0), hl
	ld	(vxCmdWriteBuffer0), hl
	ld	de, VX_MAX_TRIANGLE*8
	add	hl, de
	ld	(vxCmdReadBuffer1), hl
	ld	(vxCmdWriteBuffer1), hl

; restore index position in array
	ld	hl, VX_DEPTH_BUCKET+511
	ld	d, (hl)
	dec	h
	ld	e, (hl)
	dec	l
vxCmdRestoreBucketLoop0:
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	dec	l
	jr	nz, vxCmdRestoreBucketLoop0
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
; and copy to the correct position
	lea	ix, ix-8
	ld	bc, (vxGeometrySize)
	ld	a, c
	dec	bc
	inc	b
	ld	c, a
	push	bc
	push	bc
	push	bc
	push	bc
	ld	a, c
vxCmdFillBucketOuter0:
	push	bc
	ld	b, 0
vxCmdFillBucketInner0:
	ld	hl, VX_DEPTH_BUCKET+8
	ld	c, l
	ld	l, (ix+VX_GEOMETRY_DEPTH)
	ld	e, (hl)
	inc	h
	ld	d, (hl)
;	dec	de
	ex	de, hl
	sbc.s	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
; de*7+write_buffer
;	ld	h, c
;	ld	l, d
;	ld	d, c
;	mlt	hl
;	mlt	de
;	ld	h, l
;	ld	l, b
;	add	hl, de
vxCmdWriteBuffer1=$+1
	ld	hl, $0
	add	hl, de
	ex	de, hl
	lea	hl, ix+0
	ldir
	lea	ix, ix-8
	dec	a
	jr	nz, vxCmdFillBucketInner0
	pop	bc
	djnz	vxCmdFillBucketOuter0

vxCmdReadBuffer1=$+2
	ld	ix, $0

	ld	bc, 511
	ld	hl, VX_DEPTH_BUCKET+511
	ld	de, VX_DEPTH_BUCKET+510
	ld	(hl), $00
	lddr
; restore size
	pop	bc
	ld	a, c
	ld	c, b
	ld	b, a
	ld	e, 8
	ld	l, (ix+VX_GEOMETRY_DEPTH+1)
	ld	a, e
	add	a, (hl)
	ld	(hl), a
	jr	nc, $+5
	inc	h
	inc	(hl)
	dec	h
	lea	ix, ix+8
	djnz	$-14
	dec	c
	jr	nz, $-17
	ld	l, 255
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	dec	h
	dec	l
vxCmdRestoreBucket1:
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	dec	l
	jr	nz, vxCmdRestoreBucket1
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	lea	ix, ix-8

	pop	bc
	ld	a, c
vxCmdFillBucketOuter1:
	push	bc
	ld	b, 0
vxCmdFillBucketInner1:
	ld	hl, VX_DEPTH_BUCKET+8
	ld	c, l
	ld	l, (ix+VX_GEOMETRY_DEPTH+1)
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	ex	de, hl
	sbc.sil	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
vxCmdWriteBuffer0=$+1
	ld	hl, $0
	add	hl, de
	ex	de, hl
	lea	hl, ix+0
	ldir
	lea	ix, ix-8
	dec	a
	jr	nz, vxCmdFillBucketInner1
	pop	bc
	djnz	vxCmdFillBucketOuter1

vxCmdReadBuffer0=$+2
	ld	ix, $0

	ld	bc, 511
	ld	hl, VX_DEPTH_BUCKET+511
	ld	de, VX_DEPTH_BUCKET+510
	ld	(hl), $00
	lddr

	pop	bc
	ld	a, c
	ld	c, b
	ld	b, a
	ld	e, 4		; size of final batch
	ld	l, (ix+VX_GEOMETRY_DEPTH+2)
	ld	a, e
	add	a, (hl)
	ld	(hl), a
	jr	nc, $+5
	inc	h
	inc	(hl)
	dec	h
	lea	ix, ix+8
	djnz	$-14
	dec	c
	jr	nz, $-17
	ld	l, 255
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	dec	h
	dec	l
vxCmdRestoreBucket2:
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	dec	l
	jr	nz, vxCmdRestoreBucket2
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	lea	ix, ix-8

	pop	bc
	ld	a, c
	inc	l
vxCmdFillBucket2:
	ld	l, (ix+VX_GEOMETRY_DEPTH+2)
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	dec.sil	de
	dec	de
	dec	de
	dec	de
	ld	(hl), d
	dec	h
	ld	(hl), e
	ld	iy, VX_GEOMETRY_QUEUE
	add	iy, de
; copy only the triangle adress
	ld	de, (ix+VX_GEOMETRY_INDEX)
	ld	(iy+VX_GEOMETRY_INDEX), de
	ld	l, (ix+VX_GEOMETRY_ID)
	ld	(iy+VX_GEOMETRY_ID), l

	lea	ix, ix-8
	dec	a
	jr	nz, vxCmdFillBucket2
	djnz	vxCmdFillBucket2
	ccr	ge_z_sort
	ret
	
VX_QUEUE_SORT_SIZE := $ - VX_VERTEX_SHADER_CODE
endrelocate

vxNClip:
; we'll compute (y1-y0)*(x2-x1)+(y2-y1)*(x0-x1)
	inc	hl
	inc	bc
	inc	de
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
	sra	h
	rr	l
	ld	c, h
	ex	de, hl
	dec	hl
	sub	a, (hl)
	ld	d, a
	ld	a, 0
	jr	nc, $+3
	sub	a, e
	bit	7, c
	jr	z, $+3
	sub	a, d
	mlt	de
	add	a, d
	ld	d, a
; bc and hl need a restore
; (y1-y0)*(x2-x1)
;  a - (hl)*hl-bc
	ld	a, (hl)
	inc	hl
	ld	c, (hl)	; b still hold correct value
	pop	hl	; pop bc
	inc	hl
	ld	hl, (hl)
	or	a, a
	sbc	hl, bc
	sra	h
	rr	l
	ld	c, h
	ex	de, hl
	ex	(sp), hl	; save previous de
	sub	a, (hl)
	ld	d, a
	ld	a, 0
	jr	nc, $+3
	sub	a, e
	bit	7, c
	jr	z, $+3
	sub	a, d
	mlt	de
	add	a, d
	ld	d, a
; do de + temp_value
	pop	hl
	add	hl, de
	dec	hl
	rl	h
	ret
