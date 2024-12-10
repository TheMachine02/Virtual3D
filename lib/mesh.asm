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


; mesh have a special format and are optimized to be partially / on screen
; they should be small with many triangles and possibly bones or animation
; backface culling is performed BEFORE per-triangle frustrum culling for them and vertex are only transformed for non - rejected backface culling face
; because the mesh have 50% triangle backward with high density, it should be beneficial to do, especially since there shouldn't be many frustrum culled triangle within the mesh (mesh should be culled by the bounding box, much more efficiently)
; also enable contribution culling within mesh (if the face is estimated to have an area < 1 cull it, it allow to not assemble & clip & render useless triangle)

; mesh format :
; db option
; db bone_count
; dl vertex_stream, triangle_stream

vxMeshTransform:
; send a mesh for submission
; support animated format
; hl : mesh source
;  a : material ID
; ix : worldview matrix
; iy : modelworld matrix
;  c : animation key
	ld	(.BASE_MESH), hl
	ex	de, hl
	ld	hl, VX_MATERIAL_DATA
	ld	l, a
	ld	(vxPrimitiveMaterial), hl
	ld	a, c
	ld	(vxAnimationKey), a
	inc	hl
	ld	bc, (hl)
	ex	de, hl
	inc	hl
	ld	a, (hl)
	inc	hl
.mesh_transform_bone:
	push	af
	push	ix
	push	iy
	push	hl
	ld	de, (hl)
	inc	hl
	inc	hl
	inc	hl
	ld	hl, (hl)
	push	bc
.BASE_MESH:=$+1
	ld	bc, $CCCCCC
	add	hl, bc
	ex	de, hl
	add	hl, bc
	pop	bc
	call	vxMeshStream
	pop	hl
	ld	de, 6
	add	hl, de
	pop	iy
	pop	ix
	pop	af
	dec	a
	jr	nz, .mesh_transform_bone
	ret

vxMeshStream:
; send a primitive stream for submission
; handle calling the vertex shader & 
; hl : vertex source
; de : triangle source
; bc : vertex adress
; ix : worldview matrix
; iy : modelworld matrix
; return : bc is the new vertex source for consecutive stream
	push	de
	push	bc
	push	hl
; let's transform the vertex stream
.setup_matrix:
; load up the model view matrix accordingly
; get bonemodel matrix
.setup_bonemodel:
	ld	a, (vxAnimationKey)
	ld	d, a
	ld	e, VX_ANIMATION_MATRIX_SIZE
	mlt	de
	add	hl, de
; increment by the size of the stream option
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	push	ix
	lea	ix, iy+0
	ld	iy, 0
	ex	de, hl
	add	iy, de
	ld	hl, vxModelWorld
	call	vxMatrix.mlt4
	pop	ix
	ld	iy, vxModelWorld
.setup_matrix_worldview:
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
; only copy the 2 first row since that what we'll need for screenspace mapping
	ld	hl, vxModelView
	ld	de, vxModelViewScreenSpace
	ld	bc, 6
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
; iy+0 are options, so check those. Here, only bounding box is interesting. Advance in the vertex stream by count of matrix * size of matrix + 1
.setup_option:
	lea	iy, iy+VX_STREAM_HEADER_SIZE
	ld	e, (iy+VX_ANIMATION_MATRIX_COUNT)
	ld	d, VX_ANIMATION_MATRIX_SIZE
	mlt	de
	add	iy, de
	inc	iy
	tst	a, VX_STREAM_OPTION_AABB
	call	nz, .bounding_box
	jp	nz, .stream_cull
	cce	ge_vtx_transform
; actual stream start
	pop	ix
	call	.ftransform
	ccr	ge_vtx_transform
; save ix here for actual data sourcing
	ex	(sp), ix
	lea	iy, ix+0
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
	pop	bc
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
	
; very interesting for mesh, but hard to optimise
vxNClip:
; we'll compute (y2-y1)*(x0-x1) - (y0-y1)*(x2-x1)
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
	
	
; 	
; 
; .backface_setup:
; ; input : iy = stream, also expect so global variable to be correctly set
; 	lea	iy, iy+VX_STREAM_HEADER_SIZE
; ; lut setup
; .mlt_generate:
; ; now the view vector
; ; we'll need to generate actual LUT table for bc * a (signed)
; ; bc is know is advance, but we have 3 table for -64 to 64
; 	ld	de, (vxView_t)
; 	ld	hl, VX_VIEW_MLTX + VX_VIEW_MLT_OFFSET - 1
; 	call	.view_mlt
; 	ld	de, (vxView_t+3)
; 	ld	hl, VX_VIEW_MLTY + VX_VIEW_MLT_OFFSET - 1
; 	call	.view_mlt
; 	ld	de, (vxView_t+6)
; 	ld	hl, VX_VIEW_MLTZ + VX_VIEW_MLT_OFFSET - 1
; 	call	.view_mlt
; ; preload the first value, it is used as stream end mark
; 	ld	de, (iy+VX_TRIANGLE_I0)
; 	dec	e
; 	ret	z
; 	ld	hl, VX_VIEW_MLTX
; 	ld	i, hl
; ; setup the various SMC
; ; geometry format STR
; ; geometry material MTR
; ; also set the geometry depth offset here
; 	ld	hl, (vxPrimitiveMaterial)
; 	ld	a, (hl)
; 	and	a, VX_FORMAT_STRIDE
; 	ld	(.STR), a
; 	inc	hl
; ; this is the VBO
; 	ld	(.SP_RET0), sp
; 	ld	hl, (hl)
; 	ld	sp, hl
; 	ex	de, hl
; 	xor	a, a
; .backface_cull:
; 	inc	l
; 	add	hl, sp
; 	exx
; ; switch to shadow for the bfc
; 	ld	hl, i
; ; between -31 and 31 pre multiplied by 4
; 	ld	l, (iy+VX_TRIANGLE_N0)
; 	ld	de, (hl)
; ; fetch VX_VIEW_MLTY
; 	inc	h
; 	ld	l, (iy+VX_TRIANGLE_N1)
; 	ld	bc, (hl)
; ; fetch VX_VIEW_MLTZ
; 	inc	h
; 	ld	l, (iy+VX_TRIANGLE_N2)
; 	ld	hl, (hl)
; 	add	hl, bc
; 	add	hl, de
; 	ld	de, (iy+VX_TRIANGLE_N3)
; 	add	hl, de
; 	add	hl, hl
; 	exx
; 	jr	nc, .discard
; 	ld	(hl), a
; 	ld	hl, (iy+VX_TRIANGLE_I1)
; 	add	hl, sp
; 	ld	(hl), a
; 	ld	hl, (iy+VX_TRIANGLE_I2)
; 	add	hl, sp
; 	ld	(hl), a
; .discard:
; .STR:=$+2
; 	lea	iy, iy+$1C
; 	ld	hl, (iy+VX_TRIANGLE_I0)
; 	dec	l
; 	jr	nz, .backface_cull
; 	
; 	
; 	
; 	add	hl, bc
; 	ld	hl, (hl)
; 	add	hl, de
; ; NOTE : we already have a x3 factor here, so actual scaling to get the two precision bit of 16 + 2.6 or extra bit of 16 + 1.7 isn't truly needed
; .DEO=$+1
; 	ld	de, VX_DEPTH_OFFSET
; 	add	hl, de
; ; we'll also set the depth into de
; 	ex	de, hl
; .MTR:=$+1
; 	ld	hl, VX_DEPTH_BUCKET_H or $CC
; 	ld	e, l
; ; write both the ID in the lower 8 bits and the depth in the upper 16 bits, we'll sort on the full 24 bit pair so similar material will be 'packed' together at best without breaking sorting
; 	ld	(ix+VX_GEOMETRY_DEPTH), de
; 	ld	l, d
; 	ld	a, (hl)
; 	add	a, VX_GEOMETRY_SIZE
; 	ld	(hl), a
; 	inc	h
; 	jr	c, .overflow_h
; .continue_h:
; 	inc	h
; ; we can't acess deu quickly here, so do a slow read
; 	ld	l, (ix+VX_GEOMETRY_DEPTH+2)
; 	ld	a, (hl)
; 	add	a, VX_GEOMETRY_KEY_SIZE
; 	ld	(hl), a
; 	jr	c, .overflow_u
; .continue_u:
; 	ld	(ix+VX_GEOMETRY_INDEX), iy
; 	lea	ix, ix+VX_GEOMETRY_SIZE
; .discard:
; .STR:=$+2
; 	lea	iy, iy+$1C
; 	ld	hl, (iy+VX_TRIANGLE_I0)
; 	dec	l
; 	jr	nz, .pack
