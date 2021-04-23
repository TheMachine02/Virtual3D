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

define	VX_REGISTER_US	-36-11
define	VX_REGISTER_VS	-36-10
define	VX_REGISTER_STARTPOINT -36-9
define	VX_REGISTER_OFFSET -36-6
define	VX_REGISTER_MIDPOINT -36-3
define	VX_REGISTER_TMP	-36+0
define	VX_REGISTER_Y0	-32+0
define	VX_REGISTER_X0	-32+1
define	VX_REGISTER_C0	-32+3
define	VX_REGISTER_U0	-32+4
define	VX_REGISTER_V0	-32+5
define	VX_REGISTER_Y1	-26+0
define	VX_REGISTER_X1	-26+1
define	VX_REGISTER_C1	-26+3
define	VX_REGISTER_U1	-26+4
define	VX_REGISTER_V1	-26+5
define	VX_REGISTER_Y2	-20+0
define	VX_REGISTER_X2	-20+1
define	VX_REGISTER_C2	-20+3
define	VX_REGISTER_U2	-20+4
define	VX_REGISTER_V2	-20+5

define	VX_FDVDY	-12
define	VX_FDUDY	-10
define	VX_FDVDX	-6
define	VX_FDUDX	-4

define	VX_PRIMITIVE_INTERPOLATION_CODE	$E30800
define	VX_PRIMITIVE_INTERPOLATION_SIZE	1024

 rb	64
VX_REGISTER_DATA:
 db	3072	dup	$D3

vxPrimitiveRender:

; the render target for a flat shaded triangle
.target_triangle_color:
	ld	ix, (iy+VX_TRIANGLE_I0)
	add	ix, bc
	ld	a, (ix+VX_VERTEX_GPR2)
	lea	hl, ix+0
	ld	ix, (iy+VX_TRIANGLE_I1)
	add	ix, bc
	add	a, (ix+VX_VERTEX_GPR2)
	lea	de, ix+0
	ld	ix, (iy+VX_TRIANGLE_I2)
	add	ix, bc
	add	a, (ix+VX_VERTEX_GPR2)
	ld	b, a
	ld	c, 86
	mlt	bc
	ld	a, b
	ld	bc, VX_LUT_CONVOLVE
	ld	c, (iy+VX_TRIANGLE_COLOR)
	ld	b, a
	ld	a, (bc)
	ld	(VX_PRIMITIVE_COLOR_RBG), a
	lea	bc, ix+0
	ld	a, (bc)
	or	a, (hl)
	ex	de, hl
	or	a, (hl)
	and	a, VX_CLIPPLANE_3D_MASK
	jr	z, .raster_triangle_color
.clip_triangle_color:
	ld	iy, VX_PATCH_INPUT
; I have actually switched hl and de previously
	ld	(iy+VX_PATCH_I0), de
	ld	(iy+VX_PATCH_I1), hl
	ld	(iy+VX_PATCH_I2), bc
	ld	(iy+VX_PATCH_I3), de
	ld	b, 3
	call	vxPrimitiveClipFrustrum
; fall through filling polygons
.raster_polygon_color:
; iy = point to a list of transformed vertex adress
;  b = number of point
; use global color VX_PRIMITIVE_COLOR_RBG
	dec	b
	dec	b
	ret	m
	ret	z
	ld	hl, (iy+VX_PATCH_I0)
.raster_color_loop:
	push	bc
	ld	de, (iy+VX_PATCH_I1)
	ld	bc, (iy+VX_PATCH_I2)
	push	hl
	pea	iy+VX_PATCH_INDEX_SIZE
	call	.raster_triangle_color
	pop	iy
	pop	hl
	pop	bc
	djnz	.raster_color_loop
	ret
.raster_triangle_color:
; hl = p0 adress
; de = p1 adress
; bc = p2 adress
; use global VX_COLOR_PRIMITIVE_RBG color
include "color.asm"

VX_PRIMITIVE_INTERPOLATION_COPY:=$
relocate VX_PRIMITIVE_INTERPOLATION_CODE

.target_triangle_gouraud:
; interpolated, no u&v unpack, unpack color
; this target could also be used if you want no uv, the pixel shader uniform color (c) will be set randomly in this case
; take iy as input, bc as vertex
	ld	hl, (iy+VX_TRIANGLE_I1)
	add	hl, bc
	ex	de, hl
	ld	hl, (iy+VX_TRIANGLE_I0)
	add	hl, bc
	ld	ix, (iy+VX_TRIANGLE_I2)
	add	ix, bc
	lea	bc, ix+0
	ld	a, (iy+VX_TRIANGLE_COLOR)
	ld	(vxShaderUniform0), a
	jr	.target_triangle_interpolate

; render triangle
; iy = triangle data (as stored in memory)
; bc = vertex cache adress
;  a = encoding format of triangle data
; nicely optimized for 3 points
; TODO : please optimise this with a truth jump table ?
.triangle:
; check if we need interpolation (VX_FORMAT_INTERPOLATION_MASK)
	rla
	jp	nc, .target_triangle_color
	rla
	jr	nc, .target_triangle_gouraud

.target_triangle_texture:
; take iy as input, bc as vertex
	lea	hl, iy+VX_TRIANGLE_UV0
	ld	ix, (iy+VX_TRIANGLE_I0)
	add	ix, bc
	push	ix
	lea	de, ix+VX_VERTEX_GPR0
	ldi
	ldi
	ld	a, (de)
	ld	ix, (iy+VX_TRIANGLE_I1)
	add	ix, bc
	lea	de, ix+VX_VERTEX_GPR0+2
	ldi
	ldi
	ex	de, hl
	add	a, (hl)
	ex	de, hl
	ld	iy, (iy+VX_TRIANGLE_I2)
	add	iy, bc
	lea	de, iy+VX_VERTEX_GPR0+4
	ldi
	ldi
	ex	de, hl
	add	a, (hl)
	ld	b, a
	ld	c, 86
	mlt	bc
	ld	a, b
	ld	(vxShaderUniform0+1), a
	lea	bc, iy+4
	lea	de, ix+2
	pop	hl

.target_triangle_interpolate:
	ld	a, (bc)
	or	a, (hl)
	ex	de, hl
	or	a, (hl)
	and	a, VX_CLIPPLANE_3D_MASK
	jr	z, .raster_triangle_interpolate
.clip_triangle_interpolate:
	ld	iy, VX_PATCH_INPUT
	ld	(iy+VX_PATCH_I0), de
	ld	(iy+VX_PATCH_I1), hl
	ld	(iy+VX_PATCH_I2), bc
; make patch cyclic
	ld	(iy+VX_PATCH_I3), de
	ld	b, 3
	call	vxPrimitiveClipFrustrum
.raster_polygon_interpolate:
; iy : point to a list of transformed vertex adress
;  b : number of point
	dec	b
	dec	b
	ret	m
	ret	z
	ld	hl, (iy+VX_PATCH_I0)
.raster_interpolate_loop:
	push	bc
	ld	de, (iy+VX_PATCH_I1)
	ld	bc, (iy+VX_PATCH_I2)
	push	hl
	pea	iy+VX_PATCH_INDEX_SIZE
	call	.raster_triangle_interpolate
	pop	iy
	pop	hl
	pop	bc
	djnz	.raster_interpolate_loop
	ret
.raster_triangle_interpolate:
; hl = p0 adress
; de = p1 adress
; bc = p2 adress
include "texture.asm"

assert $ < $E30C01
end relocate

include "clip.asm"

; polygons
; vxPrimitiveRenderPolygon:
; ; iy = polygon data (as stored in memory) (index, data)
; ; bc = vertex cache adress
; ;  a = encoding format of triangle data
; ;  d = point count
; 	bit	7, a		; VX_FORMAT_INTERPOLATION_MASK
; 	jp	z, _inner_renderPolygonColor
; _inner_renderPolygonTexture:
; 	ret
; _inner_renderPolygonColor:
; 	ld	ix, VX_PATCH_INPUT
; 	xor	a, a
; 	ld	e, d
; _inner_cacheCompute:
; 	ld	hl, (iy+VX_POLYGON_I0)
; 	add	hl, bc
; 	ld	(ix+VX_POLYGON_I0), hl
; 	or	a, (hl)
; 	lea	iy, iy+3
; 	lea	ix, ix+3
; 	dec	d
; 	jr	nz, _inner_uniformCompute
; 	ld	iy, VX_PATCH_INPUT
; ; make input cyclic
; 	ld	hl, (iy+VX_POLYGON_I0)
; 	ld	(ix+VX_POLYGON_I0), hl
; 	inc.s	bc	; reset bcu
; 	ld	b, e
; 	ld	c, b
; 	or	a, a
; 	push	af
; 	sbc	hl, hl
; 	ex	de, hl
; 	sbc	hl, hl
; _inner_uniformCompute:
; 	ld	ix, (iy+VX_POLYGON_I0)
; 	ld	e, (ix+VX_VERTEX_GPR2)
; 	add	hl, de
; 	lea	iy, iy+3
; 	djnz	_inner_uniformCompute
; ; hl div c here
; 	xor	a, a
; 	add	hl, hl
; 	sbc	hl, bc
; 	jr	nc, $+3
; 	add	hl, bc
; 	adc	a, a
; 	add	hl, hl
; 	sbc	hl, bc
; 	jr	nc, $+3
; 	add	hl, bc
; 	adc	a, a
; 	add	hl, hl
; 	sbc	hl, bc
; 	jr	nc, $+3
; 	add	hl, bc
; 	adc	a, a
; 	add	hl, hl
; 	sbc	hl, bc
; 	jr	nc, $+3
; 	add	hl, bc
; 	adc	a, a
; 	add	hl, hl
; 	sbc	hl, bc
; 	jr	nc, $+3
; 	add	hl, bc
; 	adc	a, a
; 	add	hl, hl
; 	sbc	hl, bc
; 	jr	nc, $+3
; 	add	hl, bc
; 	adc	a, a
; 	add	hl, hl
; 	sbc	hl, bc
; 	jr	nc, $+3
; 	add	hl, bc
; 	adc	a, a
; 	add	hl, hl
; 	sbc	hl, bc
; 	adc	a, a
; 	cpl
; 	ld	de, VX_LUT_CONVOLVE
; 	ld	e, (iy+0)
; 	ld	d, a
; 	ld	a, (de)
; 	ld	(VX_PRIMITIVE_COLOR_RBG), a
; 	ld	b, c
; 	pop	af
; 	ld	iy, VX_PATCH_INPUT
; 	jp	nz, _inner_clipdrawColorPolygon
; 	jp	vxPrimitiveFillPolygon
