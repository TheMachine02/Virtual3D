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
	ld	a, (ix+VX_MATRIX0_C0)
	ld	(vxVertexCompute.MC0), a
	ld	a, (ix+VX_MATRIX0_C1)
	ld	(vxVertexCompute.MC1), a
	ld	a, (ix+VX_MATRIX0_C2)
	ld	(vxVertexCompute.MC2), a
	ld	a, (ix+VX_MATRIX0_C3)
	ld	(vxVertexCompute.MC3), a
	ld	a, (ix+VX_MATRIX0_C4)
	ld	(vxVertexCompute.MC4), a
	ld	a, (ix+VX_MATRIX0_C5)
	ld	(vxVertexCompute.MC5), a
	ld	a, (ix+VX_MATRIX0_C6)
	ld	(vxVertexCompute.MC6), a
	ld	a, (ix+VX_MATRIX0_C7)
	ld	(vxVertexCompute.MC7), a
	ld	a, (ix+VX_MATRIX0_C8)
	ld	(vxVertexCompute.MC8), a
	ld	hl, (ix+VX_MATRIX0_TX)
	ld	(vxVertexCompute.MTX), hl
	ld	hl, (ix+VX_MATRIX0_TY)
	ld	(vxVertexCompute.MTY), hl
	ld	hl, (ix+VX_MATRIX0_TZ)
	ld	(vxVertexCompute.MTZ), hl
; lightning write
; 	ld	a, (ix+VX_LIGHT0_VECTOR)
; 	ld	(vxVertexCompute.LV0), a
; 	ld	a, (ix+VX_LIGHT0_VECTOR+1)
; 	ld	(vxVertexCompute.LV1), a
; 	ld	a, (ix+VX_LIGHT0_VECTOR+2)
; 	ld	(vxVertexCompute.LV2), a
; 	ld	a, (ix+VX_LIGHT0_AMBIENT)
; 	ld	(vxVertexCompute.LA), a
; 	ld	a, (ix+VX_LIGHT0_POW)
; 	ld	(vxVertexCompute.LE), a
	ret

.ftransform:
; relocate the shader to fast VRAM ($E30800)

relocate VX_VERTEX_SHADER_CODE

; global shader call

vxVertexCompute:
; ix = global data register [MC[0-8],MTX,MTY,MTZ,LV[0-2],LA,LE]
; iy = vertex data register [VX,VY,VZ,VN[0-2]]
; de = output data register [RC,SY,SX,RI[0-1],RX,RY,RZ]
; bc = x vertex coordinate [16bits]
; OUT register
; de = de + VX_VERTEX_SIZE
; iy = iy + VX_VERTEX_DATA_SIZE
; data copied to memory
; X coordinate
;	ld	bc, (iy+0)
.MTX:=$+1
	ld	de, $CC
.MC0:=$+1
	ld	a, $CC
	ld	h, b
	ld	l, a
	mlt	hl
	cp	a, $80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	bc, (iy+VX_VERTEX_VY)
.MC1:=$+1
	ld	a, $CC
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	bc, (iy+VX_VERTEX_VZ)
.MC2:=$+1
	ld	a, $CC
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	(ix+VX_VERTEX_RX), hl
; Z coordinate
.MTZ:=$+1
	ld	de, $CC
.MC8:=$+1
	ld	a, $CC
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
.MC7:=$+1
	ld	a, $CC
	ld	bc, (iy+VX_VERTEX_VY)
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
.MC6:=$+1
	ld	a, $CC
	ld	bc, (iy+VX_VERTEX_VX)
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	(ix+VX_VERTEX_RZ), hl
; Y coordinate
.MTY:=$+1
	ld	de, $CC
.MC3:=$+1
	ld	a, $CC
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
.MC4:=$+1
	ld	a, $CC
	ld	bc, (iy+VX_VERTEX_VY)
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
.MC5:=$+1
	ld	a, $CC
	ld	bc, (iy+VX_VERTEX_VZ)
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
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
;  ; min(a,15)
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
	or	a, 00100000b
.clip_ry_0:
	add	hl, bc
	or	a, a
	adc	hl, bc
	jp	p, .clip_ry_1
	or	a, 00010000b
.clip_ry_1:
	ld	hl, (ix+VX_VERTEX_RX)
	or	a, a
	sbc	hl, bc
	jp	m, .clip_rx_0
	or	a, 10000000b
.clip_rx_0:
	add	hl, bc
	or	a, a
	adc	hl, bc
	jp	p, .clip_rx_1
	or	a, 01000000b
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
; do scissor here TODO
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
endrelocate
