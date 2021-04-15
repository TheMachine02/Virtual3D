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

vxPrimitiveMesh:
; send a mesh for submit
; support animated format
; hl : vertex source
;  a : material ID
; de : triangle source
; ix : worldview matrix
; iy : modelworld matrix
;  c : animation key
	ret


vxPrimitiveMeshPrepass:
; backface culling pass
; MULTIPLE PASS ON MULTIPLE STREAM
; reset all vertex belonging to the mesh within cache with special (untransformed) value
; it should be within X value (only area free)
; compute bone - eyeworld then stream each patch of vertex stream while loading each bone & eye world uniform
	ld	ix, VX_GEOMETRY_QUEUE
.prepass:
	ld	hl, i
	ld	l, (iy+VX_TRIANGLE_N0)
	ld	de, (hl)
; fetch VX_VIEW_MLTY
	inc	h
	ld	l, (iy+VX_TRIANGLE_N1)
	ld	bc, (hl)
; fetch VX_VIEW_MLTZ
	inc	h
	ld	l, (iy+VX_TRIANGLE_N2)
	ld	hl, (hl)
	add	hl, bc
	add	hl, de
	ld	de, (iy+VX_TRIANGLE_N3)
	add	hl, de
	add	hl, hl
	jr	nc, .discard
	ld	hl, (iy+VX_TRIANGLE_I1)
	add	hl, sp
	set	7, (hl)
	ld	hl, (iy+VX_TRIANGLE_I1)
	add	hl, sp
	set	7, (hl)
	ld	hl, (iy+VX_TRIANGLE_I1)
	add	hl, sp
	set	7, (hl)
	ld	(ix+0), iy
	lea	ix, ix+4
.discard:
.STR:=$+2
	lea	iy, iy+$1C
	ld	l, (iy+VX_TRIANGLE_I0)
	bit	0, l
	jr	z, .prepass
	ret
	
vxPrimitiveMeshAssembly:
; special assembly, only take care of frustrum cull & sorting
; read only from geometry_queued by the previous works ?
; single pass
; setup the various SMC
; geometry format STR
; geometry material MTR
; also set the geometry depth offset here
	ld	hl, (vxPrimitiveDepth)
	ld	(.DEO), hl
	ld	hl, (vxPrimitiveMaterial)
	ld	ix, (vxPrimitiveQueue)
	ld	a, (hl)
	and	a, VX_FORMAT_STRIDE
	ld	(.STR), a
	ld	a, l
	ld	(.MTR), a
	inc	hl
; this is the VBO
	ld	bc, (hl)
; preload the first value, it is used as stream end mark
	ld	hl, (iy+VX_TRIANGLE_I0)
	bit	0, l
	ret	nz
	ld	(.SP_RET0), sp
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
	add	hl, hl
	add	hl, hl
.DEO=$+1
	ld	de, VX_DEPTH_OFFSET
	add	hl, de
; we'll also set the depth into de
	ex	de, hl
.MTR:=$+1
	ld	hl, VX_DEPTH_BUCKET_L or $CC
	ld	e, l
; write both the ID in the lower 8 bits and the depth in the upper 16 bits, we'll sort on the full 24 bit pair so similar material will be 'packed' together at best without breaking sorting
	ld	(ix+VX_GEOMETRY_DEPTH), de
	ld	a, (hl)
	add	a, VX_GEOMETRY_SIZE
	ld	(hl), a
	inc	h
	jr	nc, .overflow_l
	inc	(hl)
.overflow_l:
	inc	h
	ld	l, d
	ld	a, (hl)
	add	a, VX_GEOMETRY_SIZE
	ld	(hl), a
	inc	h
	jr	nc, .overflow_h
	inc	(hl)
.overflow_h:
	inc	h
; we can't acess deu quickly here, so do a slow read
	ld	l, (ix+VX_GEOMETRY_DEPTH+2)
	ld	a, (hl)
	add	a, VX_GEOMETRY_KEY_SIZE
	ld	(hl), a
	jr	nc, .overflow_u
	inc	h
	inc	(hl)
.overflow_u:
	ld	(ix+VX_GEOMETRY_INDEX), iy
	lea	ix, ix+VX_GEOMETRY_SIZE
.discard:
.STR:=$+2
	lea	iy, iy+$1C
	ld	hl, (iy+VX_TRIANGLE_I0)
	bit	0, l
	jr	z, .pack
.SP_RET0:=$+1
	ld	sp, $CCCCCC
	ret
