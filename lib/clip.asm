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

define	VX_PLANE_BIT0		10000000b	; vertical right edge (x=320)
define	VX_PLANE_BIT1		01000000b	; vertical left edge (x=0)
define	VX_PLANE_BIT2		00100000b	; horizontal upper edge (y=0)
define	VX_PLANE_BIT3		00010000b	; horizontal lower edge (y=240)
define 	VX_MAX_PATCH_VERTEX    	8		; number of newly created vertex
define 	VX_MAX_PATCH_SIZE	16		; number of vertex per patch at max

define	VX_CLIPPLANE_3D_MASK	11110000b
define	VX_CLIPPLANE_2D_MASK	00001111b

define	VX_PATCH_I0		0
define	VX_PATCH_I1		4
define	VX_PATCH_I2		8
define	VX_PATCH_I3		12
define	VX_PATCH_INDEX_SIZE	4

vxPatchVertexCache:
 dl	0
VX_PATCH_VERTEX:
 dl	0,0,0,0,0,0

if defined VX_DEBUG_CC_INSTRUCTION
vxPrimitiveClipFrustrum:
	cce	ge_pri_clip
	call	.inner
	ccr	ge_pri_clip 
	ret
.inner:
else
vxPrimitiveClipFrustrum:
end if
; input ;
; iy : patch_input (VX_PATCH_INPUT), point to a list of address of vertex
;  b : number of point
; output ;
; iy : clipped patch (take this address only and not INPUT or OUTPUT)
;  b : number of point
	ld	ix, VX_PATCH_OUTPUT
	ld	hl, VX_PATCH_VERTEX_POOL
	ld	(vxPatchVertexCache), hl
	rla
	jr	nc, .nextPlane0
	ex	af, af'
	xor 	a, a
	cp	a, b
	ld	c, VX_PLANE_BIT0
	call	nz, vxPrimitiveClipPlane
	ex	af, af'
.nextPlane0:
	rla
	jr	nc, .nextPlane1
	ex	af, af'
	xor 	a, a
	cp	a, b
	ld	c, VX_PLANE_BIT1
	call	nz, vxPrimitiveClipPlane
	ex	af, af'
.nextPlane1:
	rla
	jr	nc, .nextPlane2
	ex	af, af'
	xor 	a, a
	cp	a, b
	ld	c, VX_PLANE_BIT2
	call	nz, vxPrimitiveClipPlane
	ex	af, af'
.nextPlane2:
	rla
	ret	nc
	xor 	a, a
	cp	a, b
	ret	z
	ld	c, VX_PLANE_BIT3
; fall trough ;

vxPrimitiveClipPlane:
; input ;
; iy : patch_input (VX_PATCH_INPUT), point to a list of address of vertex
;  b : number of point
;  a : mask
; output ;
; iy : clipped patch (VX_PATCH_OUPUT)
;  b : number of point
	push	iy
	push	ix
; b : count, c : planemask
.clipSutherHodgmanLoop:
	ld	hl, (iy+VX_PATCH_I1)
	ld	de, (iy+VX_PATCH_I0)
	ld	a, (de)
	and	a, (hl)
	and	a, c
	jr	nz, .noEdge
	ld	a, (de)
	or	a, (hl)
	and	a, c
	jr	nz, .clipEdge
	ld	(ix+VX_PATCH_I0), de
.incEdge:
	lea	ix, ix+VX_PATCH_INDEX_SIZE
.noEdge:
	lea	iy, iy+VX_PATCH_INDEX_SIZE
	djnz	.clipSutherHodgmanLoop
	pop	iy
	ld	hl, (iy+VX_PATCH_I0)
	ld	(ix+VX_PATCH_I0), hl
	lea	hl, ix+0
	lea	bc, iy+0
	or	a, a
	sbc	hl, bc
	ld	a, l
	rrca
	rrca
	ld	b, a
	pop	ix
	ret
; all works is here ;
.clipEdge:
	push	bc
	ld	a, (de)
	and	a, c
	push	af
; compute distance based of mask a
	ld	a, c
	tst	a, 11000000b
; nz = vertical
	jp	nz, .clipVerticalPlane
.clipHorizontalPlane:
	ld	bc, VX_VERTEX_RY
	add	hl, bc
	ld	bc, (hl)
	inc	hl
	inc	hl
	inc	hl
	ld	hl, (hl)
	sbc	hl, bc
	tst	a, 00100000b
	jr	nz, .hinv0
	add	hl, bc
	add	hl, bc
.hinv0:
	ex	de, hl
	ld	bc, VX_VERTEX_RY
	add	hl, bc
	ld	bc, (hl)
	inc	hl
	inc	hl
	inc	hl
	ld	hl, (hl)
	sbc	hl, bc
	tst	a, 00100000b
	jr	nz, .hinv1
	add	hl, bc
	add	hl, bc
.hinv1:
; parametric compute for horizontal plane ;
.parametricHCompute:
	push	ix
	push	iy
; save plane mask for later
	push	af
	call	vxParametric.factor
	ld	ix, (iy+VX_PATCH_I0)
	ld	iy, (iy+VX_PATCH_I1)
; ix = iy+0 (p0) , iy = iy+3 (p1)
; compute (p1-p0)*t+p0, for 24 bits vertex
; t = bc, p0 = ix, p1 = iy, output = clip_vertex0
; vertex coordinate rx
	ld	hl, (iy+VX_VERTEX_RX)
	ld	de, (ix+VX_VERTEX_RX)
	call	vxParametric.mlt
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RX), hl
; vertex coordinate rz
	ld	hl, (iy+VX_VERTEX_RZ)
	ld	de, (ix+VX_VERTEX_RZ)
	call	vxParametric.mlt
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RZ), hl
; vertex coordinate ry
	pop	af
	and	a, 00100000b
	ld	a, VX_SCREEN_HEIGHT_CENTER-(VX_SCREEN_HEIGHT/2)
	jr	nz, .HNeg
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ld	a, VX_SCREEN_HEIGHT_CENTER+(VX_SCREEN_HEIGHT/2)
.HNeg:
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RY), hl
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SY), a
	push	bc
	ld	hl, (VX_PATCH_VERTEX+VX_VERTEX_RX)
	ld	bc, (VX_PATCH_VERTEX+VX_VERTEX_RZ)
.parametricDivide1:
	xor	a, a
	add	hl, hl
	jr	nc, $+9
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
	sbc	hl, bc
	jr	c, .nextcarry1
	sbc	hl, bc
	jr	nc, .equal1
	or	a, a
.nextcarry1:
	adc	a, a
	add	hl, bc
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	adc	a, a
	cpl
	ld	l, a
	ld	h, VX_SCREEN_WIDTH shr 1
	mlt	hl
	ld	a, h
	sbc	hl, hl
	jr	nc, $+3
	cpl
	ld	l, a
	ld	de, VX_SCREEN_WIDTH_CENTER
	adc	hl, de
	jr	.writex
.equal1:
	rra
	ld	hl, $000140	;=VX_SCREEN_WIDTH_CENTER+(VX_SCREEN_WIDTH/2)
	jr	nc, .writex
	dec	h
	ld	l, h	;=VX_SCREEN_WIDTH_CENTER-(VX_SCREEN_WIDTH/2)
.writex:
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SX), hl
	xor	a, a
; common compute ;
.parametricCCompute:
	ld	(VX_PATCH_VERTEX+VX_VERTEX_CODE), a
; now, other vertex parameters
	pop	bc
	ld	hl, VX_PATCH_VERTEX + VX_VERTEX_GPR0
; parameter 0
	ld	a, (iy+VX_VERTEX_GPR0)	; a = p1
	ld	d, (ix+VX_VERTEX_GPR0)	; d = p0
	sub	a, d			; a = p1-p0
	ld	e, a			; e = p1-p0
	ld	a, d			; a = p0
	jr	nc, $+3			; sign correction
	sub	a, b			;
	ld	d, b			;
	mlt	de			; de = (unsigned)(p1-p0)*b
	add	a, d			; a = (signed)(p1-p0)*b/256+p0
	ld	(hl), a			; and write result
	inc	hl			; next parameter
; parameter 1
	ld	a, (iy+VX_VERTEX_GPR1)
	ld	d, (ix+VX_VERTEX_GPR1)
	sub	a, d
	ld	e, a
	ld	a, d
	jr	nc, $+3
	sub	a, b
	ld	d, b
	mlt	de
	add	a, d
	ld	(hl), a
	pop	iy
	pop	ix
; do specific edge shift here
	pop	af
	jr	nz, .edgeRentring
; edge leaving
	ld	hl, (iy+VX_PATCH_I0)
	ld	(ix+VX_PATCH_I0), hl
	lea	ix, ix+VX_PATCH_INDEX_SIZE
.edgeRentring:
	ld	hl, VX_PATCH_VERTEX
	ld	de, (vxPatchVertexCache)
	ld	(ix+VX_PATCH_I0), de
	ld	bc, VX_VERTEX_SIZE
	ldir
	ld	(vxPatchVertexCache), de
	pop	bc
	jp	.incEdge
; parametric compute for horizontal plane ;
.clipVerticalPlane:
	ld	bc, VX_VERTEX_RX
	add	hl, bc
	ld	bc, (hl)
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	hl, (hl)
	sbc	hl, bc
	tst	a, 10000000b
	jr	nz, .vinv0
	add	hl, bc
	add	hl, bc
.vinv0:
	ex	de, hl
	ld	bc, VX_VERTEX_RX
	add	hl, bc
	ld	bc, (hl)
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	hl, (hl)
	sbc	hl, bc
	tst	a, 10000000b
	jr	nz, .parametricVCompute
	add	hl, bc
	add	hl, bc
.parametricVCompute:
	push	ix
	push	iy
	push	af	; push flag plane
	call	vxParametric.factor
	ld	ix, (iy+VX_PATCH_I0)
	ld	iy, (iy+VX_PATCH_I1)
; ix = iy+0 (p0) , iy = iy+3 (p1)
; compute (p1-p0)*t+p0, for 24 bits vertex
; t = bc, p0 = ix, p1 = iy, output = clip_vertex0
; vertex coordinate ry
	ld	hl, (iy+VX_VERTEX_RY)
	ld	de, (ix+VX_VERTEX_RY)
	call	vxParametric.mlt
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RY), hl
; vertex coordinate rz
	ld	hl, (iy+VX_VERTEX_RZ)
	ld	de, (ix+VX_VERTEX_RZ)
	call	vxParametric.mlt
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RZ), hl
; vertex coordinate rx
; here, rx = -z or +z (based on plane, right plane = +)
	pop	af
	and	a, 10000000b
	push	bc
	ld	bc, $000140	;=VX_SCREEN_WIDTH_CENTER+(VX_SCREEN_WIDTH/2)
	jr	nz, .VNeg
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	dec	b
	ld	c,b	;=VX_SCREEN_WIDTH_CENTER-(VX_SCREEN_WIDTH/2)
.VNeg:
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RX), hl
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SX), bc
	ld	hl, (VX_PATCH_VERTEX+VX_VERTEX_RY)
	ld	bc, (VX_PATCH_VERTEX+VX_VERTEX_RZ)
; beware, RZ can be negative here. If so, it block stuff up, so, set code accordingly
	ld	a, (VX_PATCH_VERTEX+VX_VERTEX_RZ+2)
	rla
	jr	c, .clipz0
.parametricDivide0:
	xor	a, a
	add	hl, hl
	jr	nc, $+9
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
	sbc	hl, bc
	jr	c, .nextcarry0
	sbc	hl, bc
	jr	nc, .equal0
	or	a, a
.nextcarry0:
	adc	a, a
	add	hl, bc
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	add	hl, hl
	sbc	hl, bc
	adc	a, a
	add	a, a
	cpl
	ld	l, a
	ld	h, VX_SCREEN_HEIGHT shr 1
	mlt	hl
	ld	a, h
	jr	c, $+4
	neg
	add	a, VX_SCREEN_HEIGHT_CENTER
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SY), a
	xor	a, a
	jp	.parametricCCompute
.equal0:
	jr	nz, .clipy0
	rra
	ld	a, VX_SCREEN_HEIGHT_CENTER+(VX_SCREEN_HEIGHT/2)
	jr	c, $+3
	xor	a, a	;=VX_SCREEN_HEIGHT_CENTER-(VX_SCREEN_HEIGHT/2)
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SY), a
	jp	.parametricCCompute
.clipz0:
	add	hl, hl
	rla
.clipy0:
; we need to take care of extra clipping incurring on y plane only, since vertical plane will be both clipped proprely at first (and it doesn't change anything)
; so when it moves on to the y code, x won't be clipped anymore, only clamped, which is more than enough
	rra
	ld	c, 00010000b
	ld	a, VX_SCREEN_HEIGHT_CENTER+(VX_SCREEN_HEIGHT/2)
	jr	c, .clipy1
	xor	a, a	;=VX_SCREEN_HEIGHT_CENTER-(VX_SCREEN_HEIGHT/2)
	ld	c, 00100000b
.clipy1:
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SY), a
	ld	a, c
	jp	.parametricCCompute

vxParametric:
.mlt:
; (p1-p0)*f/65536+p0
; p1 = hl (24bits), p0 = de (24bits), f = bc (16bits)
	push	de
	xor	a, a
	sbc	hl, de	; hl = p1-p0
	or	a, h	; replaces "ld a,h" & avoid "or a,a" later
	ld	h, b
	dec	sp
	push	hl
	inc	sp
; l x b /256 -> d
	mlt	hl
	ld	d, h
; grab hlu in h
	pop	hl	; also h=b -> l
; hlu x b x 256
	ld	e, h	; hlu saved in e for later...
	bit	7, h
	mlt	hl
	jr	z, .mlt_sign_adjust
	sbc	hl, bc
.mlt_sign_adjust:
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	l, d
; hlu x c
	ld	d, c
	mlt	de
	add	hl, de
; h x b
	ld	e, a
	ld	d, b
	mlt	de
	add	hl, de
; h x c / 256
	ld	e, a
	ld	d, c
	mlt	de
	ld	e, d
	ld	d, 0
	add	hl, de
	pop	de
	add	hl, de	; add	up p0
	ret

.factor:
; bc (16bits) = abs(hl)*65536/abs(hl-de)
; abs(hl) < abs(hl-de)
; de < 0 and hl > 0 : substract carry
; hl > 0 and de < 0 : substract dont carry, we need to negate
	ex	de, hl
	or	a, a
	sbc	hl, de
	ex	de, hl
	jr	c, .factor_delta_abs
	push	hl
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	pop	hl
	jr	.factor_compute
.factor_delta_abs:
	push	de
	ex	de, hl
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	pop	de
.factor_compute:
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	cpl
	ld	b, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	adc	a, a
	cpl
	ld	c, a
	ret


;vxPrimitiveClipPlane:

; count : b
; project all vertex from the new primitive patch
; no-modified vertex are skipped
.clipplane_perspective:
	ld	a, (ix+VX_VERTEX_CODE)
	and	a, VX_CLIPPLANE_3D_MASK
	jr	z, .clipplane_null
.clipplane_dispatch:
; based on value of outcode plane, stored in uniform (new vertex create inherit some clip plane propriety)
	ld	a, (ix+VX_VERTEX_GPR2)
	rrca
	rrca
	ld	hl, .clipplane_table
	ld	l, a
	jp	(hl)
.clipplane_null:
	lea	ix, ix+VX_VERTEX_SIZE
	djnz	.clipplane_perspective
	ret

.clipplane_code_error:
	di
	halt
	jr	.clipplane_null
.clipplane_code_0101:
	ld	(ix+VX_VERTEX_SY), VX_SCREEN_HEIGHT_CENTER + (VX_SCREEN_HEIGHT shr 1)
	ld	hl, VX_SCREEN_WIDTH_CENTER - (VX_SCREEN_WIDTH shr 1)
	ld	(ix+VX_VERTEX_SX), hl
	jr	.clipplane_null
.clipplane_code_0110:
	ld	(ix+VX_VERTEX_SY), VX_SCREEN_HEIGHT_CENTER - (VX_SCREEN_HEIGHT shr 1)
	ld	hl, VX_SCREEN_WIDTH_CENTER - (VX_SCREEN_WIDTH shr 1)
	ld	(ix+VX_VERTEX_SX), hl
	jr	.clipplane_null
.clipplane_code_1001:
	ld	(ix+VX_VERTEX_SY), VX_SCREEN_HEIGHT_CENTER + (VX_SCREEN_HEIGHT shr 1)
	ld	hl, VX_SCREEN_WIDTH_CENTER + (VX_SCREEN_WIDTH shr 1)
	ld	(ix+VX_VERTEX_SX), hl
	jr	.clipplane_null
.clipplane_code_1010:
	ld	(ix+VX_VERTEX_SY), VX_SCREEN_HEIGHT_CENTER - (VX_SCREEN_HEIGHT shr 1)
	ld	hl, VX_SCREEN_WIDTH_CENTER + (VX_SCREEN_WIDTH shr 1)
	ld	(ix+VX_VERTEX_SX), hl
	jr	.clipplane_null	
.clipplane_code_0001:
	ld	(ix+VX_VERTEX_SY), VX_SCREEN_HEIGHT_CENTER + (VX_SCREEN_HEIGHT shr 1)
	jr	.clipplane_divide_rx
.clipplane_code_0010:
	ld	(ix+VX_VERTEX_SY), VX_SCREEN_HEIGHT_CENTER - (VX_SCREEN_HEIGHT shr 1)
	jr	.clipplane_divide_rx
.clipplane_code_0100:
	ld	hl, VX_SCREEN_WIDTH_CENTER - (VX_SCREEN_WIDTH shr 1)
	ld	(ix+VX_VERTEX_SX), hl
	jr	.clipplane_divide_ry
.clipplane_code_1000:
	ld	hl, VX_SCREEN_WIDTH_CENTER + (VX_SCREEN_WIDTH shr 1)
	ld	(ix+VX_VERTEX_SX), hl

.clipplane_divide_ry:
	ld	hl, (ix+VX_VERTEX_RY)
	xor	a, a
	add	hl, hl
	jr	nc, .clipplane_absolute_ry
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
.clipplane_absolute_ry:
	ld	de, (ix+VX_VERTEX_RZ)
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	adc	a, a
	cpl
	add	a, a
	ld	l, VX_SCREEN_HEIGHT shr 1
	ld	h, a
	mlt	hl
	ld	a, h
	jr	nc, $+3
	cpl
	adc	a, VX_SCREEN_HEIGHT_CENTER
	ld	(ix+VX_VERTEX_SY), a
	jp	.clipplane_null

.clipplane_divide_rx:
	ld	hl, (ix+VX_VERTEX_RX)
	xor	a, a
	add	hl, hl
	jr	nc, .clipplane_absolute_rx
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
.clipplane_absolute_rx:
	ld	de, (ix+VX_VERTEX_RZ)
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	jr	nc, $+3
	add	hl, de
	adc	a, a
	add	hl, hl
	sbc	hl, de
	adc	a, a
	cpl
	ld	l, a
	ld	h, VX_SCREEN_WIDTH shr 1
	mlt	hl
	ld	a, h
	sbc	hl, hl
	jr	nc, $+3
	cpl
	ld	l, a
	ld	de, VX_SCREEN_WIDTH_CENTER
	adc	hl, de
	ld	(ix+VX_VERTEX_SX), hl
	jp	.clipplane_null
	
; 10000000b	; vertical right edge (x=320)
; 01000000b	; vertical left edge (x=0)
; 00100000b	; horizontal upper edge (y=0)
; 00010000b	; horizontal lower edge (y=240)
align 256
.clipplane_table:
 dd	.clipplane_code_error	; 0000b	; none, should have been skipped
 dd	.clipplane_code_0001	; 0001b
 dd	.clipplane_code_0010	; 0010b
 dd	.clipplane_code_error	; 0011b	; impossible
 dd	.clipplane_code_0100	; 0100b
 dd	.clipplane_code_0101	; 0101b
 dd	.clipplane_code_0110	; 0110b
 dd	.clipplane_code_error	; 0111b	; impossible
 dd	.clipplane_code_1000	; 1000b
 dd	.clipplane_code_1001	; 1001b
 dd	.clipplane_code_1010	; 1010b
; dd	.clipplane_code_error	; 1011b	; impossible
; dd	.clipplane_code_error	; 1100b	; impossible
; dd	.clipplane_code_error	; 1101b	; impossible
; dd	.clipplane_code_error	; 1111b	; impossible
