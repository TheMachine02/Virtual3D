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

define	VX_GEOMETRY_QUEUE		$D10000	; 4*4096 (16K)
define	VX_VERTEX_BUFFER		$D08000	; 16*2048 (32K)
define	VX_PRIMITIVE_SORT_CODE		$E30800
define	VX_MAX_TRIANGLE			4096
define	VX_MAX_VERTEX			2048
; poison bit to mark vertex as to be not transformed
; it should be reset if we should transform it
define	VX_VERTEX_POISON		1 shl VX_VERTEX_POISON_BIT
define	VX_VERTEX_POISON_BIT		0

virtual at -64
	VX_REGISTER_UE:		rb	1
	VX_REGISTER_VE:		rb	1
	VX_REGISTER_STARTPOINT:	rb	3
	VX_REGISTER_OFFSET:	rb	3
	VX_REGISTER_MIDPOINT:	rb	3
	VX_REGISTER_TMP:	rb	4
	VX_REGISTER_Y0:		rb	1
	VX_REGISTER_X0:		rb	2
	VX_REGISTER_U0:		rb	1
	VX_REGISTER_V0:		rb	1
	VX_REGISTER_Y1:		rb	1
	VX_REGISTER_X1:		rb	2
	VX_REGISTER_U1:		rb	1
	VX_REGISTER_V1:		rb	1
	VX_REGISTER_Y2:		rb	1
	VX_REGISTER_X2:		rb	2
	VX_REGISTER_U2:		rb	1
	VX_REGISTER_V2:		rb	1
	VX_REGISTER_AREG:	rb	1
	VX_REGISTER_BREG:	rb	1
	VX_FDVDY:		rb	2
	VX_FDUDY:		rb	4
	VX_FDVDX:		rb	2
	VX_FDUDX:		rb	4
end virtual

define	VX_PRIMITIVE_INTERPOLATION_SIZE	1024

 align 64
 rb	64
VX_GPR_REGISTER_DATA:
VX_REGISTER_DATA:
 db	2048	dup	$C3
 
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
vxLightUniform_t:
 dl	0,0,0
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
vxModelLight:
 db    0,0,0
 db    0,0
vxModelLight_t:
 dl    0,0,0
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
 db	69,0,0		; 69
 db	0,91,0		; 91
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
	ld	de, VX_VRAM
	ld	bc, VX_VRAM_SIZE
	ldir
; reset material state
	ld	a, -1
	ld	(VX_SHADER_STATE), a
.setup:
; check primitive count and reset it
	ld	hl, (vxPrimitiveQueueSize)
	ld	a, h
	or	a, l
	jr	z, .deferred_reset
	ld	iy, VX_GEOMETRY_QUEUE
	lea	de, iy+VX_GEOMETRY_ID
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	(hl), VX_STREAM_END
; note, bc should be zero here
	ld	(vxPrimitiveQueueSize), bc
	jr	.deferred_index
; TODO : reallocate .deferred into fast RAM, use jr .index as long jump
; TODO : remove the call vxPrimitiveRenderTriangle
.deferred:
	ld	e, (hl)
	inc	hl
	ld	bc, (hl)			; subcache
	ld	a, VX_MATERIAL_PIXEL_SHADER - 1
	add	a, l
	ld	l, a
	ld	ix, (hl)
VX_SHADER_STATE:=$+1
	ld	a, $CC
	cp	a, ixh
	call	nz, vxShader.load
.deferred_render:
	ld	a, e
	pea	iy+VX_GEOMETRY_KEY_SIZE
	ld	iy, (iy+VX_GEOMETRY_INDEX)	; read triangle data
	call	vxPrimitiveRender.triangle
	pop	iy
.deferred_index:
	ld	hl, VX_MATERIAL_DATA
	ld	l, (iy+VX_GEOMETRY_ID)
	ld	b, l
	djnz	.deferred
.deferred_reset:
	ld	a, $D0
	ld	mb, a
	jp	vxVertexCache.reset
	
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
; let's transform the vertex stream
.setup_matrix:
; vertex source have size at the begining
	push	bc
	push	de
	lea	hl, iy+0
	ld	de, vxModelWorldReverse
	ld	bc, VX_MATRIX_SIZE
	ldir	
; transform the worldview with the modelworld matrix to have the global modelview matrix
; modelview = modelworld0 * worldview0
	ld	hl, vxModelView
	call	vxMatrix.mlt4		; (hl) = (iy)*(ix)
; modelViewReverseTranslate = -modelViewTranslate * transpose(modelview)
; equivalent to eye position in modelspace
	ld	hl, vxModelView
	ld	de, vxModelViewReverse
	ld	bc, VX_MATRIX_SIZE
	ldir
	ld	iy, vxModelView
	ld	ix, vxProjectionMatrix
	ld	hl, vxModelView
	call	vxMatrix.mlt4
	ld	ix, vxModelViewReverse
	call	vxMatrix.transpose
	ld	iy, vxView_t
	lea	hl, ix+VX_MATRIX_TX
	lea	de, iy+0
	ld	bc, 9
	ldir
	ld	(ix+VX_MATRIX_TZ), bc
	ld	(ix+VX_MATRIX_TY), bc
	ld	(ix+VX_MATRIX_TX), bc
	call	vxMatrix.ftransform
	lea	ix, iy+0
	ld	iy, vxPosition
	call	vxMatrix.extend
.setup_lightning:
; modelworldreverse=transpose(modelworld)
	ld	ix, vxModelWorldReverse
	call	vxMatrix.transpose
; modellight=lightuniform*transpose(modelworld)
; transform the light vector by the transpose of modelworld matrix
	ld	hl, vxModelLight
	ld	iy, vxLightUniform
	call	vxVector.mlt3
	inc	hl
	inc	hl
	inc	hl
; copy the lightning parameter
	ld	de, (iy+VX_LIGHT_AMBIENT)
	ld	(hl), de
	ld	a, (iy+VX_LIGHT_PARAM)
	bit	VX_LIGHT_POINT_BIT, a
	jr	z, .setup_shader
.setup_lightning_world:
; transform the light position by the transpose of modelworld matrix (this give us the absolute position in model space), however we need to transform in back to 24.0 values
	ld	iy, vxLightUniform_t
	call	vxMatrix.ftransform
	ld	ix, vxModelLight_t
	ld	iy, vxPosition
	call	vxMatrix.extend
.setup_shader:
; load up shader data
	ld	ix, (vxPrimitiveMaterial)
	ld	hl, (ix+VX_MATERIAL_VERTEX_UNIFORM)
	call	.uniform
	pop	iy
; iy = source, ix = matrix
	ld	a, (iy+VX_STREAM_HEADER_OPTION)
; iy+0 are options, so check those. Here, only bounding box is interesting.
.setup_obb:
	lea	iy, iy+VX_STREAM_HEADER_SIZE
	and	a, VX_STREAM_HEADER_BBOX
	call	nz, .bounding_box
	jp	nz, .stream_cull
	cce	ge_vtx_transform
; actual stream start
	pop	ix
	call	.ftransform
	ccr	ge_vtx_transform
	pop	iy			; polygon list
	cce	ge_pri_assembly
; copy primitive assembly within fast area
	ld	hl, VX_PRIMITIVE_ASM_COPY
	ld	de, VX_VRAM
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
.stream_cull:
	ld	hl, 6
	add	hl, sp
	ld	sp, hl
	ret
.bounding_box:
; check the bounding box
; stream the bounding box as standard vertex stream into the stream routine
	cce	ge_vtx_transform
	ld	ix, VX_PATCH_VERTEX_POOL
; poison reset the vertex pool since we use the same vertex shader as stream
	xor	a, a
	ld	de, VX_VERTEX_SIZE
	lea	hl, ix+0
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	call	.ftransform
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
.ftransform:
	ld	hl, (vxPrimitiveMaterial)
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	hl, (hl)
.uniform:
	jp	(hl)

; vertex cache handling routine
vxVertexCache:

; .unpack:
; less than 96 cycles () > 147 cycles minimum
; ; de - base adress
; ; bc - vertex count
; ; hl - vertex stream
; 	ld	a, c
; 	dec	bc
; 	inc	b
; 	ld	c, b
; 	ld	b, a
; 	exx
; 	ld	(.SP_RET), sp
; 	ld	sp, VX_VERTEX_SIZE - 10
; .unpack_copy:
; 	exx
; 	ld	(hl), c
; 	inc	hl
; 	ld	c, 10
; 	ldir
; 	add	hl, sp
; 	exx
; 	djnz    .unpack_copy
; 	dec     c
; 	jr      nz, .unpack_copy
; .SP_RET:=$+1
; 	ld	sp, $CCCCCC
; 	ret

; vertex cache reset - one per frame
; reset all the vertex to untransformed state for mesh function and bfc optimisation
; write $FF if the vertex need to be transformed
; can be disabled in pipeline state (VIRTUAL_PIPELINE_STATE)
; about 14000 cycles, we need to save at least 8 vertex to be beneficial
.reset:
	ld	bc, .vram_cache_size
	ld	hl, .vram_cache
	ld	de, VX_VRAM_CACHE
	ldir
	xor	a, a
	ld	hl, VX_VERTEX_BUFFER
	ld	de, VX_VERTEX_SIZE
	jp	.reset_kernel
	
.vram_cache:
relocate VX_VRAM_CACHE
.reset_kernel:
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	ld	(hl), a
	add	hl, de
	djnz	.reset_kernel
	ret
.vram_cache_size:= $ - VX_VRAM_CACHE
end	relocate
