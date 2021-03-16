; shader will copy 1024 bytes from global_data to VX_VRAM. This load occurs at begin of stream instruction, to ensure maximum vertex throughput. About 2200 cycles per vertex are needed.

vxModelView:
 db    0,0,0
 db    0,0,0
 db    0,0,0
 dl    0,0,0
vxLight:
 db    0,0,0
 db    0,0,0
 dw    0,0,0

vxVertexShader:

.write_uniform:
; matrix write
	ld	ix, vxModelView
	ld	c, 0
	ld	a, (ix+VX_MATRIX0_C0)
	bit	7, a
	jr	z, $+6
	neg
	set	7, c
	ld	(.MC0), a
	ld	a, (ix+VX_MATRIX0_C1)
	bit	7, a
	jr	z, $+6
	neg
	set	6, c
	ld	(.MC1), a
	ld	a, (ix+VX_MATRIX0_C2)
	bit	7, a
	jr	z, $+6
	neg
	set	5, c
	ld	(.MC2), a
	ld	a, c
	ld	(.MS0), a
	ld	c, 0
	ld	a, (ix+VX_MATRIX0_C3)
	bit	7, a
	jr	z, $+6
	neg
	set	7, c
	ld	(.MC3), a
	ld	a, (ix+VX_MATRIX0_C4)
	bit	7, a
	jr	z, $+6
	neg
	set	6, c
	ld	(.MC4), a
	ld	a, (ix+VX_MATRIX0_C5)
	bit	7, a
	jr	z, $+6
	neg
	set	5, c
	ld	(.MC5), a
	ld	a, c
	ld	(.MS1), a
	ld	c, 0
	ld	a, (ix+VX_MATRIX0_C6)
	bit	7, a
	jr	z, $+6
	neg
	set	7, c
	ld	(.MC6), a
	ld	a, (ix+VX_MATRIX0_C7)
	bit	7, a
	jr	z, $+6
	neg
	set	6, c
	ld	(.MC7), a
	ld	a, (ix+VX_MATRIX0_C8)
	bit	7, a
	jr	z, $+6
	neg
	set	5, c
	ld	(.MC8), a
	ld	a, c
	ld	(.MS2), a
	ld	hl, (ix+VX_MATRIX0_TX)
	ld	(.MTX), hl
	ld	hl, (ix+VX_MATRIX0_TY)
	ld	(.MTY), hl
	ld	hl, (ix+VX_MATRIX0_TZ)
	ld	(.MTZ), hl
	ld	a, VX_SCREEN_HEIGHT
	ld	(.SHY), a
	xor	a, a
	ld	(.SLY), a
; lightning write
; 	ld	a, (ix+VX_LIGHT0_VECTOR)
; 	ld	(.LV0), a
; 	ld	a, (ix+VX_LIGHT0_VECTOR+1)
; 	ld	(.LV1), a
; 	ld	a, (ix+VX_LIGHT0_VECTOR+2)
; 	ld	(.LV2), a
; 	ld	a, (ix+VX_LIGHT0_AMBIENT)
; 	ld	(.LA), a
; 	ld	a, (ix+VX_LIGHT0_POW)
; 	ld	(.LE), a
	ret

.ftransform:

relocate VX_VERTEX_SHADER_CODE	
	
.trampoline_stack:
 dl	.trampoline_v0_ret
 dl	.trampoline_v1_ret
 dl	.trampoline_v2_ret
 dl	0
.stack:

; iy = vertex data register [VX,VY,VZ,VN[0-2]]
; ix = output data register [RC,SY,SX,RI[0-1],RX,RY,RZ]

.fma_divide:
	ld	sp, .trampoline_stack
; compute the Z coordinate from matrix register with FMA engine ;
;	ld	a, (iy+VX_VERTEX_SM)
.MS2:=$+1
	xor	a, $CC
	ld	hl, .engine_000 shr 1
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
	xor	a, $CC
	ld	hl, .engine_000 shr 1
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
	xor	a, $CC
	ld	hl, .engine_000 shr 1
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

; ; lightning model is here, infinite directionnal light, no pow
; 	xor	a, a
; 	ld	c, (iy+VX_VERTEX_NX)
; .LV0=$+1
; 	ld	b, $CC
; 	bit	7, c
; 	jr	z, $+3
; 	sub	a, b
; 	bit	7, b
; 	jr	z, $+3
; 	sub	a, c
; 	mlt	bc
; 	add	a, b
; 	ld	c, (iy+VX_VERTEX_NY)
; .LV1=$+1
; 	ld	b, $CC
; 	bit	7, c
; 	jr	z, $+3
; 	sub	a, b
; 	bit	7, b
; 	jr	z, $+3
; 	sub	a, c
; 	mlt	bc
; 	add	a, b
; 	ld	c, (iy+VX_VERTEX_NZ)
; .LV2=$+1
; 	ld	b, $CC
; 	bit	7, c
; 	jr	z, $+3
; 	sub	a, b
; 	bit	7, b
; 	jr	z, $+3
; 	sub	a, c
; 	mlt	bc
; 	add	a, b
; ; max(a,0)
; 	jp	p, $+5
; 	xor	a, a
; 	ld	c, a
; .LE=$+1
; 	ld	b, $CC
; 	mlt	bc
; 	ld	a, b
; 	rl	c
; .LA=$+1
; 	adc	a, $CC
; ; min(a,15)
; 	cp	a, 32
; 	jr	c, $+4
; 	ld	a, 31
; 	ld	(ix+VX_VERTEX_UNIFORM), a

.perspective_divide:
;	ld	hl, (ix+VX_VERTEX_RY)
	ld	bc, (ix+VX_VERTEX_RZ)
	ld	a, (ix+VX_VERTEX_RZ+2)
	rla
	jr	c, .perspective_zclip
.perspective_divide_ry:
	xor	a, a
	ld	(ix+VX_VERTEX_CODE), a
	add	hl, hl
	jr	nc, .absolute_ry
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
.absolute_ry:
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
	xor	a, a
	sbc	hl, bc
; X < Z
	jp	m, .clip_ry_0
	or	a, 00100010b
.clip_ry_0:
	add	hl, bc
	add	hl, bc
	add	hl, hl
	jr	nc, .clip_ry_1
	or	a, 00010001b
.clip_ry_1:
	ld	hl, (ix+VX_VERTEX_RX)
	sbc	hl, bc
	jp	m, .clip_rx_0
	or	a, 10001000b
.clip_rx_0:
	add	hl, bc
	add	hl, bc
	add	hl, hl
	jr	nc, .clip_rx_1
	or	a, 01000100b
.clip_rx_1:
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
	ld	l, VX_SCREEN_HEIGHT/2+1 ;precision stuffs
	ld	h, a
	mlt	hl
	ld	a, h
	jr	nc, $+3
	cpl
	adc	a, VX_SCREEN_HCENTER
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
	jr	nc, .absolute_rx
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
.absolute_rx:
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
	ld	h, VX_SCREEN_WIDTH/2+1
	mlt	hl
	ld	a, h
	sbc	hl, hl
	jr	nc, $+3
	cpl
	ld	l, a
	ld	de, VX_SCREEN_WCENTER
	adc	hl, de
	ld	(ix+VX_VERTEX_SX), hl
	ret

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
align 64
endrelocate
