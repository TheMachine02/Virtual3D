; Virtual-3D library, version 1.0
;
; MIT License
; 
; Copyright (c) 2017 - 2024 TheMachine02
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

vxVertexShader:
; please note, vertex shader uniform should realloc to vram itself with uniform call

; this is non-critical code, called only one time per vertex stream execution
.uniform:
	ld	hl, .vram
	ld	de, VX_VRAM
	ld	bc, VX_VRAM_SIZE
	ldir
	ld	hl, .vram_cache
	ld	de, VX_VRAM_CACHE
	ld	bc, VX_VRAM_CACHE_SIZE
	ldir
.uniform_matrix:
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
; 	add	hl, de
; 	ld	de, .LV0
; 	ldi
; 	ld	de, .LV1
; 	ldi
; 	ld	de, .LV2
; 	ldi
; 	ld	de, .LA
; 	ldi
; 	ld	de, .LE
; 	ldi
; screen space reflection (test)
; we use the model to view to get x,y of normal vector
; so we only need the first two row of the matrix
	ld	hl, vxModelViewScreenSpace
	ld	a, (hl)
	ld	(.SSMC0), a
	inc	hl
	ld	a, (hl)
	ld	(.SSMC1), a
	inc	hl
	ld	a, (hl)
	ld	(.SSMC2), a
	inc	hl
	ld	a, (hl)
	ld	(.SSMC3), a
	inc	hl
	ld	a, (hl)
	ld	(.SSMC4), a
	inc	hl
	ld	a, (hl)
	ld	(.SSMC5), a
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

.vram:
; NOTE : the vertex shader ftransform should be relocated to VRAM at the begining of the routine (after the label, since the label is used in material as copying, for 1024 bytes of data / code)
; This load occurs at begin of stream instruction, to ensure maximum vertex throughput. About 1800 cycles per vertex are needed.
; iy = vertex data register [VX,VY,VZ,VN[0-2]]
; ix = output data register [RC,SY,SX,RI[0-1],RX,RY,RZ]
; SMC registers are set with uniform routine
relocate VX_VRAM
.ftransform:
	ld	a, (iy+VX_VERTEX_SIGN)
	dec	a
; no vertex stream ?
	ret	z
	ld	(.SP_RET), sp
.ftransform_trampoline:
	bit	VX_VERTEX_POISON_BIT, (ix+VX_VERTEX_CODE)
	jp	nz, .ftransform_ret
	ld	sp, .trampoline_stack
; compute the Z coordinate from matrix register with FMA engine
	inc	a
	ld	i, a
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
	ld	a, i
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
	ld	a, i
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
.perspective_divide:
;	ld	hl, (ix+VX_VERTEX_RY)
	ld	bc, (ix+VX_VERTEX_RZ)
	xor	a, a
	bit	7, (ix+VX_VERTEX_RZ+2)
	jr	nz, .perspective_zclip
.perspective_divide_ry:
	add	hl, hl
	jr	nc, .perspective_absolute_ry
	rla
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	or	a, a
.perspective_absolute_ry:
	sbc	hl, bc
	jp	c, .perspective_iterate
	sbc	hl, bc
	ccf
	jp	nc, .perspective_iterate
; clip code compute for ry
	rra
	ld	a, 00100010b
; 00010001b if negative
	jr	nc, $+3
	rrca
	ld	(ix+VX_VERTEX_CODE), a
; restore the correct stack adress
	pop	hl
	jr	.perspective_divide_rx
; scissor code
.perspective_high_y:
	set	0, (ix+VX_VERTEX_CODE)
	jr	.perspective_divide_rx
.perspective_low_y:
	set	1, (ix+VX_VERTEX_CODE)
	jr	.perspective_divide_rx
; we got a gap here, were we can put zclip
.perspective_zclip:
	sbc	hl, bc
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
	jr	.ftransform_ret
.perspective_low_x:
	set	2, (ix+VX_VERTEX_CODE)
	jr	.ftransform_ret
.perspective_high_x:
	set	3, (ix+VX_VERTEX_CODE)
	jr	.ftransform_ret
.perspective_screen_ry:
	cpl
	ld	l, a
	ld	h, VX_SCREEN_HEIGHT shr 1
	mlt	hl
	ld	a, h
	jr	c, $+4
	neg
	add	a, VX_SCREEN_HEIGHT_CENTER
	ld	(ix+VX_VERTEX_SY), a
.perspective_scissor_ry:
; high y guardband if equivalent to negative Y due to inversed Y screen coordinate, 0001b if negative
.SHY=$+1
	cp	a, $CC + 1
	jr	nc, .perspective_high_y
.SLY=$+1
	cp	a, $CC
	jr	c, .perspective_low_y
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
	jp	c, .perspective_iterate
; potential clipping issue
	sbc	hl, bc
	ccf
	jp	nc, .perspective_iterate
	rra
	ld	a, 10001000b
; 01000100b if negative
	jr	nc, $+3
	rrca
	or	a, (ix+VX_VERTEX_CODE)
	ld	(ix+VX_VERTEX_CODE), a
	jr	.ftransform_ret
.perspective_screen_rx:
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
	jr	c, .perspective_low_x
.SHX=$+1
	ld	de, $CCCCCC
	sbc	hl, de
	jr	nc, .perspective_high_x
.ftransform_ret:
; simple algorithm examples : fog, infinite directionnal lightning, screen space reflection

; lightning model is here, infinite directionnal light, no pow
; TODO : could be made faster, either constant time multiplie (constant*normal) or other trick : 4.4 fixed point ?
; .lightning:
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
; 	jp	p, .light_scale
; 	xor	a, a
; 	jr	.light_ambient
; .light_scale:
; 	add	a, a
; 	add	a, a
; 	ld	c, a
; ; LE have a 64 scaling
; .LE=$+1
; 	ld	b, $CC
; 	mlt	bc
; 	ld	a, b
; 	rl	c
; .light_ambient:
; .LA=$+1
; 	adc	a, $CC
; 	cp	a, 32
; 	jr	c, $+4
; 	ld	a, 31
; 	ld	(ix+VX_VERTEX_GPR2), a

; .fog:
; ; simple fog algorithm
; 	ld	hl, (ix+VX_VERTEX_RZ+1)
; 	ld	a, 4
; 	sub	a, h
; 	jr	nc, $+3
; 	xor	a, a
; 	add	a, a
; 	add	a, a
; ; clamp
; 	cp	a, 32
; 	jr	c, $+4
; 	ld	a, 31
; 	ld	(ix+VX_VERTEX_GPR2), a
; use this target for gouraud shading, this is v register
;	ld	(ix+VX_VERTEX_GPR1), a

; screen space reflection
.SSMC0=$+1
	ld	h, $CC
	ld	l, (iy+VX_VERTEX_NX)
	xor	a, a
	bit	7, h
	jr	z, $+3
	sub	a, l
	bit	7, l
	jr	z, $+3
	sub	a, h
	mlt	hl
.SSMC1=$+1
	ld	b, $CC
	ld	c, (iy+VX_VERTEX_NY)
	bit	7, b
	jr	z, $+3
	sub	a, c
	bit	7, c
	jr	z, $+3
	sub	a, b
	mlt	bc
	add	hl, bc
.SSMC2=$+1
	ld	b, $CC
	ld	c, (iy+VX_VERTEX_NZ)
	bit	7, b
	jr	z, $+3
	sub	a, c
	bit	7, c
	jr	z, $+3
	sub	a, b
	mlt	bc
	add	hl, bc
	add	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
; between 0-128
	ld	a, h
	add	a, 64
	ld	(ix+VX_VERTEX_GPR0), a
	
.SSMC3=$+1
	ld	h, $CC
	ld	l, (iy+VX_VERTEX_NX)
	xor	a, a
	bit	7, h
	jr	z, $+3
	sub	a, l
	bit	7, l
	jr	z, $+3
	sub	a, h
	mlt	hl
.SSMC4=$+1
	ld	b, $CC
	ld	c, (iy+VX_VERTEX_NY)
	bit	7, b
	jr	z, $+3
	sub	a, c
	bit	7, c
	jr	z, $+3
	sub	a, b
	mlt	bc
	add	hl, bc
.SSMC5=$+1
	ld	b, $CC
	ld	c, (iy+VX_VERTEX_NZ)
	bit	7, b
	jr	z, $+3
	sub	a, c
	bit	7, c
	jr	z, $+3
	sub	a, b
	mlt	bc
	add	hl, bc
	add	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	ld	a, 64
	sub	a, h
	ld	(ix+VX_VERTEX_GPR1), a

	lea	ix, ix+VX_VERTEX_SIZE
	lea	iy, iy+VX_VERTEX_DATA_SIZE
	ld	a, (iy+VX_VERTEX_SIGN)
; check for a = VX_STREAM_END (1)
	dec	a
	jp	nz, .ftransform_trampoline
.SP_RET=$+1
	ld	sp, $CCCCCC
	ret
; free space between alignement

; NOTE : some of these engine have a +-1 or +-2 off error, but that's okay since the output is actually a 18.6 fixed value
align 512
.engine_000:
; 244 cycles
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
	jr	.engine_000_low
align 32
	sbc	hl, hl
.engine_000_low:
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
; 238 cycles
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
	jr	.engine_001_low
align 32
	sbc	hl, hl
.engine_001_low:
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
	sbc	hl, bc
	ret
 
align 64
.engine_010:
; 250 cycles
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
	jr	.engine_010_low
align 32
	sbc	hl, hl
.engine_010_low:
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	sbc	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ret

align 64
.engine_011:
; 247 cycles
	ld	h, (iy+VX_VERTEX_VZ+1)
	ld	l, a
	mlt	hl
	ld	b, (iy+VX_VERTEX_VY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_VERTEX_VX+1)
	ld	c, e
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
	jr	.engine_011_low
align 32
	sbc	hl, hl
.engine_011_low:
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	add	hl, de
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ret

align 64
.engine_100:
; 238 cycles
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
	jr	.engine_100_low
align 32
	sbc	hl, hl
.engine_100_low:
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
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
; 247 cycles
	ld	h, (iy+VX_VERTEX_VX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_VERTEX_VZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_VERTEX_VY+1)
	ld	c, d
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
	jr	.engine_101_low
align 32
	sbc	hl, hl
.engine_101_low:
	ld	b, (iy+VX_VERTEX_VX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_VERTEX_VY)
	mlt	de
	sbc	hl, de
	ld	b, (iy+VX_VERTEX_VZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ret

align 64
.engine_110:
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
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	jr	.engine_110_low
align 32
	sbc	hl, hl
.engine_110_low:
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
	sbc	hl, bc
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
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
	jr	.engine_111_low
align 32
	sbc	hl, hl
.engine_111_low:
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

assert ($-VX_VRAM) <= VX_VRAM_SIZE
end relocate

.vram_cache:
relocate VX_VRAM_CACHE
; 64 bytes for the perspective iterate routines
.perspective_iterate:
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
	ret
.trampoline_stack:
 dl	.trampoline_v0_ret
 dl	.trampoline_v1_ret
 dl	.trampoline_v2_ret
 dl	.perspective_screen_ry
 dl	.perspective_screen_rx

assert ($-VX_VRAM_CACHE) <= VX_VRAM_CACHE_SIZE
end relocate
