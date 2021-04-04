vxVertexShader:

; this is non-critical code, called only one time per vertex stream execution
.uniform:
; matrix write
	ld	hl, vxModelView
	ld	de, VX_LONG_STRIDE
	ld	c, d
	ld	a, (hl)
	bit	7, a
	jr	z, $+6
	neg
	set	7, c
	ld	(.MC0), a
	inc	hl
	ld	a, (hl)
	bit	7, a
	jr	z, $+6
	neg
	set	6, c
	ld	(.MC1), a
	inc	hl
	ld	a, (hl)
	bit	7, a
	jr	z, $+6
	neg
	set	5, c
	ld	(.MC2), a
	ld	a, c
	ld	(.MS0), a
	ld	c, d
	inc	hl
	ld	a, (hl)
	bit	7, a
	jr	z, $+6
	neg
	set	7, c
	ld	(.MC3), a
	inc	hl
	ld	a, (hl)
	bit	7, a
	jr	z, $+6
	neg
	set	6, c
	ld	(.MC4), a
	inc	hl	
	ld	a, (hl)
	bit	7, a
	jr	z, $+6
	neg
	set	5, c
	ld	(.MC5), a
	ld	a, c
	ld	(.MS1), a
	ld	c, d
	inc	hl
	ld	a, (hl)
	bit	7, a
	jr	z, $+6
	neg
	set	7, c
	ld	(.MC6), a
	inc	hl
	ld	a, (hl)
	bit	7, a
	jr	z, $+6
	neg
	set	6, c
	ld	(.MC7), a
	inc	hl
	ld	a, (hl)
	bit	7, a
	jr	z, $+6
	neg
	set	5, c
	ld	(.MC8), a
	ld	a, c
	ld	(.MS2), a
	inc	hl
	ld	bc, (hl)
	ld	(.MTX), bc
	add	hl, de
	ld	bc, (hl)
	ld	(.MTY), bc
	add	hl, de
	ld	bc, (hl)
	ld	(.MTZ), bc
; lightning write
	add	hl, de
	ld	de, .LV0
	ldi
	ld	de, .LV1
	ldi
	ld	de, .LV2
	ldi
	ld	de, .LA
	ldi
	ld	de, .LE
	ldi
; scissor set
; NOTE : this should be + 1
	ld	a, VX_SCREEN_HEIGHT+1
	ld	(.SHY), a
	xor	a, a
	ld	(.SLY), a
; NOTE : this should be + 1 for true bound, here the bound is 0-320
	ld	hl, VX_SCREEN_WIDTH+1
	ld	(.SHX), hl
	sbc	hl, hl
	ld	(.SLX), hl
	ret

; NOTE : the vertex shader ftransform should be relocated to VRAM at the begining of the routine (after the label, since the label is used in material as copying, for 1024 bytes of data / code)
; This load occurs at begin of stream instruction, to ensure maximum vertex throughput. About 1800 cycles per vertex are needed.
; iy = vertex data register [VX,VY,VZ,VN[0-2]]
; ix = output data register [RC,SY,SX,RI[0-1],RX,RY,RZ]
; SMC registers are set with uniform routine
.ftransform:
relocate VX_VERTEX_SHADER_CODE
.ftransform_trampoline:
	ld	sp, .trampoline_stack
; compute the Z coordinate from matrix register with FMA engine ;
;	ld	a, (iy+VX_VERTEX_SM)
.MS2:=$+1
	ld	hl, .engine_000 shr 1 or $CC
	xor	a, l
	ld	l, a
	add	hl, hl
.MC6:=$+1
.MC7:=$+2
	ld	de, $CCCCCC
.MC8:=$+1
	ld	a, $CC
	jp	(hl)
.trampoline_v0_ret:
.MTZ:=$+1
	ld	de, $CCCCCC
	add	hl, de
	ld	(ix+VX_VERTEX_RZ), hl
; X coordinate ;
	ld	a, (iy+VX_VERTEX_SM)
.MS0:=$+1
	ld	hl, .engine_000 shr 1 or $CC
	xor	a, l
	ld	l, a
	add	hl, hl
.MC0:=$+1
.MC1:=$+2
	ld	de, $CCCCCC
.MC2:=$+1
	ld	a, $CC
	jp	(hl)
.trampoline_v1_ret:
.MTX:=$+1
	ld	de, $CCCCCC
	add	hl, de
	ld	(ix+VX_VERTEX_RX), hl
; Y coordinate ;
	ld	a, (iy+VX_VERTEX_SM)
.MS1:=$+1
	ld	hl, .engine_000 shr 1 or $CC
	xor	a, l
	ld	l, a
	add	hl, hl
.MC3:=$+1
.MC4:=$+2
	ld	de, $CCCCCC
.MC5:=$+1
	ld	a, $CC
	jp	(hl)
.trampoline_v2_ret:
.MTY:=$+1
	ld	de, $CCCCCC
	add	hl, de
	ld	(ix+VX_VERTEX_RY), hl

; lightning model is here, infinite directionnal light, no pow
	xor	a, a
	ld	de, (iy+VX_VERTEX_NX)
.LV0=$+1
	ld	b, $CC
	bit	7, e
	jr	z, $+3
	sub	a, b
	bit	7, b
	jr	z, $+3
	sub	a, e
	ld	c, e
	mlt	bc
	add	a, b
.LV1=$+1
	ld	e, $CC
	bit	7, d
	jr	z, $+3
	sub	a, e
	bit	7, e
	jr	z, $+3
	sub	a, d
	mlt	de
	add	a, d
	ld	c, (iy+VX_VERTEX_NZ)
.LV2=$+1
	ld	b, $CC
	bit	7, c
	jr	z, $+3
	sub	a, b
	bit	7, b
	jr	z, $+3
	sub	a, c
	mlt	bc
	add	a, b
; max(a,0)
	jp	p, .light_scale
	xor	a, a
	jr	.light_ambient
.light_scale:
	add	a, a
	add	a, a
	ld	c, a
; LE have a 64 scaling
.LE=$+1
	ld	b, $CC
	mlt	bc
	ld	a, b
	rl	c
.light_ambient:
.LA=$+1
	adc	a, $CC
; min(a,15)
	cp	a, 32
	jr	c, $+4
	ld	a, 31
	ld	(ix+VX_VERTEX_GPR2), a
; use this target for gouraud shading, this is v register
	ld	(ix+VX_VERTEX_GPR1), a

.perspective_divide:
;	ld	hl, (ix+VX_VERTEX_RY)
	ld	bc, (ix+VX_VERTEX_RZ)
	xor	a, a	
	bit	7, (ix+VX_VERTEX_RZ+2)
	jr	nz, .perspective_zclip
.perspective_divide_ry:
	ld	(ix+VX_VERTEX_CODE), a
	add	hl, hl
	jr	nc, .perspective_absolute_ry
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
.perspective_absolute_ry:
	sbc	hl, bc
	jr	c, .perspective_iterate_ry
	sbc	hl, bc
	ccf
	jr	nc, .perspective_iterate_ry
; clip code compute for ry
	rra
	ld	a, 00100010b
; 00010001b if negative
	jr	nc, $+3
	rrca
	ld	(ix+VX_VERTEX_CODE), a
	jr	.perspective_divide_rx
; we got a gap here, were we can put zclip
.perspective_zclip:
	sbc	hl, bc
; X < Z
	jp	m, .perspective_clip_ry_0
	or	a, 00100010b
.perspective_clip_ry_0:
	add	hl, bc
	add	hl, bc
	add	hl, hl
	jr	nc, .perspective_clip_ry_1
	or	a, 00010001b
.perspective_clip_ry_1:
	ld	hl, (ix+VX_VERTEX_RX)
	sbc	hl, bc
	jp	m, .perspective_clip_rx_0
	or	a, 10001000b
.perspective_clip_rx_0:
	add	hl, bc
	add	hl, bc
	add	hl, hl
	jr	nc, .perspective_clip_rx_1
	or	a, 01000100b
.perspective_clip_rx_1:
	ld	(ix+VX_VERTEX_CODE), a
	ret
.perspective_iterate_ry:
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
.perspective_scissor_ry:
; high y guardband if equivalent to negative Y due to inversed Y screen coordinate, 0001b if negative
.SHY=$+1
	cp	a, $CC + 1
	jr	c, .perspective_high_y
	set	0, (ix+VX_VERTEX_CODE)
.perspective_high_y:
.SLY=$+1
	cp	a, $CC
	jr	nc, .perspective_divide_rx
	set	1, (ix+VX_VERTEX_CODE)
.perspective_divide_rx:
	ld	hl, (ix+VX_VERTEX_RX)
	xor	a, a
	add	hl, hl
	jr	nc, .perspective_absolute_rx
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
.perspective_absolute_rx:
	sbc	hl, bc
	jr	c, .perspective_iterate_rx
; potential clipping issue
	sbc	hl, bc
	ccf
	jr	nc, .perspective_iterate_rx
	rra
	ld	a, 10001000b
; 01000100b if negative
	jr	nc, $+3
	rrca
	or	a, (ix+VX_VERTEX_CODE)
	ld	(ix+VX_VERTEX_CODE), a
	ret
.perspective_iterate_rx:
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
	ld	(ix+VX_VERTEX_SX), hl
.SLX=$+1
	ld	de, $CCCCCC
	or	a, a
	sbc	hl, de
	add	hl, de
	jr	nc, .perspective_high_x
	set	2, (ix+VX_VERTEX_CODE)
	ret
.perspective_high_x:
.SHX=$+1
	ld	de, $CCCCCC
	sbc	hl, de
	ret	c
	set	3, (ix+VX_VERTEX_CODE)
	ret

.trampoline_stack:
 dl	.trampoline_v0_ret
 dl	.trampoline_v1_ret
 dl	.trampoline_v2_ret
 dl	0
.stack:

; free space between alignement

align 512
.engine_000:
; 232 cycles
	ld	h, (iy+VX_VERTEX_VX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_VERTEX_VY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_VERTEX_VZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ret

align 64
.engine_001:
; 241 cycles
	ld	h, (iy+VX_VERTEX_VX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_VERTEX_VY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_VERTEX_VZ+1)
	ld	c, a
	mlt	bc
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	ret
 
align 64
.engine_010:
; 241 cycles
	ld	h, (iy+VX_VERTEX_VX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_VERTEX_VY+1)
	ld	c, d
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_VERTEX_VZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	or	a, a
	sbc	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ret

align 64
.engine_011:
; 253 cycles
	ld	h, (iy+VX_VERTEX_VX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_VERTEX_VY+1)
	ld	c, d
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_VERTEX_VZ+1)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	or	a, a
	sbc	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	ret

align 64
.engine_100:
; 241 cycles
	ld	h, (iy+VX_VERTEX_VZ+1)
	ld	l, a
	mlt	hl
	ld	b, (iy+VX_VERTEX_VX+1)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_VERTEX_VY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ret

align 64
.engine_101:
; 253 cycles
	ld	h, (iy+VX_VERTEX_VY+1)
	ld	l, d
	mlt	hl
	ld	b, (iy+VX_VERTEX_VX+1)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_VERTEX_VZ+1)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	ret

align 64
.engine_110:
; 253 cycles
	ld	h, (iy+VX_VERTEX_VZ+1)
	ld	l, a
	mlt	hl
	ld	b, (iy+VX_VERTEX_VX+1)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_VERTEX_VY+1)
	ld	c, d
	mlt	bc
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	or	a, a
	sbc	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ret

align 64
.engine_111:
; 247 cycles
	ld	h, (iy+VX_VERTEX_VX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_VERTEX_VY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_VERTEX_VZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ret

assert $ < $E30C00
endrelocate
