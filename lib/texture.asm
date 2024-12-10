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
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE US OR OTHER DEALINGS IN THE
; SOFTWARE.

define	VX_GPR_HINT_HUGE_TILE	1 slh 0		; bigger than 32 pixels height triangle 
define	VX_GPR_HINT_DUAL_PIXEL	1 slh 1		; we can output dual pixel (vrs)
define	VX_GPR_HINT_MIPMAP	1 slh 2		; perform mipmap computation
define	VX_GPR_HINT_DAMAGE	1 slh 3		; sha 256 area was damaged
define	VX_GPR_NO_HINT		1 slh 7		; disable hinting


define	VX_REGISTER_SIZE		8
define	VX_REGISTER1			1
define	VX_REGISTER0			4

define	VX_GPR_REGISTER_SIZE		8
virtual	at 0
	VX_GPR_REGISTER_JP:		rb	1
	VX_GPR_REGISTER_LENGTH:		rb	3
	VX_GPR_REGISTER_VRAM:		rb	3
	VX_GPR_UNUSED:			rb	1
end	virtual

; WARNING : this routine assume vertex buffer is in the first 64K of RAM
assert VX_PATCH_VERTEX_POOL < $D10000
assert VX_VERTEX_BUFFER < $D10000

vxPrimitiveTextureRaster:
.triangle_gpr:
; about 200 cycles to swap in place
	inc	hl
	inc	de
	inc	bc
.triangle_gpr_pre_setup:
	ld	a, (de)
	sub	a, (hl)
	jr	c, .triangle_gpr_swap_y0
	ex	de, hl
.triangle_gpr_swap_y0:
	ld	a, (bc)
	sub	a, (hl)
	jr	nc, .triangle_gpr_swap_y1
	ld	a, h
	ld	h, b
	ld	b, a
	ld	a, l
	ld	l, c
	ld	c, a
.triangle_gpr_swap_y1:
	ld	a, (de)
	sub	a, (hl)
	jr	nc, .triangle_gpr_swap_y2
	ex	de, hl
.triangle_gpr_swap_y2:
.triangle_gpr_hcull:
; cull if dy=0
	ld	a, (bc)
	sub	a, (hl)
	ret	z
.triangle_gpr_cache:
	cce	ge_pxl_raster
; save y2-y0 for later
	ld	i, a
.triangle_gpr_setup_mbase:
	ld	a, VX_REGISTER_DATA shr 16
	ld	mb, a
; copy x&y u&v to constant area : 219 cycles
	ld	iy, VX_REGISTER_DATA
	push	bc
	push	de
	lea	de, iy+VX_REGISTER_Y0
	ld	bc, 5
	ldir
	pop	hl
	ld	c, 5
	ldir
	pop	hl
	ld	c, 5
	ldir
	ld	(VX_SMC_STACK_REGISTER), sp
; .edge0Setup:
; ; perform necessary computation to interpolate over the edge0, which is line(x0,y0,x2,y2)
; ; ~ 250cc
; .edge0Compute_offset:
; ; register_offset=320*y0+x0+framebuffer;
; 	ld.s	de, (iy+VX_REGISTER_X0)
; 	ld	l, (iy+VX_REGISTER_Y0)
; 	ld	h, 160
; 	mlt	hl
; 	add	hl, hl
; 	add	hl, de
; 	ex	de, hl
; 	ld	ix, (vxFramebuffer)
; 	add	ix, de
; 	ld	(iy+VX_REGISTER_OFFSET), ix
; .edge0Compute_dx:
; ; compute the deltas for vxRegisterInterpolation
; ; dx = abs(x2-x0) [de]
; 	ld.s	de, (iy+VX_REGISTER_X2)	; load x2
; ; hl already hold _x0
; ;	ld	hl, (iy+VX_REGISTER_X0)	; load x0
; 	ld	a, $23 or $08	; inc ix
; ; carry reseted by add ix, de
; ;	or	a, a
; 	sbc	hl, de	; hl = x2-x0
; 	jr	nc, .edge0Swap
; 	add	hl, de	;
; 	ex	de, hl	;
; 	xor	a, $08	; dec ix
; 	sbc	hl, de	; hl = x0-x2
; .edge0Swap:
; 	ld	(VX_SMC_EDGE0_INC), a
; .edge0Compute_dy:
; ; dy = y0-y2 [bc]
; ; 	ld	a, (iy+VX_REGISTER_Y0)
; ; 	sub	a, (iy+VX_REGISTER_Y2)
; 	ld	a, i
; 	neg
; 	ld	bc, $FFFFFF
; 	ld	c, a
; .edge0Compute_error:
; ; prepare the error for pixel center correct in/out (leftruled)
; 	ex	de, hl
; 	sbc	hl, hl	; carry is set here, so hl=-1
; 	ld	l, a
; 	sbc	hl, de
; 	sra	h
; 	rr	l
; 	neg
; ; load the buffer increment on the y axis
; 	ld	sp, 320
; .edge0loop:
; ; dark magic part I
; 	add	hl, de
; 	jr	nc, .edge0End
; .edge0Propagate:
; 	db	$DD
; VX_SMC_EDGE0_INC=$
; 	nop
; 	add	hl, bc
; 	jr	c, .edge0Propagate
; .edge0End:
; 	ld	(iy+VX_GPR_REGISTER_VRAM), ix
; 	add	ix, sp
; 	lea	iy, iy+VX_REGISTER_SIZE
; 	dec	a
; 	jr	nz, .edge0loop
; .edge0magic:

.triangle_gpr_vram_setup:
	ld	a, i
	ld	hl, VX_LUT_INVERSE shr 1
	ld	l, a
	add	hl, hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
.triangle_gpr_mlt_dx0:
; piece of magic by calc84maniac
; hlbc (32 bits pair) = hl * bc
	ld.s	hl, (iy+VX_REGISTER_X2)
	ld.s	de, (iy+VX_REGISTER_X0)
	or	a, a
	sbc	hl, de
	xor	a, a
	ld	d, b
	ld	e, l
	ld	l, c
	ld.s	sp, hl
	ld	l, b
	bit	7, h
	mlt	hl
	jr	z, $+4
	sbc	hl, bc
	ld	b, e
	mlt	bc
	mlt	de
	mlt.s	sp
	ex	de, hl
	add.s	hl, sp
	adc	a, d
	ld	d, e
	ld	e, b
	add.s	hl, de
	ld	b, l
	ld	e, h
	adc	a, 0
	ld	d, a
	rla
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	(iy+VX_GPR_FDX0_LOWER+1), bc
	ld	(iy+VX_GPR_FDX0_UPPER), hl
; 	sra	h
; 	rr	l
; 	rr	b
; 	rr	c
; 	ld	(iy+VX_GPR_FDX0_HALF_LOWER+1), bc
; 	ld	(iy+VX_GPR_FDX0_HALF_UPPER), hl
.triangle_gpr_vram_adress:
; iy is already setup
; compute the vram adress
	ld	l, (iy+VX_REGISTER_Y0)
	ld	h, 160
	mlt	hl
	add	hl, hl
	ld.s	bc, (iy+VX_REGISTER_X0)
	add	hl, bc
	ld	bc, (vxFramebuffer)
	add	hl, bc
	ld	(iy+VX_REGISTER_OFFSET), hl
.triangle_gpr_vram_subpixel:
; hl - ix is setup, we now need to add DX0_HALF to it
; 	ld	de, (iy+VX_GPR_FDX0_HALF_UPPER)
; 	ld	ix, (iy+VX_GPR_FDX0_HALF_LOWER)
; ; perform the subpixel precision iteration
; 	add	hl, de
	ld	ix, 0
; now, we can load the true value
	ex	de, hl
	ld	hl, (iy+VX_GPR_FDX0_UPPER)
; increase the delta by 320 to compensate for line increase
	ld	bc, 320
	add	hl, bc
	ex	de, hl
; we need bcu to have the upper 8 bits of 0.16 and b to have lower 8 bits of 0.16
	ld	bc, (iy+VX_GPR_FDX0_LOWER)
	ld	a, i
	ld	sp, VX_REGISTER_SIZE
.triangle_gpr_vram:
	ld	(iy+VX_GPR_REGISTER_VRAM), hl
	add	ix, bc
	adc	hl, de
	add	iy, sp
	dec	a
	jr	nz, .triangle_gpr_vram

	ld	ix, VX_REGISTER_DATA
; 	ld	d, (ix+VX_REGISTER_Y2)
; 	ld	e, 160
; 	mlt	de
; 	ld	hl, (vxFramebuffer)
; 	add	hl, de
; 	add	hl, de
; 	ld.s	de, (ix+VX_REGISTER_X2)
; 	add	hl, de
	ld	(iy+VX_GPR_REGISTER_VRAM), hl
	ld	hl, vxPixelShaderExit
	ld	(iy+VX_GPR_REGISTER_LENGTH), hl

.edge1Setup:
;	ld	iy, VX_REGISTER_DATA	; load up shader data register
	lea	iy, ix+0
.edge1Compute_dy:
	ld	a, (iy+VX_REGISTER_Y0)
	sub	a, (iy+VX_REGISTER_Y1)
	jr	z, .edge1Null
; bc is already negated
	ld	bc, $FFFFFF
	ld	c, a
.edge1Compute_offset:
	ld	de, (iy+VX_REGISTER_OFFSET)
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
vxShaderAdress4Write:=$+2
	ld	ix, $CCCCCC + 2 ; (+2 is double carry sbc)
	add	ix, de
.edge1Compute_dx:
	ld.s	hl, (iy+VX_REGISTER_X0)
	ld.s	de, (iy+VX_REGISTER_X1)
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
	exx
	lea	hl, ix+0
	ld	de, (iy+VX_GPR_REGISTER_VRAM)
	add	hl, de
	add	hl, hl
	add	hl, hl
	ld	hl, (hl)
	ld	(iy+VX_GPR_REGISTER_LENGTH), hl
	exx
	add	ix, sp
	lea	iy, iy+VX_REGISTER_SIZE
	dec	a
	jr	nz, .edge1loop
.edge1Null:

.edge2Setup:
	ld	ix, VX_REGISTER_DATA	; load up shader data register
	ld	hl, (iy+VX_GPR_REGISTER_VRAM)
	ld	(ix+VX_REGISTER_MIDPOINT), hl
.edge2Compute_dy:
	ld	a, (ix+VX_REGISTER_Y1)
	ld	d, a
	sub	a, (ix+VX_REGISTER_Y2)
.edge2Compute_offset:
	ld	e, 160
	mlt	de
	ld	hl, (vxFramebuffer)
	add	hl, de
	add	hl, de
	ld.s	de, (ix+VX_REGISTER_X1)
	ld	b, d
	ld	c, e
	add	hl, de
	ld	(ix+VX_REGISTER_OFFSET), hl
	or	a, a
	jr	z, .edge2Null
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	ld.s	hl, (ix+VX_REGISTER_X2)
vxShaderAdress3Write:=$+2
	ld	ix, $CCCCCC
	add	ix, de
.edge2Compute_dx:
	ld	d, b
	ld	e, c
; bcu already at $FF, reset only b
	ld	bc, $FFFFFF
;	ld	b, $FF
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
	exx
	lea	hl, ix+0
	ld	de, (iy+VX_GPR_REGISTER_VRAM)
	add	hl, de
	add	hl, hl
	add	hl, hl
	ld	hl, (hl)
	ld	(iy+VX_GPR_REGISTER_LENGTH), hl
	exx
	add	ix, sp
	lea	iy, iy+VX_REGISTER_SIZE
	dec	a
	jr	nz, .edge2loop
.edge2Null:
	ccr	ge_pxl_raster
	cce	ge_pxl_shading
; we'll count computing gradient as shading part
	ld	iy, VX_REGISTER_DATA	; load up shader data register
.triangleInv_dx:
	ld	de, (iy+VX_REGISTER_MIDPOINT)
	ld	hl, (iy+VX_REGISTER_OFFSET)
	or	a, a
	sbc	hl, de
	jp	z, vxPixelShaderExit
; now abs(hl)
	ld	a, $13
;	ld	a, $A0 ; for ldi / ldd
	jr	nc, .triangleAbs
	ex	de, hl
	or	a, $08
	sbc	hl, hl
	sbc	hl, de
.triangleAbs:
; 	ld	(iy+VX_SHADER_INTERPOLATE_VEC), a
; write inc/dec
vxShaderAdress0Write=$+1
	ld	($D00000), a
vxShaderAdress1Write=$+1
	ld	($D00000), a
; if a = 1B, write 1B ; else write 0
	xor	a, $13	; for ldi / ldd
;	xor	a, $A0
	jr	z, $+4
	ld	a, $1B
vxShaderAdress2Write=$+1
	ld	($D00000), a
	add	hl, hl
	ld	de, VX_LUT_INVERSE + 2
	add	hl, de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	exx
.triangle_gpr_gradient:
; 625 cycles for the gradient compute
; inv = 65536/(y2-y0);
	ld	hl, VX_LUT_INVERSE shr 1
	ld	a, i
	ld	l, a
	add	hl, hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
.triangle_gpr_mlt_dvdy:
; dvdy = (v2-v0)*inv/256;
	ld	a, (iy+VX_REGISTER_V2)
	sub	a, (iy+VX_REGISTER_V0)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, .triangle_gpr_null_dvdy
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
.triangle_gpr_null_dvdy:
	ld	(iy+VX_FDVDY), hl
.triangle_gpr_mlt_dvdx:
; (v1-(y1-y0)*dvdy)*invx/256
	ld	a, (iy+VX_REGISTER_Y1)
	sub	a, (iy+VX_REGISTER_Y0)
	ld	b, a
	ld	c, h
	ld	h, a
	mlt	bc
	mlt	hl
; store y1-y0 into b
	ld	b, a
	ld	a, (iy+VX_REGISTER_V0)
	rl	l
	adc	a, h
	add	a, c
	exx
	ld	c, a
	ld	a, (iy+VX_REGISTER_V1)
	sub	a, c
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, .triangle_gpr_null_dvdx
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
.triangle_gpr_null_dvdx:
	ld	(iy+VX_FDVDX), hl
	exx
.triangle_gpr_mlt_dudy:
; dudy = (u2-u0)*inv/256;
	ld	a, (iy+VX_REGISTER_U2)
	sub	a, (iy+VX_REGISTER_U0)
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, .triangle_gpr_null_dudy
	jr	nc, $+5
	or	a, a
	sbc	hl, de
	ld	d, a
	mlt	de
	rl	e
	ld	e, d
	ld	d, 0
	adc	hl, de
.triangle_gpr_null_dudy:
	ld	(iy+VX_FDUDY), hl
.triangle_gpr_mlt_dudx:
; 	ld	a, (iy+VX_REGISTER_Y1)
; 	sub	a, (iy+VX_REGISTER_Y0)
; 	ld	b, a
	ld	c, h
; 	ld	h, a
	ld	h, b
	mlt	bc
	mlt	hl
	ld	a, (iy+VX_REGISTER_U0)
	rl	l
	adc	a, h
	add	a, c
	exx
	ld	c, a
	ld	a, (iy+VX_REGISTER_U1)
	sub	a, c
	ld	h, d
	ld	l, a
	mlt	hl
	jr	z, .triangle_gpr_null_dudx
	jr	nc, $+5
	or	a, a
	sbc	hl, de
	ld	d, a
	mlt	de
	rl	e
	ld	e, d
	ld	d, 0
	adc	hl, de
.triangle_gpr_null_dudx:
	ld	(iy+VX_FDUDX), hl
; .triangleMipmap:
; 	ld	sp, TMP
; 	call	vxMipmap.gradient
; 	call	vxVariableShading.rate
.triangle_gpr_subtexel:
; 403 cycles worst case with last jump
	ld	bc, (iy+VX_FDVDX)
	ld	hl, (iy+VX_FDVDY)
	ld	d, h
	ld	e, b
; NOTE : carry is undefined but we don't really care for on 1/256 off error on 8.8
; 	or	a, a
	sbc	hl, bc
	sra	h
	rr	l
	ld	a, (iy+VX_REGISTER_V0)
	add	a, h
	ld	h, a
	ld	i, hl
.triangle_gpr_subtexel_shift:
; now adapt because of the layout in memory : [lDVDY][hDVDY][lDUDY][hDUDY]
; if dvdy is < 0 then adding will always propagate a carry inside dudy, which is a no-no
	ld	hl, (iy+VX_FDUDY)
; check the sign of FDVDY
	bit	7, d
	jr	z, .triangle_gpr_subtexel_dy
	dec	hl
; only write 1 byte because the other one is register passed, we only change in memory for the 24 bits load
	ld	(iy+VX_FDUDY), l
.triangle_gpr_subtexel_dy:
	ld	a, h
vxShaderAdress5Write=$+1
	ld	($D00000), a
	ld	bc, (iy+VX_FDUDX)
; check the sign if FDVDX
	bit	7, e
	jr	z, .triangle_gpr_subtexel_dx
	dec	bc
; only write 1 byte because the other one is register passed, we only change in memory for the 24 bits load
	ld	(iy+VX_FDUDX), c
.triangle_gpr_subtexel_dx:
; 	ld	bc, (iy+VX_FDUDX)
; 	ld	hl, (iy+VX_FDUDY)
; NOTE : carry is undefined but max is 1/256 off error on 8.8, also possibility for more error due to the dec bc / dec hl
; 	or	a, a
	sbc	hl, bc
	sra	h
	rr	l
	ld	a, l
	ld	mb, a
	ld	a, (iy+VX_REGISTER_U0)
	add	a, h
	exa
.triangle_gpr_render_pixel:
; initialise drawing span parameters
	ld	hl, i
	ex	de, hl
	ld	ix, 0
	add	ix, de
.SMC0:=$+1
	ld	a, $D3
	ld	mb, a
	or	a, a
	sbc	hl, hl
	ld	i, hl
	ld	l, b
	ld	sp, hl
;	lea	hl, ix+0
; de still hold the correct ix 24 bits value
	ex	de, hl
	ld	de, (iy+VX_FDVDX)
	ld	bc, (iy+VX_FDVDY)
	ld	a, b
vxShaderAdress6Write=$+1
	ld	($D00000), a
	exx
; 	ld	a, ($E11617)
; 	cp	a, $A0
; 	jr	nz, .jp_2
; 	dec	 sp
; 	exa
; 	inc	a
; 	jr	.jp
; .jp_2:	
; 	inc	sp
; 	exa
; 	dec	a
; .jp:
	exa
vxShaderUniform0=$+1
	ld	bc, VX_PIXEL_SHADER_DATA
vxShaderJumpWrite=$+1
	jp	$000000
vxPixelShaderExit:
VX_SMC_STACK_REGISTER=$+1
	ld	sp, $000000
	ccr	ge_pxl_shading
	ret
