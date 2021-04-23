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

; TODO : create geometry shader in submission
; Better vertex shader with decoupled projection
; Put all the code in fast ram, use sha256

VIRTUAL_PIPELINE_STATE:
; pipeline state
vxPrimitiveQueue:
 dl	0
vxGeometrySize:
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
vxTModelWorld:
 db	0,0,0
 db	0,0,0
 db	0,0,0
vxTModelWorld_t:
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
vxProjectionMatrix:
 db	48,0,0
 db	0,64,0
 db	0,0,64
vxProjectionMatrix_t:
 dl	0,0,0
 
vxPrimitiveSubmit:
.reset:
; various reset blahblah
	ld	hl, (VX_LCD_BUFFER)
	ld	(vxPrimitiveQueue), hl
	ld	hl, VIRTUAL_NULL_RAM
	ld	de, VX_DEPTH_BUCKET_L
	ld	bc, 256 * 6
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
	ld	hl, (vxGeometrySize)
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
	ld	(vxGeometrySize), bc
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
	call	vxVertexCache.setup		; stream vertex data to cache
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

vxVertexCache:
; de - vertex source, bc - vertex cache, ix worldview0 matrix, iy modelworld0 matrix (should be an model matrix)
; hl is the vertex shader program
; NOTE : expect material to be set
; vertex source have size at the begining
; support animation
.setup:
	push	bc
	push	de
; load shader first
	ld	de, VX_VERTEX_SHADER_CODE
	ld	bc, VX_VERTEX_SHADER_SIZE
	ldir
	ld	hl, vxVertexShader.iterate
	ld	de, VX_VRAM_CACHE
	ld	c, VX_VRAM_CACHE_SIZE
	ldir	
; transform the worldview with the modelworld matrix to have the global modelview matrix
; modelviewcache = modelworld0 * worldview0
	ld	hl, vxModelViewCache
	call	vxMatrixTransform		; (hl) = (iy)*(ix)
; modelview=modelviewcache
	ld	de, vxModelView
	ld	bc, VX_MATRIX_SIZE
	ldir
; modelViewReverseTranslate = -modelViewTranslate * transpose(modelview)
; equivalent to eye position in modelspace
	push	iy
	ld	hl, vxModelView
	ld	de, vxModelViewReverse
	ld	bc, VX_MATRIX_SIZE
	ldir
	ld	ix, vxModelViewReverse
	ld	iy, vxView_t
	call	vxMatrixTranspose
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
	ld	iy, vxModelView
	ld	ix, vxProjectionMatrix
	ld	hl, vxModelView
	call	vxMatrixTransform
;	ld	iy, vxModelView
;	ld	hl, vxModelView
;	call	vxfMatrixPerspective
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
	ld	ix, VX_PATCH_VERTEX_POOL
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
.reset:
; hl - base adress, bc - vertex count
	ld	a, c
	dec	bc
	inc	b
	ld	c, b
	ld	b, a
	ld	a, VX_VERTEX_RESET
	ld	de, VX_VERTEX_SIZE
.reset_loop:
	ld	(hl), a
	add	hl, de
	djnz	.reset_loop
	dec	c
	jr	nz, .reset_loop
	ret
	
; set the depth offset of the current primitive stream
vxPrimitiveDepthOffset:
	ld	de, VX_DEPTH_OFFSET
	add	hl, de
	ld	(vxPrimitiveDepth), hl
	ret

vxPrimitiveDepthSort:
; 311 cycles per triangle with an added constant ~34000 cycles
; sorting a full queue take less than 27 ms
	cce	ge_z_sort
	ld	hl, VX_PRIMITIVE_SORT_COPY
	ld	de, VX_PRIMITIVE_SORT_CODE
	ld	bc, VX_PRIMITIVE_SORT_SIZE
	ldir
	ld	hl, .restore_rel
	ld	de, VX_VRAM_CACHE
	ld	bc, .restore_rel_size
	ldir
	ld	bc, (vxGeometrySize)
	ld	a, b
	or	a, c
	call	nz, .helper
	ccr	ge_z_sort
	ret

; sort table, target temporary buffer based on current framebuffer
; we need two 6*4096 bytes buffer aligned within 64K. Both buffer need to be aligned and not cross boundary
; framebuffer : $D40000
;	- tmp 0 : $D40000
;	- tmp 1 : $D46000
; framebuffer : $D52C00
; 	- tmp 0 : $D52C00
;	- tmp 1 : $D58C00
	
VX_PRIMITIVE_SORT_COPY:=$
; relocate to fast RAM
relocate VX_PRIMITIVE_SORT_CODE

.helper:
; sort the current submission queue
	ld	(.SP_RET), sp
.setup:
; fetch the high byte of the current framebuffer and build up the VRAM temporary area
	ld	ix, .sort
	ld	hl, (vxFramebuffer)
	ld	(ix+.WBL -.sort), hl
	ld	(ix+.WBLH-.sort), h
	ld	(ix+.WBLL-.sort), l
	ld	de, VX_MAX_TRIANGLE*VX_GEOMETRY_SIZE
	add	hl, de
	ld	(ix+.WBH -.sort), hl
	ld	(ix+.WBHH-.sort), h
	ld	(ix+.WBHL-.sort), l
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	ld	(ix+.RBH -.sort), hl
	sbc	hl, de
	ld	(ix+.RBL -.sort), hl
; size computation
	ld	a, c
	dec	bc
	inc	b
	ld	c, b
	ld	b, a
	ld	(ix+.SZ0 -.sort), bc
	ld	(ix+.SZ1 -.sort), bc
	ld	(ix+.SZ2 -.sort), bc
; actual sorting start here
; restore index position in array for all three bucket
.restore_bucket_l:
	ld	hl, VX_DEPTH_BUCKET_L + 511
	ld	a, (hl)
.WBLH:=$+1
	add	a, $CC
	ld	d, a
	ld	(hl), a
	dec	h
	ld	a, (hl)
.WBLL:=$+1
	add	a, $CC
	ld	e, a
	ld	(hl), a
	call	.restore_bucket
; high bucket
.restore_bucket_h:
	ld	hl, VX_DEPTH_BUCKET_H + 511
	ld	a, (hl)
.WBHH:=$+1
	add	a, $CC
	ld	d, a
	ld	(hl), a
	dec	h
	ld	a, (hl)
.WBHL:=$+1
	add	a, $CC
	ld	e, a
	ld	(hl), a
	call	.restore_bucket
; upper bucket
.restore_bucket_u:
	ld	hl, VX_DEPTH_BUCKET_U + 511
	ld	d, (hl)
	dec	h
	ld	e, (hl)
	call	.restore_bucket
.sort:
; sorting now, backward
; set sp as stride, we'll use hl' as return adress within the jump
	ld	sp, -3
.sort_bucket_l:
.SZ0:=$+1
	ld	bc, $CCCCCC
.WBL:=$+1
	ld	de, $CCCCCC
	ld	ix, (vxPrimitiveQueue)
	ld	hl, VX_DEPTH_BUCKET_L
	exx
	ld	hl, .sort_bucket_h
	exx
	jp	.sort_bucket
.sort_bucket_h:
	ld	hl, .sort_bucket_u
	exx
.SZ1:=$+1
	ld	bc, $CCCCCC
; we have sort on the low key, now sort on the high key
;	ld	a, VX_GEOMETRY_DEPTH + 1
; load iyh instead of iyl
	ld	a, $7C
	ld	(.DOF), a
.WBH:=$+1
	ld	de, $CCCCCC
.RBL:=$+2
	ld	ix, $CCCCCC
; load up VX_DEPTH_BUCKET_H
	inc	h
	inc	h
	jp	.sort_bucket
.sort_bucket_u:
; copying take ~250 cycles, so we need to sort >10 triangles to be better than not copying. In practise, this is always true.
	ld	hl, .sort_bucket_rw_overwrite
	ld	de, .sort_bucket_overwrite
	ld	bc, VX_VRAM_CACHE_SIZE shr 1
	ldir
	exx
; finish by the sorting the upper key, and storing partial result within the geometry queue
.SZ2:=$+1
	ld	bc, $CCCCCC
	ld	de, VX_GEOMETRY_QUEUE
.RBH:=$+2
	ld	ix, $CCCCCC
; load up VX_DEPTH_BUCKET_U
	inc	h
	inc	h
	jp	.sort_bucket
.sort_bucket_rw:
	lea	ix, ix-VX_GEOMETRY_SIZE
.sort_bucket_rw_overwrite:
	ld	l, (ix+VX_GEOMETRY_DEPTH+2)
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	dec	de
	ex	de, hl
; copy 4 (VX_GEOMETRY_KEY_SIZE) bytes
	ld	a, (ix+VX_GEOMETRY_ID)
	ld	(hl), a
	add	hl, sp
	ld	iy, (ix+VX_GEOMETRY_INDEX)
	ld	(hl), iy
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	djnz	.sort_bucket_rw
	dec	c
	jr	nz, .sort_bucket_rw
.SP_RET:=$+1
	ld	sp, $CCCCCC
	ret

VX_PRIMITIVE_SORT_SIZE:= $ - VX_PRIMITIVE_SORT_CODE
end relocate

.restore_rel:
relocate VX_VRAM_CACHE
.restore_bucket:
	dec	l
.restore_add:
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
	jr	nz, .restore_add
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	ret
.sort_bucket:
	lea	ix, ix-VX_GEOMETRY_SIZE
.sort_bucket_overwrite:
	ld	iy, (ix+VX_GEOMETRY_DEPTH)
.DOF:=$+1
	ld	a, iyl
	ld	l, a
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	ex	de, hl
	add	hl, sp
	ld	(hl), iy
	add	hl, sp
	ld	iy, (ix+VX_GEOMETRY_INDEX)
	ld	(hl), iy
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	djnz	.sort_bucket
	dec	c
	jr	nz, .sort_bucket
	exx
	jp	(hl)
.restore_rel_size:= $ - VX_VRAM_CACHE
assert .restore_rel_size <= VX_VRAM_CACHE_SIZE
end relocate
