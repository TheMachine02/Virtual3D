vxPrimitiveTextureRaster:
	inc	hl
	inc	de
	inc	bc
	ld	a, (de)
	sub	a, (hl)
	jr	c, _inner_swap0
	ex	de, hl
_inner_swap0:
	ld	a, (bc)
	sub	a, (hl)
	jr	nc, _inner_swap1
	push	hl
	or	a, a
	sbc	hl, hl
	add	hl, bc
	pop	bc
_inner_swap1:
	ld	a, (de)
	sub	a, (hl)
	jr	nc, _inner_swap2
	ex	de, hl
_inner_swap2:
_inner_hcull:
; cull if dy=0
	ld	a, (bc)
	sub	(hl)
	ret	z
_inner_cacheRegister:
	ld	(VX_SMC_STACK_REGISTER), sp
; copy x&y u&v to constant area
	ld	iy, VX_REGISTER_DATA
	push	bc
	push	de
	lea	de, iy-32
	ld	bc, 6
	ldir
	pop	hl
	ld	c, 6
	ldir
	pop	hl
	ld	c, 6
	ldir
_inner_triangleSetup:
debug_mark_gouraud:
;	ld	a, (iy+VX_REGISTER_C0)
;	ld	(iy+VX_REGISTER_V0), a
;	ld	a, (iy+VX_REGISTER_C1)
;	ld	(iy+VX_REGISTER_V1), a
;	ld	a, (iy+VX_REGISTER_C2)
;	ld	(iy+VX_REGISTER_V2), a
debug_mark_endpoint:
;	ld	hl, $D30000
;	ld	h, (iy+VX_REGISTER_V0)
;	ld	l, (iy+VX_REGISTER_U0)
;	ld	(hl), $E0
;	ld	h, (iy+VX_REGISTER_V1)
;	ld	l, (iy+VX_REGISTER_U1)
;	ld	(hl), $E0
;	ld	h, (iy+VX_REGISTER_V2)
;	ld	l, (iy+VX_REGISTER_U2)
;	ld	(hl), $E0
_inner_triangleInv_dy:
; ~ 500 cc
; inv = 65536/(y2-y0);
	ld	a, (iy+VX_REGISTER_Y2)
	sub	a, (iy+VX_REGISTER_Y0)
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	ld	de, VX_LUT_INVERSE
	add	hl, de
	ld	de, (hl)
	inc.s	de
_inner_triangleCompute_dvdy:
; dvdy = (v2-v0)*inv/256;
	ld	a, (iy+VX_REGISTER_V2)
	sub	(iy+VX_REGISTER_V0)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, _inner_triangleNull_dvdy
	jr	nc, $+5
	or	a, a
	sbc	hl, de
	ld	b, e
	ld	c, a
	mlt	bc
	rl	c
	ld	c, b
	ld	b, 0
	adc	hl, bc
_inner_triangleNull_dvdy:
	ld	(iy+VX_FDVDY), hl
; compute vs at longest span
	ld	a, (iy+VX_REGISTER_Y1)
	sub	(iy+VX_REGISTER_Y0)
	ld	b, a
	ld	c, h
	ld	h, a
	mlt	bc
	mlt	hl
	ld	a, (iy+VX_REGISTER_V0)
	rl	l
	adc	a, h
	add	a, c
	ld	(iy+VX_REGISTER_VS), a
_inner_triangleCompute_dudy:
; dudy = (u2-u0)*inv/256;
	ld	a, (iy+VX_REGISTER_U2)
	sub	(iy+VX_REGISTER_U0)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, _inner_triangleNull_dudy
	jr	nc, $+5
	or	a, a
	sbc	hl, de
	ld	d, a
	mlt	de
	rl	e
	ld	e, d
	ld	d, 0
	adc.s	hl, de
_inner_triangleNull_dudy:
; compute us at longest span
	ld	a, (iy+VX_REGISTER_Y1)
	sub	(iy+VX_REGISTER_Y0)
	ld	b, a
	ld	c, h
	ld	d, a
	ld	e, l
	mlt	bc
	mlt	de
	ld	a, (iy+VX_REGISTER_U0)
	rl	e
	adc	a, d
	add	a, c
	ld	(iy+VX_REGISTER_US), a
; now adapt because of the layout in memory : [lDVDY][hDVDY][lDUDY][hDUDY]
	bit	7, (iy+VX_FDVDY+1)	; if dvdy is < 0 then adding will always propagate a carry inside dudy, which is a no-no
	jr	z, $+4
	dec.s	hl
	ld	(iy+VX_FDUDY), hl
_inner_edge0Setup:
; perform necessary computation to interpolate over the edge0, which is line(x0,y0,x2,y2)
; ~ 250cc
_inner_edge0Compute_offset:
; register_offset=320*y0+x0+framebuffer;
	ld	hl, (iy+VX_REGISTER_X0)
	ld	e, (iy+VX_REGISTER_Y0)
	ld	d, 160
	mlt	de
	ex.s	de, hl
	add	hl, hl
	add	hl, de
	ex	de, hl
	ld	ix, (vxFramebuffer)
	add	ix, de
	ld	(iy+VX_REGISTER_OFFSET), ix
_inner_edge0Compute_dx:
; compute the deltas for vxRegisterInterpolation
; dx = abs(x2-x0) [de]
	ld	de, (iy+VX_REGISTER_X2)	; load x2
; hl already hold _x0
;	ld	hl, (iy+VX_REGISTER_X0)	; load x0
	ex.s	de, hl
	ld	a, $23	; inc ix
; carry reseted by add ix, de
;	or	a, a
	sbc	hl, de	; hl = x2-x0
	jr	nc, _inner_edge0Swap
	add	hl, de	;
	ex	de, hl	;
	or	a, $08	; dec ix
	sbc	hl, de	; hl = x0-x2
_inner_edge0Swap:
	ld	(VX_SMC_EDGE0_INC), a
_inner_edge0Compute_dy:
; dy = y0-y2 [bc]
	ld	a, (iy+VX_REGISTER_Y0)
	sub	a, (iy+VX_REGISTER_Y2)
	ld	bc, $FFFFFF
	ld	c, a
_inner_edge0Compute_error:
; prepare the error for pixel center correct in/out (leftruled)
	ex	de, hl
	sbc	hl, hl	; carry is set here, so hl=-1
	ld	l, a
	sbc	hl, de
	sra	h
	rr	l
	neg
; load the buffer increment on the y axis
	ld	sp, 320
_inner_edge0loop:
; dark magic part I
	add	hl, de
	jr	nc, _inner_edge0End
_inner_edge0Propagate:
	.db	$DD
VX_SMC_EDGE0_INC=$
	nop
	add	hl, bc
	jr	c, _inner_edge0Propagate
_inner_edge0End:
	ld	(iy+VX_REGISTER0), ix
	add	ix, sp
	lea	iy, iy+VX_REGISTER_SIZE
	dec	a
	jr	nz, _inner_edge0loop
_inner_edge0magic:
	ld	ix, VX_REGISTER_DATA
	ld	hl, (ix+VX_REGISTER_X2)
	ld	e, (ix+VX_REGISTER_Y2)
	ld	d, 160
	mlt	de
	ex.s	de, hl
	add	hl, hl
	add	hl, de
	ld	de, (vxFramebuffer)
	add	hl, de
	ld	(iy+VX_REGISTER0), hl
_inner_edge1Setup:
;	ld	iy, VX_REGISTER_DATA	; load up shader data register
	lea iy, ix+0
_inner_edge1Compute_dy:
	ld	a, (iy+VX_REGISTER_Y0)
	sub	a, (iy+VX_REGISTER_Y1)
	jr	z, _inner_edge1Null
; bc is already negated
;	ld	bc, $FFFFFF
	ld	c, a
_inner_edge1Compute_offset:
	ld	de, (iy+VX_REGISTER_OFFSET)
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	ld	ix, VX_LUT_PIXEL_LENGTH/4 + 2 ; (+2 is double carry sbc)
	add	ix, de
_inner_edge1Compute_dx:
	ld	de, (iy+VX_REGISTER_X0)
	ld	hl, (iy+VX_REGISTER_X1)
	ex.s	de, hl
	ld	a, $23	; dec ix
	or	a, a
	sbc	hl, de	; hl = x1-x0
	jr	nc, _inner_edge1Swap
	add	hl, de	;
	ex	de, hl	;
	xor	a, $08	; inc ix	(inverted due to <0 working function)
	sbc	hl, de	; hl = -x1+x0
_inner_edge1Swap:
	ex	de, hl	; de = abs(x1-x0)
	ld	(VX_SMC_EDGE1_INC), a
_inner_edge1Compute_error:
	ld	a, c
	scf
	sbc	hl, hl
	ld	l, a
	sbc	hl, de
	sra	h
	rr	l
	neg
; load the buffer increment on the y axis
	ld	sp, -320
	lea	iy, iy+VX_REGISTER1
_inner_edge1loop:
; dark magic part II
	add	hl, de
	jr	nc, _inner_edge1End
_inner_edge1Propagate:
	.db	$DD
VX_SMC_EDGE1_INC=$
	nop
	add	hl, bc
	jr	c, _inner_edge1Propagate
_inner_edge1End:
	ld	(iy+VX_REGISTER0), ix
	add	ix, sp
	lea	iy, iy+VX_REGISTER_SIZE
	dec	a
	jr	nz, _inner_edge1loop
	lea	iy, iy-VX_REGISTER1
_inner_edge1Null:

_inner_edge2Setup:
	ld	ix, VX_REGISTER_DATA	; load up shader data register
	ld	(ix+VX_REGISTER_MIDPOINT), iy
_inner_edge2Compute_dy:
	ld	a, (ix+VX_REGISTER_Y1)
	ld	e, a
	sub	a, (ix+VX_REGISTER_Y2)
_inner_edge2Compute_offset:
	ld	hl, (ix+VX_REGISTER_X1)
	ld	b, h
	ld	c, l
	ld	d, 160
	mlt	de
	ex.s	de, hl
	add	hl, hl
	add	hl, de
	ld	de, (vxFramebuffer)
	add	hl, de
	ld	(ix+VX_REGISTER_OFFSET), hl
	or	a, a
	jr	z, _inner_edge2Null
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	ld	hl, (ix+VX_REGISTER_X2)
	ld	ix, VX_LUT_PIXEL_LENGTH/4
	add	ix, de
_inner_edge2Compute_dx:
	ld	d, b
	ld	e, c
; bcu already at $FF, reset only b
;	ld	bc, $FFFFFF
	ld	b, $FF
	ld	c, a
	ex.s	de, hl
	ld	a, $23	; dec ix
	or	a, a
	sbc	hl, de	; hl = x2-x1
	jr	nc, _inner_edge2Swap
	add	hl, de	;
	ex	de, hl	;
	xor	a, $08	; inc ix	(inverted due to <0 working function)
	sbc	hl, de	; hl = -x1+x0
_inner_edge2Swap:
	ld	(VX_SMC_EDGE2_INC), a
_inner_edge2Compute_error:
	ld	a, c
	ex	de, hl
	scf
	sbc	hl, hl
	ld	l, a
	sbc	hl, de
	sra	h
	rr	l
	neg
	ld	sp, -320
	lea	iy, iy+VX_REGISTER1
_inner_edge2loop:
; dark magic part III
	add	hl, de
	jr	nc, _inner_edge2End
_inner_edge2Propagate:
	.db	$DD
VX_SMC_EDGE2_INC=$
	nop
	add	hl, bc
	jr	c, _inner_edge2Propagate
_inner_edge2End:
	ld	(iy+VX_REGISTER0), ix
	add	ix, sp
	lea	iy, iy+VX_REGISTER_SIZE
	dec	a
	jr	nz, _inner_edge2loop
	lea	iy, iy-VX_REGISTER1
_inner_edge2Null:
_inner_edge2Magic:
	ld	de, (iy+VX_REGISTER0)
	ld	hl, vxPixelShaderExitLUT/4
	or	a, a
	sbc	hl, de
	ld	(iy+VX_REGISTER1), hl

_inner_triangleInv_dx:
	ld	iy, VX_REGISTER_DATA	; load up shader data register
	ld	ix, (iy+VX_REGISTER_MIDPOINT)	; value @x1
	ld	hl, (iy+VX_REGISTER_OFFSET)
	ld	de, (ix+VX_REGISTER0)
	or	a, a
	sbc hl, de
	jp	z, vxPixelShaderExit
; now abs(hl)
	ld	a, $13
	jr	nc, _inner_triangleAbs
	ex	de, hl
	or	a, $08
	sbc	hl, hl
	sbc	hl, de
_inner_triangleAbs:
; write inc/dec
vxShaderAdress0Write=$+1
	ld	($D00000), a
vxShaderAdress1Write=$+1
	ld	($D00000), a
; if a = 1B, write 1B ; else write 0
	xor	a, $13
	jr	z, $+4
	or	a, $13
vxShaderAdress2Write=$+1
	ld	($D00000), a

	add	hl, hl
	ld	de, VX_LUT_INVERSE + 2
	add	hl, de
	ld	de, (hl)
	inc.s	de	; de = 65536/dx
_inner_triangleCompute_dvdx:
	ld	a, (iy+VX_REGISTER_V1)
	sub	a, (iy+VX_REGISTER_VS)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, _inner_triangleNull_dvdx
	jr	nc, $+5
	or	a, a
	sbc	hl, de
	ld	b, e
	ld	c, a
	mlt	bc
	ld	c, b
	xor	a, a
	ld	b, a
	add	hl, bc
_inner_triangleNull_dvdx:
	ld	(iy+VX_FDVDX), hl
	ld	c, h
_inner_triangleCompute_dudx:
	ld	a, (iy+VX_REGISTER_U1)
	sub	a, (iy+VX_REGISTER_US)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, _inner_triangleNull_dudx
	jr	nc, $+5
	or	a, a
	sbc	hl, de
	ld	d, a
	mlt	de
	ld	e, d
	xor	a, a
	ld	d, a
	add.s	hl, de
_inner_triangleNull_dudx:
	bit	7, c
	jr	z, $+4
	dec.s	hl
	ld	(iy+VX_FDUDX), hl

_inner_triangleGradient:
	ld	a, (iy+VX_REGISTER_Y2)
	sub	a, (iy+VX_REGISTER_Y0)
	ld	b, a
	ld	hl, (iy+VX_FDVDY)
	ld	de, (iy+VX_FDVDX)
	or	a, a
	sbc	hl, de
	sra	h \ rr l
	ld	a, (iy+VX_REGISTER_V0)
	add	a, h
	ld	h, a
	ld	(iy+VX_REGISTER_TMP), hl
	ld	hl, (iy+VX_FDUDY)
	ld	de, (iy+VX_FDUDX)
	or	a, a
	sbc	hl, de
	sra	h \ rr l
	ld	(iy+VX_REGISTER_TMP+2), l
	ld	a, (iy+VX_REGISTER_U0)
	add	a, h
	ld	hl, (iy+VX_REGISTER_TMP)
	ld	de, (iy+VX_FDVDY)
	ld	c, (iy+VX_FDUDY+1)
	lea	ix, iy+0
_inner_triangleGradientLoop:
	ld	(ix+VX_REGISTER2), hl
	ld	(ix+VX_REGISTER3), a
	add	hl, de
	adc	a, c
	dec	b
	jr	z, _inner_triangleGradientEnd
	ld	(ix+VX_REGISTER2+VX_REGISTER_SIZE), hl
	ld	(ix+VX_REGISTER3+VX_REGISTER_SIZE), a
	add	hl, de
	adc	a, c
	lea	ix, ix+(VX_REGISTER_SIZE*2)
	djnz	_inner_triangleGradientLoop
_inner_triangleGradientEnd:
_inner_triangleRenderPixel:
; initialise drawing
; hl'= texture page and accumulator for dux	LOADED
; bc'= low byte is dux						INIT
; sp = dux*65536+dvx						INIT
; de'= undefined							INIT
; hl = accumulator for dux					LOADED
; de = screen adress						LOADED
; bc = djnz size							LOADED
	ld	de, (iy+VX_FDVDX)
	ld	hl, (iy+VX_FDUDX+1)
	ld	sp, hl
	exx
vxShaderUniform0=$+1
	ld	bc, VX_PIXEL_SHADER_DATA + 255
	exx
vxShaderJumpWrite=$+1
	jp	$000000
vxPixelShaderExit:
VX_SMC_STACK_REGISTER=$+1
	ld	sp, $000000
	ret

VX_REALLOC_EDGE_POINTER:
; dark magic
_inner_edgeTrace:
	add	hl, de
	jr	nc, _inner_edgeEnd
_inner_edgePropagate:
	.db	$DD
VX_REALLOC_EDGE_INC=$
	nop
	add	hl, bc
	jr	c, _inner_edgePropagate
_inner_edgeEnd:
	ld	(iy+VX_REGISTER0), ix
	add	ix, sp
	lea	iy, iy+VX_REGISTER_SIZE
	dec	a
	jr	nz, _inner_edgeTrace
	ret
VX_REALLOC_EDGE_SIZE=$-VX_REALLOC_EDGE_POINTER

VX_REALLOC_SHADER_POINTER:
	.fill VX_REALLOC_EDGE_SIZE
VX_REALLOC_SHADER_SIZE=VX_REALLOC_EDGE_SIZE