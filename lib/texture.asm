vxPrimitiveTextureRaster:
	inc	hl
	inc	de
	inc	bc
	ld	a, (de)
	sub	a, (hl)
	jr	c, .swap0
	ex	de, hl
.swap0:
	ld	a, (bc)
	sub	a, (hl)
	jr	nc, .swap1
	push	hl
	or	a, a
	sbc	hl, hl
	add	hl, bc
	pop	bc
.swap1:
	ld	a, (de)
	sub	a, (hl)
	jr	nc, .swap2
	ex	de, hl
.swap2:
.hcull:
; cull if dy=0
	ld	a, (bc)
	sub	a, (hl)
	ret	z
.cacheRegister:
	cce	ge_pxl_raster
	ld	(VX_SMC_STACK_REGISTER), sp
; copy x&y u&v to constant area
	ld	iy, VX_REGISTER_DATA
	push	bc
	push	de
	lea	de, iy-32
	ld	bc, 3
	ldir
	inc	de
	ld	c, 2
	ldir	
	pop	hl
	ld	bc, 3
	ldir
	inc	de
	ld	c, 2
	ldir	
	pop	hl
	ld	bc, 3
	ldir
	inc	de
	ld	c, 2
	ldir	
.triangleSetup:
; debug_mark_gouraud:
;	ld	a, (iy+VX_REGISTER_C0)
;	ld	(iy+VX_REGISTER_V0), a
;	ld	a, (iy+VX_REGISTER_C1)
;	ld	(iy+VX_REGISTER_V1), a
;	ld	a, (iy+VX_REGISTER_C2)
;	ld	(iy+VX_REGISTER_V2), a
; debug_mark_endpoint:
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
.triangleInv_dy:
; ~ 500 cc
; inv = 65536/(y2-y0);
; 	ld	a, (iy+VX_REGISTER_Y2)
; 	sub	a, (iy+VX_REGISTER_Y0)
	ld	hl, VX_LUT_INVERSE shr 1
	ld	l, a
	add	hl, hl
	ld	de, (hl)
	inc.s	de
.triangleCompute_dvdy:
; dvdy = (v2-v0)*inv/256;
	ld	a, (iy+VX_REGISTER_V2)
	sub	a, (iy+VX_REGISTER_V0)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, .triangleNull_dvdy
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
.triangleNull_dvdy:
	ld	(iy+VX_FDVDY), hl
; compute vs at longest span
	ld	a, (iy+VX_REGISTER_Y1)
	sub	a, (iy+VX_REGISTER_Y0)
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
.triangleCompute_dudy:
; dudy = (u2-u0)*inv/256;
	ld	a, (iy+VX_REGISTER_U2)
	sub	a, (iy+VX_REGISTER_U0)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, .triangleNull_dudy
	jr	nc, $+5
	or	a, a
	sbc	hl, de
	ld	d, a
	mlt	de
	rl	e
	ld	e, d
	ld	d, 0
	adc.s	hl, de
.triangleNull_dudy:
; now adapt because of the layout in memory : [lDVDY][hDVDY][lDUDY][hDUDY]
	bit	7, (iy+VX_FDVDY+1)	; if dvdy is < 0 then adding will always propagate a carry inside dudy, which is a no-no
	jr	z, $+4
	dec.s	hl
	ld	(iy+VX_FDUDY), hl
; compute us at longest span
	ld	a, (iy+VX_REGISTER_Y1)
	sub	(iy+VX_REGISTER_Y0)
	ld	b, a
	ld	c, h
	ld	h, a
	mlt	bc
	mlt	hl
	ld	a, (iy+VX_REGISTER_U0)
	rl	l
	adc	a, h
	add	a, c
	ld	(iy+VX_REGISTER_US), a
.edge0Setup:
; perform necessary computation to interpolate over the edge0, which is line(x0,y0,x2,y2)
; ~ 250cc
.edge0Compute_offset:
; register_offset=320*y0+x0+framebuffer;
	ld	de, (iy+VX_REGISTER_X0)
	ld	l, (iy+VX_REGISTER_Y0)
	ld	h, 160
	mlt	hl
	add	hl, hl
	add	hl, de
	ex	de, hl
	ld	ix, (vxFramebuffer)
	add	ix, de
	ld	(iy+VX_REGISTER_OFFSET), ix
.edge0Compute_dx:
; compute the deltas for vxRegisterInterpolation
; dx = abs(x2-x0) [de]
	ld	de, (iy+VX_REGISTER_X2)	; load x2
; hl already hold _x0
;	ld	hl, (iy+VX_REGISTER_X0)	; load x0
	ld	a, $23 or $08	; inc ix
; carry reseted by add ix, de
;	or	a, a
	sbc	hl, de	; hl = x2-x0
	jr	nc, .edge0Swap
	add	hl, de	;
	ex	de, hl	;
	xor	a, $08	; dec ix
	sbc	hl, de	; hl = x0-x2
.edge0Swap:
	ld	(VX_SMC_EDGE0_INC), a
.edge0Compute_dy:
; dy = y0-y2 [bc]
	ld	a, (iy+VX_REGISTER_Y0)
	sub	a, (iy+VX_REGISTER_Y2)
	ld	bc, $FFFFFF
	ld	c, a
.edge0Compute_error:
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
.edge0loop:
; dark magic part I
	add	hl, de
	jr	nc, .edge0End
.edge0Propagate:
	db	$DD
VX_SMC_EDGE0_INC=$
	nop
	add	hl, bc
	jr	c, .edge0Propagate
.edge0End:
	ld	(iy+VX_REGISTER0), ix
	add	ix, sp
	lea	iy, iy+VX_REGISTER_SIZE
	dec	a
	jr	nz, .edge0loop
.edge0magic:
	ld	ix, VX_REGISTER_DATA
	ld	de, (ix+VX_REGISTER_X2)
	ld	l, (ix+VX_REGISTER_Y2)
	ld	h, 160
	mlt	hl
	add	hl, hl
	add	hl, de
	ld	de, (vxFramebuffer)
	add	hl, de
	ld	(iy+VX_REGISTER0), hl
.edge1Setup:
;	ld	iy, VX_REGISTER_DATA	; load up shader data register
	lea iy, ix+0
.edge1Compute_dy:
	ld	a, (iy+VX_REGISTER_Y0)
	sub	a, (iy+VX_REGISTER_Y1)
	jr	z, .edge1Null
; bc is already negated
;	ld	bc, $FFFFFF
	ld	c, a
.edge1Compute_offset:
	ld	de, (iy+VX_REGISTER_OFFSET)
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	ld	ix, VX_LUT_PIXEL_LENGTH/4 + 2 ; (+2 is double carry sbc)
	add	ix, de
.edge1Compute_dx:
	ld	hl, (iy+VX_REGISTER_X0)
	ld	de, (iy+VX_REGISTER_X1)
	ld	a, $23	; dec ix
	or	a, a
	sbc	hl, de	; hl = x1-x0
	jr	nc, .edge1Swap
	add	hl, de	;
	ex	de, hl	;
	xor	a, $08	; inc ix	(inverted due to <0 working function)
	sbc	hl, de	; hl = -x1+x0
.edge1Swap:
	ex	de, hl	; de = abs(x1-x0)
	ld	(VX_SMC_EDGE1_INC), a
.edge1Compute_error:
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
.edge1loop:
; dark magic part II
	add	hl, de
	jr	nc, .edge1End
.edge1Propagate:
	db	$DD
VX_SMC_EDGE1_INC=$
	nop
	add	hl, bc
	jr	c, .edge1Propagate
.edge1End:
	ld	(iy+VX_REGISTER0), ix
	add	ix, sp
	lea	iy, iy+VX_REGISTER_SIZE
	dec	a
	jr	nz, .edge1loop
	lea	iy, iy-VX_REGISTER1
.edge1Null:

.edge2Setup:
	ld	ix, VX_REGISTER_DATA	; load up shader data register
	ld	(ix+VX_REGISTER_MIDPOINT), iy
.edge2Compute_dy:
	ld	a, (ix+VX_REGISTER_Y1)
	ld	l, a
	sub	a, (ix+VX_REGISTER_Y2)
.edge2Compute_offset:
	ld	de, (ix+VX_REGISTER_X1)
	ld	b, d
	ld	c, e
	ld	h, 160
	mlt	hl
	add	hl, hl
	add	hl, de
	ld	de, (vxFramebuffer)
	add	hl, de
	ld	(ix+VX_REGISTER_OFFSET), hl
	or	a, a
	jr	z, .edge2Null
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	ld	hl, (ix+VX_REGISTER_X2)
	ld	ix, VX_LUT_PIXEL_LENGTH/4
	add	ix, de
.edge2Compute_dx:
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
	jr	nc, .edge2Swap
	add	hl, de	;
	ex	de, hl	;
	xor	a, $08	; inc ix	(inverted due to <0 working function)
	sbc	hl, de	; hl = -x1+x0
.edge2Swap:
	ld	(VX_SMC_EDGE2_INC), a
.edge2Compute_error:
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
.edge2loop:
; dark magic part III
	add	hl, de
	jr	nc, .edge2End
.edge2Propagate:
	db	$DD
VX_SMC_EDGE2_INC=$
	nop
	add	hl, bc
	jr	c, .edge2Propagate
.edge2End:
	ld	(iy+VX_REGISTER0), ix
	add	ix, sp
	lea	iy, iy+VX_REGISTER_SIZE
	dec	a
	jr	nz, .edge2loop
	lea	iy, iy-VX_REGISTER1
.edge2Null:
.edge2Magic:
	ld	de, (iy+VX_REGISTER0)
	ld	hl, vxPixelShaderExitLUT/4
	or	a, a
	sbc	hl, de
	ld	(iy+VX_REGISTER1), hl

.triangleInv_dx:
	ld	iy, VX_REGISTER_DATA	; load up shader data register
	ld	ix, (iy+VX_REGISTER_MIDPOINT)	; value @x1
	ld	hl, (iy+VX_REGISTER_OFFSET)
	ld	de, (ix+VX_REGISTER0)
	or	a, a
	sbc	hl, de
	jp	z, vxPixelShaderExit
; now abs(hl)
	ld	a, $13
	jr	nc, .triangleAbs
	ex	de, hl
	or	a, $08
	sbc	hl, hl
	sbc	hl, de
.triangleAbs:
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
.triangleCompute_dvdx:
	ld	a, (iy+VX_REGISTER_V1)
	sub	a, (iy+VX_REGISTER_VS)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, .triangleNull_dvdx
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
.triangleNull_dvdx:
	ld	(iy+VX_FDVDX), hl
	ld	c, h
.triangleCompute_dudx:
	ld	a, (iy+VX_REGISTER_U1)
	sub	a, (iy+VX_REGISTER_US)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, .triangleNull_dudx
	jr	nc, $+5
	or	a, a
	sbc	hl, de
	ld	d, a
	mlt	de
	ld	e, d
	xor	a, a
	ld	d, a
	add.s	hl, de
.triangleNull_dudx:
	bit	7, c
	jr	z, $+4
	dec.s	hl
	ld	(iy+VX_FDUDX), hl
.triangleMipmap:
; 	ld	sp, TMP
; 	call	vxMipmapLevel
.triangleGradient:
	ld	a, (iy+VX_REGISTER_Y2)
	sub	a, (iy+VX_REGISTER_Y0)
	rra
	adc	a, 0
	ld	b, a
	ld	hl, (iy+VX_FDVDY)
	ld	de, (iy+VX_FDVDX)
	sbc	hl, de
	sra	h
	rr	l
	ld	a, (iy+VX_REGISTER_V0)
	add	a, h
	ld	h, a
	ld	(iy+VX_REGISTER_TMP), hl
	ld	hl, (iy+VX_FDUDY)
	ld	de, (iy+VX_FDUDX)
	sbc	hl, de
	sra	h
	rr	l
	ld	(iy+VX_REGISTER_TMP+2), l
	ld	a, (iy+VX_REGISTER_U0)
	add	a, h
	ld	hl, (iy+VX_REGISTER_TMP)
	ld	de, (iy+VX_FDVDY)
	ld	c, (iy+VX_FDUDY+1)
	lea	ix, iy+0
.triangleGradientLoop:
	ld	(ix+VX_REGISTER2), hl
	ld	(ix+VX_REGISTER3), a
	add	hl, de
	adc	a, c
	ld	(ix+VX_REGISTER2+VX_REGISTER_SIZE), hl
	ld	(ix+VX_REGISTER3+VX_REGISTER_SIZE), a
	add	hl, de
	adc	a, c
	lea	ix, ix+(VX_REGISTER_SIZE*2)
	djnz	.triangleGradientLoop
.triangleGradientEnd:
	ccr	ge_pxl_raster
.triangleRenderPixel:
	cce	ge_pxl_shading
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
	ld	bc, VX_PIXEL_SHADER_DATA
	exx
vxShaderJumpWrite=$+1
	jp	$000000
vxPixelShaderExit:
VX_SMC_STACK_REGISTER=$+1
	ld	sp, $000000
	ccr	ge_pxl_shading
	ret
