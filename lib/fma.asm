define	VX_SIGNED_MATRIX_SIZE		21
define	VX_SIGNED_MATRIX_C0		0
define	VX_SIGNED_MATRIX_C1		1
define	VX_SIGNED_MATRIX_C2		2
define	VX_SIGNED_MATRIX_SM0		3
define	VX_SIGNED_MATRIX_C3		4
define	VX_SIGNED_MATRIX_C4		5
define	VX_SIGNED_MATRIX_C5		6
define	VX_SIGNED_MATRIX_SM1		7
define	VX_SIGNED_MATRIX_C6		8
define	VX_SIGNED_MATRIX_C7		9
define	VX_SIGNED_MATRIX_C8		10
define	VX_SIGNED_MATRIX_SM2		11
define	VX_SIGNED_MATRIX_TX		12
define	VX_SIGNED_MATRIX_TY		15
define	VX_SIGNED_MATRIX_TZ		18
define	VX_SIGNED_VECTOR_SIZE		7
define	VX_SIGNED_VECTOR_WX		0
define	VX_SIGNED_VECTOR_WY		2
define	VX_SIGNED_VECTOR_WZ		4
define	VX_SIGNED_VECTOR_SM		6

vxfma_copy:

relocate VX_VERTEX_SHADER_CODE

; vxModelView:
;  db    0,0,0,0
;  db    0,0,0,0
;  db    0,0,0,0
;  dl    0,0,0
; vxLight:
;  db    0,0,0
;  db    0,0,0
;  dw    0,0,0

.write_uniform:
; matrix write
	ld	ix, vxModelView
	ld	c, 0
	ld	a, (ix+VX_MATRIX0_C0)
	
	
	
	ld	(vxVertexCompute.MC0), a
	
	
	ld	a, (ix+VX_MATRIX0_C1)
	ld	(vxVertexCompute.MC1), a
	ld	a, (ix+VX_MATRIX0_C2)
	ld	(vxVertexCompute.MC2), a
	ld	a, (ix+VX_MATRIX0_C3)
	ld	(vxVertexCompute.MC3), a
	ld	a, (ix+VX_MATRIX0_C4)
	ld	(vxVertexCompute.MC4), a
	ld	a, (ix+VX_MATRIX0_C5)
	ld	(vxVertexCompute.MC5), a
	ld	a, (ix+VX_MATRIX0_C6)
	ld	(vxVertexCompute.MC6), a
	ld	a, (ix+VX_MATRIX0_C7)
	ld	(vxVertexCompute.MC7), a
	ld	a, (ix+VX_MATRIX0_C8)
	ld	(vxVertexCompute.MC8), a
	ld	hl, (ix+VX_MATRIX0_TX)
	ld	(vxVertexCompute.MTX), hl
	ld	hl, (ix+VX_MATRIX0_TY)
	ld	(vxVertexCompute.MTY), hl
	ld	hl, (ix+VX_MATRIX0_TZ)
	ld	(vxVertexCompute.MTZ), hl
; ; lightning write
; 	ld	a, (ix+VX_LIGHT0_VECTOR)
; 	ld	(.LV0), a
; 	ld	a, (ix+VX_LIGHT0_VECTOR+1)
; 	ld	(.LV1), a
; 	ld	a, (ix+VX_LIGHT0_VECTOR+2)
; 	ld	(.LV2), a
; 	ld	a, (ix+VX_LIGHT0_AMBIENT)
; 	ld	(.LA), a
; 	ld	a, (ix+VX_LIGHT0_POW)
; 	ld	(.LE), a
	ret

.trampoline_stack:
 dl	.trampoline_v2_ret
 dl	.trampoline_v1_ret
 dl	.trampoline_v0_ret

.ftransform:
	ld	sp, .trampoline_stack
; first value ;
	ld	a, (iy+VX_VERTEX_VS)
.MS0:=$+1
	xor	a, $CC
	ld	hl, .engine_000 shr 1
	ld	l, a
	add	hl, hl
.MC0:=$+1
.MC1:=$+2
	ld	de, $CCCCCC
.MC2:=$+1
	ld	a, $CC
	jp	(hl)
.trampoline_v0_ret:
.MTX:=$+1
	ld	de, $CCCCCC
	add	hl, de
	ld	(ix+VX_VERTEX_RX), hl
; second value ;
	ld	a, (iy+VX_VERTEX_VS)
.MS1:=$+1
	xor	a, $CC
	ld	hl, .engine_000 shr 1
	ld	l, a
	add	hl, hl
.MC3:=$+1
.MC4:=$+2
	ld	de, $CCCCCC
.MC5:=$+1
	ld	a, $CC
	jp	(hl)
.trampoline_v1_ret:
.MTY:=$+1
	ld	de, $CCCCCC
	add	hl, de
	ld	(ix+VX_VERTEX_RY), hl
; third value ;
	ld	a, (iy+VX_VERTEX_VS)
.MS2:=$+1
	xor	a, $CC
	ld	hl, .engine_000 shr 1
	ld	l, a
	add	hl, hl
.MC6:=$+1
.MC7:=$+2
	ld	de, $CCCCCC
.MC8:=$+1
	ld	a, $CC
	jp	(hl)
.trampoline_v1_ret:
.MTZ:=$+1
	ld	de, $CCCCCC
	add	hl, de
	ld	(ix+VX_VERTEX_RZ), hl
	
	
	rb	64
VX_VERTEX_STACK:
	
vxVertexShader:
; hl - vertex source, bc - vertex cache, ix worldview0 matrix, iy modelworld0 matrix (should be an model matrix)
; de is the vertex shader program
; vertex source have size at the begining
; support animation
.setup:
	ld	(.SP_RET), sp
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
; write matrix uniforms
	call	.write_uniform
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
	pop	iy
; iy = source, ix = matrix
	ld	a, (iy+VX_STREAM_HEADER_OPTION)
	lea	iy, iy+VX_STREAM_HEADER_SIZE
	and	a, VX_STREAM_HEADER_BOX
	call	nz, vxVertexStreamBox
	pop	ix
	ret	c
; ix = cache, iy = source, matrix loaded
.stream:
	cce	ge_vtx_transform
	ld	a, (iy+VX_SIGNED_VECTOR_SM)
	cp	a, VX_ANIMATION_BONE	; VX_ANIMATION_BONE is = 2, END STREAM MARK = 1
	jp	z, .apply_bone
	jp	po, .stream_end
.compute:
; vertex shader HERE (a = loaded sign)

	lea	ix, ix+VX_VERTEX_SIZE
	lea	iy, iy+VX_VERTEX_DATA_SIZE
.return:
	ld	a, (iy+VX_SIGNED_VECTOR_SM)
	cp	a, VX_ANIMATION_BONE
	jr	z, .apply_bone
	jp	pe, .compute
.stream_end:
	ccr	ge_vtx_transform
.SP_RET=$+1
	ld	sp, $CCCCCC
	or	a, a
	ret
.apply_bone:
	ld	sp, VX_VERTEX_STACK
; more complex stuff here. Need to restore initial matrix & do a multiplication with the correct bone key matrix
; once done, only advance in the source, not the cache
	push	ix
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
	call	.write_uniform
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
	pop	ix
	pop	bc
	jp	.return
.bounding_box:
; check the bounding box
; stream the bounding box as standard vertex into the stream routine
	ld	ix, VX_PATCH_VERTEX_POOL
	call	.stream
; account for end marker
	inc	iy
	ld	a, (ix-16)
	and	a, (ix-32)
	ret	z
	and	a, (ix-48)
	ret	z
	and	a, (ix-64)
	ret	z
	and	a, (ix-80)
	ret	z
	and	a, (ix-96)
	ret	z
	and	a, (ix-112)
	ret	z
	and	a, (ix-128)
	ret	z
	scf
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
	and	a, VX_STREAM_HEADER_BBOX
	call	nz, vxVertexStreamBox
	pop	ix
	ret	c
	cce	ge_vtx_transform
	ld	a, c
	dec	bc
	inc	b
	ld	c, b
	ld	b, a
; ix = cache, iy = source, ix = matrix, bc = size
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
	lea	ix, ix+VX_VERTEX_SIZE
	lea	iy, iy+VX_VERTEX_DATA_SIZE
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
	push	ix
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
	pop	ix
	pop	bc
	jp	vxVertexStreamLoop
	






	ld	ix, VX_VERTEX_SHADER_DATA
	push	de
	
	ld	ixl, vxfma_trampoline_0
	ld	a, (iy+VX_SIGNED_VECTOR_SM)
	xor	a, (ix+VX_SIGNED_MATRIX_SM0 - vxfma_trampoline_0)
	ld	hl, .engine_000 shr 1
	ld	l, a
	add	hl, hl
	ld	de, (ix+VX_SIGNED_MATRIX_C0 - vxfma_trampoline_0)
	ld	a, (ix+VX_SIGNED_MATRIX_C2 - vxfma_trampoline_0)
	jp	(hl)
vxfma_trampoline_0:= $ and $FF
	ld	de, (ix+VX_SIGNED_MATRIX_TX - vxfma_trampoline_1)
	add	hl, de
	push	hl

	ld	ixl, vxfma_trampoline_1
	ld	a, (iy+VX_SIGNED_VECTOR_SM)
	xor	a, (ix+VX_SIGNED_MATRIX_SM1 - vxfma_trampoline_1)
	ld	hl, .engine_000 shr 1
	ld	l, a
	add	hl, hl
	ld	de, (ix+VX_SIGNED_MATRIX_C3 - vxfma_trampoline_1)
	ld	a, (ix+VX_SIGNED_MATRIX_C5 - vxfma_trampoline_1)
	jp	(hl)
vxfma_trampoline_1:= $ and $FF
	ld	de, (ix+VX_SIGNED_MATRIX_TY - vxfma_trampoline_1)
	add	hl, de
	push	hl

	ld	ixl, vxfma_trampoline_2
	ld	a, (iy+VX_SIGNED_VECTOR_SM)
	xor	a, (ix+VX_SIGNED_MATRIX_SM2 - vxfma_trampoline_2)
	ld	hl, .engine_000 shr 1
	ld	l, a
	add	hl, hl
	ld	de, (ix+VX_SIGNED_MATRIX_C6 - vxfma_trampoline_2)
	ld	a, (ix+VX_SIGNED_MATRIX_C8 - vxfma_trampoline_2)
; carry will be reset when jumping
	jp	(hl)
vxfma_trampoline_2:= $ and $FF
	ld	de, (ix+VX_SIGNED_MATRIX_TZ - vxfma_trampoline_2)
	add	hl, de
	
; 
; 
; ; ix is an 8 bit signed vector, iy is a 16 bit signed vector
; ; 99 (-4) cycles >> total 291 cycles min (+24 worst 315)+ jump or call (inline // not)
; 	ld	a, (iy+VX_SIGNED_VECTOR_SM)
; 	xor	a, (ix+VX_SIGNED_MATRIX_SM0)
; 	ld	hl, .engine_000 shr 1
; 	ld	l, a
; 	add	hl, hl
; 	ld	de, (ix+VX_SIGNED_MATRIX_C0)
; 	ld	a, (ix+VX_SIGNED_MATRIX_C2)
; ; carry will be reset when jumping
; 	jp	(hl)

; 0-0-0
; X-Y-Z
; E-D-A

align 512
.engine_000:
; 192 cycles
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	jp	(ix)

align 64
.engine_001:
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	jp	(ix)
 
align 64
.engine_010:
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	or	a, a
	sbc	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	jp	(ix)
	
align 64
.engine_100:
	ld	h, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	l, a
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	jp	(ix)
	
align 64
.engine_110:
	ld	h, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	l, a
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	or	a, a
	sbc	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	jp	(ix)
 
align 64
.engine_011:
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	or	a, a
	sbc	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	jp	(ix)
 
align 64
.engine_101:
	ld	h, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	l, d
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	jp	(ix)

align 64
.engine_111:
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	jp	(ix) 

endrelocate
