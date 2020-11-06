#define  vxPlaneBit0             %10000000
#define  vxPlaneBit1             %01000000
#define  vxPlaneBit2             %00100000
#define  vxPlaneBit3             %00010000
#define  vxPlaneBit4             %00001000
#define  vxVertexDirty           %00000001
#define  VX_SCREEN_WIDTH         320
#define  VX_SCREEN_HEIGHT        240
#define  VX_SCREEN_WCENTER       160
#define  VX_SCREEN_HCENTER       120


#define 	VX_MAX_PATCH_VERTEX    	8
#define 	VX_MAX_PATCH_SIZE    		64
#define	VX_PATCH_INPUT			$D03480
#define	VX_PATCH_OUTPUT			$D034C0
#define	VX_PATCH_VERTEX_POOL		$D03400

vxPatchSize:
	.db	0
vxPatchVertexCache:
	.dl	0
VX_PATCH_VERTEX:
	.dl	0,0,0,0,0,0

vxPrimitiveClipFrustrum:
; input ;
; iy : patch_input (VX_PATCH_INPUT), point to a list of address of vertex
;  b : number of point
; output ;
; iy : clipped patch
;  b : number of point
	ld	hl, VX_PATCH_VERTEX_POOL
	ld	(vxPatchVertexCache), hl
	rla
	jr	nc, _inner_nextPlane0
	ex	af,af'
	ld	a, %10000000
	call	vxPrimitiveClipPlane
	ex	af,af'
_inner_nextPlane0:
	rla
	jr	nc, _inner_nextPlane1
	ex	af,af'
	ld	a, %01000000
	call	vxPrimitiveClipPlane
	ex	af,af'
_inner_nextPlane1:
	rla
	jr	nc, _inner_nextPlane2
	ex	af,af'
	ld	a, %00100000
	call	vxPrimitiveClipPlane
	ex	af,af'
_inner_nextPlane2:
	rla
	ret	nc
	ld	a, %00010000
; fall trough ;

vxPrimitiveClipPlane:
; input ;
; iy : patch_input (VX_PATCH_INPUT), point to a list of address of vertex
;  b : number of point
;  a : mask
; output ;
; iy : clipped patch (VX_PATCH_OUPUT)
;  b : number of point
	ld	c, a
	ld	a, b
	or	a, a
	ret	z
	xor	a, a
	ld	(vxPatchSize), a
	push	bc
	inc	b
	ld	c, 3
	mlt	bc
	lea	hl, iy + 0
	ld	iy, VX_PATCH_INPUT
;	ld	ix, VX_PATCH_OUTPUT
	lea ix, iy + VX_MAX_PATCH_SIZE
	lea	de, iy + 0
	ldir
	pop	bc
; b : count, c : planemask
_inner_clipSutherHodgmanLoop:
	push	bc
	ld	hl, (iy+VX_POLYGON_I1)
	ld	de, (iy+VX_POLYGON_I0)
	ld	a, (de)
	and	(hl)
	and	c
	jr	nz, _inner_noEdge
	ld	a, (de)
	or	a, (hl)
	and	c
	jr	nz, _inner_clipEdge
	ld	(ix+VX_POLYGON_I0), de
	ld	a, (vxPatchSize)
_inner_incEdge:
	lea	ix, ix+3
	inc	a
	ld	(vxPatchSize), a
_inner_noEdge:
	lea	iy, iy + 3
	pop	bc
	djnz	_inner_clipSutherHodgmanLoop
	ld	a, (vxPatchSize)
	ld	b, a
	ld	iy, VX_PATCH_OUTPUT
	ld	hl, (iy+VX_POLYGON_I0)
	ld	(ix+VX_POLYGON_I0), hl
	ret
; all works is here ;
_inner_clipEdge:
	ld	a, (de)
	and	c
	push	af
; compute distance based of mask a
	ld	a, c
	tst	a, %11000000
; nz = vertical
	jp	nz, _inner_clipVerticalPlane
_inner_clipHorizontalPlane:
	ld	bc, VX_VERTEX_RY
	add	hl, bc
	ld	bc, (hl)
	inc	hl
	inc	hl
	inc	hl
	ld	hl, (hl)
	sbc	hl, bc
	tst	a, %00100000
	jr	nz, _inner_hinv0
	add	hl, bc
	add	hl, bc
_inner_hinv0:
	ex	de, hl
	ld	bc, VX_VERTEX_RY
	add	hl, bc
	ld	bc, (hl)
	inc	hl
	inc	hl
	inc	hl
	ld	hl, (hl)
	sbc	hl, bc
	tst	a, %00100000
	jr	nz, _inner_hinv1
	add	hl, bc
	add	hl, bc
_inner_hinv1:
; parametric compute for horizontal plane ;
_inner_parametricHCompute:
	push	ix
	push	iy
; save plane mask for later
	push	af
	call	vxParametricFactor
	ld	ix, (iy+VX_POLYGON_I0)
	ld	iy, (iy+VX_POLYGON_I1)
; ix = iy+0 (p0) , iy = iy+3 (p1)
; compute (p1-p0)*t+p0, for 24 bits vertex
; t = bc, p0 = ix, p1 = iy, output = clip_vertex0
; vertex coordinate rx
	ld	hl, (iy+VX_VERTEX_RX)
	ld	de, (ix+VX_VERTEX_RX)
	call	vxParametricExtendMlt
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RX), hl
; vertex coordinate rz
	ld	hl, (iy+VX_VERTEX_RZ)
	ld	de, (ix+VX_VERTEX_RZ)
	call	vxParametricExtendMlt
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RZ), hl
; vertex coordinate ry
	pop	af
	and	%00100000
	ld	a, VX_SCREEN_HCENTER-(VX_SCREEN_HEIGHT/2)
	jr	nz, _inner_HNeg
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ld	a, VX_SCREEN_HCENTER+(VX_SCREEN_HEIGHT/2)
_inner_HNeg:
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RY), hl
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SY), a
	push	bc
	ld	hl, (VX_PATCH_VERTEX+VX_VERTEX_RX)
	ld	bc, (VX_PATCH_VERTEX+VX_VERTEX_RZ)
_inner_parametricDivide1:
	xor	a, a
	add	hl, hl
	jr	nc, $+9
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a

	sbc	hl, bc
	jr	c, _inner_nextcarry1
	sbc	hl, bc
	jr	nc, _inner_equal1
	or	a, a
_inner_nextcarry1:
	adc	a,a	\ add hl,bc
	add	hl,hl	\ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add	hl,hl	\ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add	hl,hl	\ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add	hl,hl	\ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add	hl,hl	\ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add	hl,hl	\ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add	hl,hl	\ sbc hl,bc \ adc a,a
	cpl
	ld   e, a
	ld   d, VX_SCREEN_WIDTH/2+1
	mlt   de
	ld    a, d
	sbc	hl, hl
	jr	nc, $+3
	cpl
	ld	l, a
	ld	de, VX_SCREEN_WCENTER
	adc	hl, de
	jr	_inner_writex
_inner_equal1:
	rra
	ld	hl, VX_SCREEN_WCENTER-(VX_SCREEN_WIDTH/2)
	jr	c, _inner_writex
	ld	hl, VX_SCREEN_WCENTER+(VX_SCREEN_WIDTH/2)
_inner_writex:
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SX), hl
	xor	a, a
; common compute ;
_inner_parametricCCompute:
	ld	(VX_PATCH_VERTEX+VX_VERTEX_CODE), a
; now, other vertex parameters
	pop	bc
	ld	hl, VX_PATCH_VERTEX + VX_VERTEX_GPR0
; parameter 0
	ld	a, (iy+VX_VERTEX_GPR0); a = p1
	ld	d, (ix+VX_VERTEX_GPR0); d = p0
	sub	a, d				; a = p1-p0
	ld	e, a				; e = p1-p0
	ld	a, d				; a = p0
	jr	nc, $+3			; sign correction
	sub	a, b				;
	ld	d, b				;
	mlt	de				; de = (unsigned)(p1-p0)*b
	add	a, d				; a = (signed)(p1-p0)*b/256+p0
	ld	(hl), a			; and write result
	inc	hl				; next parameter
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
	ld	a, (vxPatchSize)
	jr	nz, _inner_edgeRentring
; edge leaving
	ld	hl, (iy+VX_POLYGON_I0)
	ld	(ix+VX_POLYGON_I0), hl
	lea	ix, ix+3
	inc	a
_inner_edgeRentring:
	ld	hl, VX_PATCH_VERTEX
	ld	de, (vxPatchVertexCache)
	ld	(ix+VX_POLYGON_I0), de
	ld	bc, VX_VERTEX_SIZE
	ldir
	ld	(vxPatchVertexCache), de
	jp	_inner_incEdge
; parametric compute for horizontal plane ;
_inner_clipVerticalPlane:
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
	tst	a, %10000000
	jr	nz, _inner_vinv0
	add	hl, bc
	add	hl, bc
_inner_vinv0:
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
	tst	a, %10000000
	jr	nz, _inner_vinv1
	add	hl, bc
	add	hl, bc
_inner_vinv1:
_inner_parametricVCompute:
	push	ix
	push	iy
	push	af	; push flag plane
	call	vxParametricFactor
	ld	ix, (iy+VX_POLYGON_I0)
	ld	iy, (iy+VX_POLYGON_I1)
; ix = iy+0 (p0) , iy = iy+3 (p1)
; compute (p1-p0)*t+p0, for 24 bits vertex
; t = bc, p0 = ix, p1 = iy, output = clip_vertex0
; vertex coordinate ry
	ld	hl, (iy+VX_VERTEX_RY)
	ld	de, (ix+VX_VERTEX_RY)
	call	vxParametricExtendMlt
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RY), hl
; vertex coordinate rz
	ld	hl, (iy+VX_VERTEX_RZ)
	ld	de, (ix+VX_VERTEX_RZ)
	call	vxParametricExtendMlt
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RZ), hl
; vertex coordinate rx
; here, rx = -z or +z (based on plane, right plane = +)
	pop	af
	and	%10000000
	push	bc
	ld	bc, VX_SCREEN_WCENTER+(VX_SCREEN_WIDTH/2)
	jr	nz, _inner_VNeg
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ld	bc, VX_SCREEN_WCENTER-(VX_SCREEN_WIDTH/2)
_inner_VNeg:
	ld	(VX_PATCH_VERTEX+VX_VERTEX_RX), hl
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SX), bc
	ld	hl, (VX_PATCH_VERTEX+VX_VERTEX_RY)
	ld	bc, (VX_PATCH_VERTEX+VX_VERTEX_RZ)
; beware, RZ can be negative here. If so, it block stuff up, so, set bc = 1
	ld	a, (VX_PATCH_VERTEX+VX_VERTEX_RZ+2)
	rla
	jr	nc, $+6
	ld	bc, 1
_inner_parametricDivide0:
	xor	a, a
	add	hl, hl
	jr	nc, $+9
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
	sbc	hl, bc
	jr	c, _inner_nextcarry0
	sbc	hl, bc
	jr	nc, _inner_equal0
	or	a, a
_inner_nextcarry0:
	adc a,a \ add hl,bc
	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
	add hl,hl \ sbc hl,bc \ adc a,a
	cpl
	add	a, a
	ld	l, VX_SCREEN_HEIGHT/2+1
	ld	h, a
	mlt	hl
	ld	a, h
	jr	nc, $+3
	cpl
	adc	a, VX_SCREEN_HCENTER
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SY), a
	xor	a, a
	jp	_inner_parametricCCompute
_inner_equal0:
	jr	nz, _inner_clipy0
	rra
	ld	a, VX_SCREEN_HCENTER-(VX_SCREEN_HEIGHT/2)
	jr	nc, $+4
	ld	a, VX_SCREEN_HCENTER+(VX_SCREEN_HEIGHT/2)
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SY), a
	jp	_inner_parametricCCompute
_inner_clipy0:
; we need to take care of extra clipping incurring on y plane only, since vertical plane will be both clipped proprely at first (and it doesn't change anything)
; so when it moves on to the y code, x won't be clipped anymore, only clamped, which is more than enough
	rra
	ld	c, %00100000
	ld	a, VX_SCREEN_HCENTER-(VX_SCREEN_HEIGHT/2)
	jr	nc, _inner_clipy1
	ld	a, VX_SCREEN_HCENTER+(VX_SCREEN_HEIGHT/2)
	ld	c, %00010000
_inner_clipy1
	ld	(VX_PATCH_VERTEX+VX_VERTEX_SY), a
	ld	a, c
	jp	_inner_parametricCCompute

vxParametricExtendMlt:
; (p1-p0)*f/65536+p0
; p1 = hl (24bits), p0 = de (24bits), f = bc (16bits)
	or	a, a
	sbc	hl, de	; hl = p1-p0
	push	de
	ld	a, l
	push	af
; grab hlu in a
	push	hl
	inc	sp
	pop	af
	dec	sp
	ld	d, h
; hlu x b x 256
	ld	l, a
	bit	7, a
	ld	h, b
	mlt	hl
	jr	z, vxParametricSignAdjust
	or	a, a
	sbc	hl, bc
vxParametricSignAdjust:
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
; hlu x c
	ld	e, a
	ld	a, d
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
; l x b /256
	ld	e, b
	mlt	de
	ld	e, d
	ld	d, 0
	add	hl, de
	pop	de
	add	hl, de	; add up p0
	ret

vxParametricFactor:
; bc (16bits) = abs(hl)*65536/abs(hl-de)
; if hl-de < 0 then hl is < 0, else both are >0
	ex	de, hl
	or	a, a
	sbc	hl, de
	push	de
; abs(de-hl), if >0 then de <0
	jp	p, _inner_deltaAbs
	add	hl, de
	ex	de, hl
	or	a, a
	sbc	hl, de
_inner_deltaAbs:
	pop	de
	ex	de, hl
	add	hl, hl
	jr	nc, _inner_absValue
	push	de
	ex	de, hl
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	pop	de
_inner_absValue:
	sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	cpl
	ld   b, a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ jr nc,$+3 \ add hl,de \ adc a,a
	add   hl,hl \ sbc hl,de \ adc a,a
	cpl
	ld   c, a
	ret
