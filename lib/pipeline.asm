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
define	VX_MAX_TRIANGLE			4096
define	VX_MAX_VERTEX			2048

; poison bit to mark vertex as to be not transformed
; it should be reset if we should transform it
define	VX_VERTEX_POISON		1 shl VX_VERTEX_POISON_BIT
define	VX_VERTEX_POISON_BIT		7

; TODO : create geometry shader in submission
; Better vertex shader with decoupled projection
; Put all the code in fast ram, use sha256

VIRTUAL_PIPELINE_STATE:
 db	0
; pipeline state
vxPrimitiveQueue:
 dl	0
vxPrimitiveQueueSize:
 dl	0
vxPrimitiveMaterial:
 dl	0
vxPrimitiveDepth:
 dl	VX_DEPTH_OFFSET
vxModelViewCache:
 db	0,0,0
 db	0,0,0
 db	0,0,0
vxModelViewCache_t:
 dl	0,0,0
vxModelWorld:
 db	0,0,0
 db	0,0,0
 db	0,0,0
vxModelWorld_t:
 dl	0,0,0
vxModelWorldReverse:
 db	0,0,0
 db	0,0,0
 db	0,0,0
vxModelWorldReverse_t:
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
vxView_t:
 dl	0,0,0
 db	0
vxModelView:
 db    0,0,0
 db    0,0,0
 db    0,0,0
vxModelView_t:
 dl    0,0,0
vxLight:
 db    0,0,0
 db    0,0
 dw    0,0,0
vxModelViewReverse:
 db	0,0,0
 db	0,0,0
 db	0,0,0
vxModelViewReverse_t:
 dl	0,0,0
vxIdentityMatrix:
 db	64,0,0
 db	0,64,0
 db	0,0,64
 dl	0,0,0
; projection matrix is (1/tan(fov/2)) / aspect and the (1/tan(fov/2))
; note we loose precision because 0.6 isn't quite enough (move to 8.8 ?)
vxProjectionMatrix:
 db	64,0,0
 db	0,85,0
 db	0,0,64
vxProjectionMatrix_t:
 dl	0,0,0
 
vxPrimitiveSubmit:
.reset:
; various reset
	ld	hl, (VX_LCD_BUFFER)
	ld	(vxPrimitiveQueue), hl
	ld	hl, VIRTUAL_NULL_RAM
	ld	de, VX_DEPTH_BUCKET_L
	ld	bc, 1536
	ldir
.setup_pixel:
	ld	hl, VX_PRIMITIVE_INTERPOLATION_COPY
	ld	de, VX_PRIMITIVE_INTERPOLATION_CODE
	ld	bc, VX_PRIMITIVE_INTERPOLATION_SIZE
	ldir
	ld	hl, vxPixelShader.code
	ld	de, VX_PIXEL_SHADER_CODE
	ld	c, 64
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
	ld	hl, (vxPrimitiveQueueSize)
	ld	a, h
	or	a, l
	ret	z
	ld	iy, VX_GEOMETRY_QUEUE
	lea	de, iy+VX_GEOMETRY_ID
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	(hl), VX_STREAM_END
; note, bc should be zero here
	ld	(vxPrimitiveQueueSize), bc
	jr	.index
; TODO : reallocate .deferred into fast RAM, use jr .index as long jump
; TODO : remove the call vxPrimitiveRenderTriangle
.deferred:
	ld	a, (hl)
	inc	hl
	ld	bc, (hl)			; subcache
	pea	iy+VX_GEOMETRY_KEY_SIZE
	ld	iy, (iy+VX_GEOMETRY_INDEX)	; read triangle data
	call	vxPrimitiveRender.triangle
	pop	iy
.index:
	ld	hl, VX_MATERIAL_DATA
	ld	l, (iy+VX_GEOMETRY_ID)
	ld	b, l
	djnz	.deferred
	ret

vxPrimitiveStream:
; send a primitive stream for submission
; handle calling the vertex shader & 
; hl : vertex source
;  a : material ID
; de : triangle source
; ix : worldview matrix
; iy : modelworld matrix
	push	de
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
	call	.setup_matrix		; stream vertex data to cache
	pop	iy			; polygon list
	ret	nz			; quit the stream if nz set (bounding box test failed)
	cce	ge_pri_assembly
; copy primitive assembly within fast area
	ld	hl, VX_PRIMITIVE_ASM_COPY
	ld	de, VX_PRIMITIVE_ASM_CODE
	ld	bc, VX_PRIMITIVE_ASM_SIZE
	ldir
;would be nice to encode the format within
	call	vxPrimitiveAssembly
; need to update count & queue position
; simple : new-previous (de)/6
	ld	bc, VX_GEOMETRY_SIZE
	call	vxMath.udiv
	ld	hl, (vxPrimitiveQueueSize)
	add	hl, de
	ld	(vxPrimitiveQueueSize), hl
	ccr	ge_pri_assembly
	ret

.setup_matrix:
; de - vertex source, bc - vertex cache, ix worldview0 matrix, iy modelworld0 matrix (should be an model matrix)
; hl is the vertex shader program
; NOTE : expect material to be set
; vertex source have size at the begining
; support animation
	push	bc
	push	de
; load shader first
	ld	de, VX_VERTEX_SHADER_CODE
	ld	bc, VX_VERTEX_SHADER_SIZE
	ldir
	lea	hl, iy+0
	ld	de, vxModelWorldReverse
	ld	bc, VX_MATRIX_SIZE
	ldir	
; transform the worldview with the modelworld matrix to have the global modelview matrix
; modelview = modelworld0 * worldview0
	ld	hl, vxModelView
	call	vxMatrixTransform		; (hl) = (iy)*(ix)
; modelViewReverseTranslate = -modelViewTranslate * transpose(modelview)
; equivalent to eye position in modelspace
	ld	hl, vxModelView
	ld	de, vxModelViewReverse
	ld	bc, VX_MATRIX_SIZE
	ldir
	ld	iy, vxModelView
	ld	ix, vxProjectionMatrix
	ld	hl, vxModelView
	call	vxMatrixTransform
	ld	ix, vxModelViewReverse
	call	vxMatrixTranspose
	ld	iy, vxView_t
	lea	hl, ix+VX_MATRIX_TX
	lea	de, iy+0
	ld	bc, 9
	ldir	
	ld	(ix+VX_MATRIX_TZ), bc
	ld	(ix+VX_MATRIX_TY), bc
	ld	(ix+VX_MATRIX_TX), bc
	call	vxfTransformDouble
	lea	de, iy+0
	call	vxfPositionExtract
; modelworldreverse=transpose(modelworld)
	ld	ix, vxModelWorldReverse
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
; reset VRAM_CACHE
	ld	hl, vxVertexShader.iterate
	ld	de, VX_VRAM_CACHE
	ld	bc, VX_VRAM_CACHE_SIZE
	ldir
	pop	iy
; iy = source, ix = matrix
; reset poison
	ld	bc, (iy+VX_STREAM_HEADER_COUNT)
	push	bc
	ld	a, (iy+VX_STREAM_HEADER_OPTION)
; iy+0 are options, so check those. Here, only bounding box is interesting.
	lea	iy, iy+VX_STREAM_HEADER_SIZE
	and	a, VX_STREAM_HEADER_BBOX
	call	nz, .bounding_box
	pop	bc
	pop	ix
	ret	nz
; actual stream start
	lea	hl, ix+0
	call	.reset_poison
	cce	ge_vtx_transform
	call	vxVertexShader.ftransform_stream
	ccr	ge_vtx_transform
	xor	a, a
	ret
; .stream:
; 	cce	ge_vtx_transform
; 	ld	(.SP_RET), sp
; ; ix = cache, iy = source, ix = matrix, bc = size
; 	jr	.stream_return
; .stream_compute:
; ; 54 cycles can be saved here, (even a bit more in fact)
; 	ld	sp, vxVertexShader.stack
; 	call	vxVertexShader.ftransform_trampoline
; 	lea	ix, ix+VX_VERTEX_SIZE
; 	lea	iy, iy+VX_VERTEX_DATA_SIZE
; .stream_return:
; 	ld	a, (iy+VX_VERTEX_SIGN)
; ; 	cp	a, VX_ANIMATION_BONE
; ; 	jr	z, .stream_load_bone
; 	cp	a, VX_STREAM_END
; 	jr	nz, .stream_compute
; .stream_end:
; 	ccr	ge_vtx_transform
; .SP_RET=$+1
; 	ld	sp, $CCCCCC
; 	xor	a, a
; 	ret
; .stream_load_bone:
; ; more complex stuff here. Need to restore initial matrix & do a multiplication with the correct bone key matrix
; ; once done, only advance in the source, not the cache
; 	push	ix
; 	lea	iy, iy+VX_ANIMATION_HEADER_SIZE
; 	push	iy
; 	ld	ix, vxModelViewCache
; 	ld	e, (ix+vxAnimationKey-vxModelViewCache)
; 	ld	d, VX_ANIMATION_MATRIX_SIZE
; 	mlt	de
; 	add	iy, de	; correct animation matrix
; ; modelview = bonemodel*modelview
; 	ld	hl, vxModelView
; 	call	vxMatrixTransform	; (hl)=(iy)*(ix)
; ; I have the correct modelview matrix in shader cache area
; ; next one is reduced matrix without translation, since it will only be a direction vector mlt. However, the light vector position also need to be transformed by the transposed matrix
; 	call	vxVertexShader.uniform
; ; light = lightuniform*transpose(bonemodel*modelworld)
; 	ld	ix, vxModelWorld
; 	lea	hl, ix+VX_MATRIX_SIZE
; 	call	vxMatrixMlt
; 	lea	ix, ix+VX_MATRIX_SIZE
; 	call	vxMatrixTranspose
; 	ld	hl, vxLight
; 	ld	iy, vxLightUniform
; 	call	vxMatrixLightning
; 	pop	iy
; 	ld	e, (iy-1)
; 	ld	d, VX_ANIMATION_MATRIX_SIZE
; 	mlt	de
; 	add	iy, de
; 	pop	ix
; 	pop	bc
; 	jp	.stream_return
.bounding_box:
; check the bounding box
; stream the bounding box as standard vertex stream into the stream routine
; TODO : reset poison
	ld	ix, VX_PATCH_VERTEX_POOL
	lea	hl, ix+0
	ld	bc, 8
	call	.reset_poison
	cce	ge_vtx_transform
	call	vxVertexShader.ftransform_stream
	ccr	ge_vtx_transform
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
; z = inside / clip, nz = outside
	ret
.uniform:
	jp	(hl)
.reset_poison:
; hl - base adress, bc - vertex count
; TODO : optimize it
	ld      a, c
	dec     bc
	inc     b
	ld      c, b
	ld      b, a
	xor	a, a
	ld      de, VX_VERTEX_SIZE
.reset_kernel:
	ld      (hl), a
	add     hl, de
	djnz    .reset_kernel
	dec     c
	jr      nz, .reset_kernel
	ret
.set_poison:
	ld      a, c
	dec     bc
	inc     b
	ld      c, b
	ld      b, a
	ld	a, VX_VERTEX_POISON
	jr	.reset_kernel
