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

include	"shader/vertex.asm"

define	VX_GEOMETRY_QUEUE		$D10000	; 4*4096 (16K)
define	VX_VERTEX_BUFFER		$D08000	; 16*2048 (32K)
define	VX_PRIMITIVE_SORT_CODE		$E30800
define	vxDepthSortTemp			$E30014
define	VX_MAX_TRIANGLE			4096
define	VX_MAX_VERTEX			2048

; TODO : create geometry shader in submission
; Better vertex shader with decoupled projection
; Put all the code in fast ram, use sha256

vxPrimitiveQueue:
 dl	0
vxGeometrySize:
 dl	0
vxPrimitiveMaterial:
 dl	0
vxPrimitiveDepth:
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
vxModelView:
 db    0,0,0
 db    0,0,0
 db    0,0,0
 dl    0,0,0
vxLight:
 db    0,0,0
 db    0,0
 dw    0,0,0
vxModelViewReverse:
 db	0,0,0
 db	0,0,0
 db	0,0,0
 dl	0,0,0

vxPrimitiveSubmit:
.reset:
; various reset blahblah
	ld	hl, (VX_LCD_BUFFER)
	ld	(vxPrimitiveQueue), hl
	ld	hl, NULL_RAM
	ld	de, VX_DEPTH_BUCKET_L
	ld	bc, 256 * 6
	ldir
.setup_pixel:
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
.setup:
; check primitive count and reset it
	ld	de, (vxGeometrySize)
	ld	a, d
	or	a, e
	ret	z
	sbc	hl, hl
	ld	(vxGeometrySize), hl
	ld	iy, VX_GEOMETRY_QUEUE
	ex	de, hl
	lea	de, iy+VX_GEOMETRY_ID
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	(hl), VX_STREAM_END
	jr	.index
; TODO : reallocate .deferred into fast RAM, use jr .index as long jump
; TODO : remove the call vxPrimitiveRenderTriangle
.deferred:
	ld	a, (hl)
	inc	hl
	ld	bc, (hl)			; subcache
	pea	iy+VX_GEOMETRY_KEY_SIZE
	ld	iy, (iy+VX_GEOMETRY_INDEX)	; read triangle data
	call	vxPrimitiveRenderTriangle
	pop	iy
.index:
	ld	hl, VX_MATERIAL_DATA
	ld	l, (iy+VX_GEOMETRY_ID)
	bit	0, l
	jr	z, .deferred
	ret
	
vxPrimitiveStream:
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
	ret	nz			; quit the stream if nz set (bounding box test failed)
	lea	iy, iy+VX_STREAM_HEADER_SIZE
	cce	ge_pri_assembly
; copy primitive assembly within fast area
	ld	hl, VX_PRIMITIVE_ASM_COPY
	ld	de, VX_PRIMITIVE_ASM_CODE
	ld	bc, VX_PRIMITIVE_ASM_SIZE
	ldir
;would be nice to encode the format within
	call	vxPrimitiveAssembly
	ccr	ge_pri_assembly
; need to update count & queue position
; simple : new-previous / 8
	ld	de, (vxPrimitiveQueue)
	lea	hl, ix+0
	ld	(vxPrimitiveQueue), hl
	or	a, a
	sbc	hl, de
	ex	de, hl
	ld	bc, VX_GEOMETRY_SIZE
	call	vxMath.udiv
	ld	hl, (vxGeometrySize)
	add	hl, de
	ld	(vxGeometrySize), hl
	ret

vxVertexStream:
; hl - vertex source, bc - vertex cache, ix worldview0 matrix, iy modelworld0 matrix (should be an model matrix)
; de is the vertex shader program
; vertex source have size at the begining
; support animation
.setup:
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
; equivalent to eye position in modelspace
	push	iy
	ld	hl, vxModelView
	ld	de, vxModelViewReverse
	ld	bc, VX_MATRIX_SIZE
	ldir
	ld	ix, vxModelViewReverse
	call	vxMatrixTranspose
	ld	hl, (ix+VX_MATRIX_TZ)
	ld	(ix+VX_MATRIX_TZ), bc
	add	hl, hl
	add	hl, hl
	ld	(vxWorldEye-1+4), hl
	ld	hl, (ix+VX_MATRIX_TY)
	ld	(ix+VX_MATRIX_TY), bc
	add	hl, hl
	add	hl, hl
	ld	(vxWorldEye-1+2), hl
	ld	hl, (ix+VX_MATRIX_TX)
	ld	(ix+VX_MATRIX_TX), bc
	add	hl, hl
	add	hl, hl
	ld	(vxWorldEye-1), hl
	ld	iy, vxWorldEye
	call	vxfTransform
	ld	de, vxWorldEye
	call	vxfPositionExtract
	pop	hl
; modelworld=modelworld0
; tmodelworld=transpose(modelworld)
	ld	de, vxModelWorld
	ld	bc, VX_MATRIX_SIZE
	ldir
	ld	c, VX_MATRIX_SIZE
	or	a, a
	sbc	hl, bc
	ldir
	ld	ix, vxTModelWorld
	call	vxMatrixTranspose
; light=lightuniform*transpose(modelworld)
; do light*matrix (hl) = (iy)*(ix)
	ld	hl, vxLight
	ld	iy, vxLightUniform
	call	vxMatrixLightning
; load up shader data
	ld	ix, (vxPrimitiveMaterial)
	ld	hl, (ix+VX_MATERIAL_VERTEX_UNIFORM)
	call	.uniform
	pop	iy
; iy = source, ix = matrix
	ld	a, (iy+VX_STREAM_HEADER_OPTION)
	lea	iy, iy+VX_STREAM_HEADER_SIZE
; iy+0 are options, so check those. Here, only bounding box is interesting.
	and	a, VX_STREAM_HEADER_BBOX
	call	nz, .bounding_box
	pop	ix
	ret	nz
; actual stream start
.stream:
	cce	ge_vtx_transform
	ld	(.SP_RET), sp
; ix = cache, iy = source, ix = matrix, bc = size
	jr	.stream_return
.stream_compute:
; 54 cycles can be saved here, (even a bit more in fact)
	ld	sp, vxVertexShader.stack
	call	vxVertexShader.ftransform_trampoline
	lea	ix, ix+VX_VERTEX_SIZE
	lea	iy, iy+VX_VERTEX_DATA_SIZE
.stream_return:
	ld	a, (iy+VX_VERTEX_SM)
	cp	a, VX_ANIMATION_BONE
	jr	z, .stream_load_bone
	cp	a, VX_STREAM_END
	jr	nz, .stream_compute
.stream_end:	
	ccr	ge_vtx_transform
.SP_RET=$+1
	ld	sp, $CCCCCC
	xor	a, a
	ret
.stream_load_bone:
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
	call	vxVertexShader.uniform
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
	ld	e, (iy-1)
	ld	d, VX_ANIMATION_MATRIX_SIZE
	mlt	de
	add	iy, de
	pop	ix
	pop	bc
	jp	.stream_return
.bounding_box:
; check the bounding box
; stream the bounding box as standard vertex stream into the stream routine
	ld	ix, VX_PATCH_VERTEX_POOL
	call	.stream
; account for end marker
	lea	iy, iy+VX_VERTEX_DATA_SIZE
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
; z = inside / clip, nz = outside
	ret
.uniform:
	jp	(hl)

; set the depth offset of the current primitive stream
vxPrimitiveDepthOffset:
	ld	de, VX_DEPTH_OFFSET
	add	hl, de
	ld	(vxPrimitiveDepth), hl
	ret

vxPrimitiveDepthSort:
	cce	ge_z_sort
	ld	hl, VX_PRIMITIVE_SORT_COPY
	ld	de, VX_PRIMITIVE_SORT_CODE
	ld	bc, VX_PRIMITIVE_SORT_SIZE
	ldir
	call	vxPrimitiveDepthSortHelper
	ccr	ge_z_sort
	ret

VX_PRIMITIVE_SORT_COPY:
; relocate to fast RAM
relocate VX_PRIMITIVE_SORT_CODE

vxPrimitiveDepthSortHelper:
; sort the current submission queue
	ld	bc, (vxGeometrySize)
	ld	a, b
	or	a, c
	ret	z
.setup:
	ld	hl, (vxDepthSortTemp)
	ld	(.WRITE_B0), hl
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	ld	(.READ_B0), hl
	ld	de, VX_MAX_TRIANGLE*8   ;VX_GEOMETRY_SIZE
	add	hl, de
	ld	(.WRITE_B1), hl
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	ld	(.READ_B1), hl
; size computation
	ld	a, c
	dec	bc
	inc	b
	ld	c, b
	ld	b, a
	push	bc
	push	bc
	push	bc
; actual sorting start here
; restore index position in array for all three bucket
	ld	hl, VX_DEPTH_BUCKET_L + 511
	ld	d, (hl)
	dec	h
	ld	e, (hl)
	dec	l
.restore_bucket_l:
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
	jr	nz, .restore_bucket_l
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
; high bucket
	ld	hl, VX_DEPTH_BUCKET_H + 511
	ld	d, (hl)
	dec	h
	ld	e, (hl)
	dec	l
.restore_bucket_h:
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
	jr	nz, .restore_bucket_h
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
; upper bucket
	ld	hl, VX_DEPTH_BUCKET_U + 511
	ld	d, (hl)
	dec	h
	ld	e, (hl)
	dec	l
.restore_bucket_u:
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
	jr	nz, .restore_bucket_u
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
; sorting now, backward
	ld	ix, (vxPrimitiveQueue)
	pop	bc
.sort_bucket_l:
	lea	ix, ix-VX_GEOMETRY_SIZE
	ld	hl, VX_DEPTH_BUCKET_L
	ld	l, (ix+VX_GEOMETRY_DEPTH)
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	dec	de
	dec	de
	dec	de
	ld	(hl), d
	dec	h
	ld	(hl), e
.WRITE_B1=$+1
	ld	hl, $CCCCCC
	add	hl, de
	add	hl, de
	ld	iy, (ix+VX_GEOMETRY_INDEX)
	ld	(hl), iy
	inc	hl
	inc	hl
	inc	hl
	ld	iy, (ix+VX_GEOMETRY_DEPTH)
	ld	(hl), iy
	djnz	.sort_bucket_l
	dec	c
	jr	nz, .sort_bucket_l

.READ_B1=$+2
	ld	ix, $CCCCCC
	pop	bc
.sort_bucket_h:
	lea	ix, ix-VX_GEOMETRY_SIZE
	ld	hl, VX_DEPTH_BUCKET_H
	ld	l, (ix+VX_GEOMETRY_DEPTH+1)
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	dec	de
	dec	de
	dec	de
	ld	(hl), d
	dec	h
	ld	(hl), e
.WRITE_B0=$+1
	ld	hl, $CCCCCC
	add	hl, de
	add	hl, de
	ld	iy, (ix+VX_GEOMETRY_INDEX)
	ld	(hl), iy
	inc	hl
	inc	hl
	inc	hl
	ld	iy, (ix+VX_GEOMETRY_DEPTH)
	ld	(hl), iy
	djnz	.sort_bucket_h
	dec	c
	jr	nz, .sort_bucket_h

.READ_B0=$+2
	ld	ix, $CCCCCC
	pop	bc
	ld	de, VX_GEOMETRY_QUEUE
	ld	hl, VX_DEPTH_BUCKET_U
.sort_bucket_u:
	lea	ix, ix-VX_GEOMETRY_SIZE
	ld	l, (ix+VX_GEOMETRY_DEPTH+2)
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	dec	de
	dec	de
	dec	de
	dec	de
	ld	(hl), d
	dec	h
	ld	(hl), e
	ex	de, hl
; copy 4 (VX_GEOMETRY_KEY_SIZE) bytes
	ld	a, (ix+VX_GEOMETRY_INDEX)
	ld	(hl), a
	inc	hl
	ld	iy, (ix+VX_GEOMETRY_INDEX + 1)
	ld	(hl), iy
	ex	de, hl
	djnz	.sort_bucket_u
	dec	c
	jr	nz, .sort_bucket_u
	ret
	
VX_PRIMITIVE_SORT_SIZE:= $ - VX_PRIMITIVE_SORT_CODE
endrelocate
