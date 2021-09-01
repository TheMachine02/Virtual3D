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

; perform hl = de * bc + hl
; doesnt destroy de
macro fma.s? hl
	push.s	hl
	xor	a, a
	ld	h, b
	ld	l, d
	mlt	hl
	bit	7, b
	jr	z, $+4
	sbc	hl, de
	bit	7, d
	jr	z, $+5
	or	a, a
	sbc	hl, bc
	ld	h, l
	ld	l, a
	ld	a, c
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	c, a
	ld	b, d
	mlt	bc
	add	hl, bc
	ld	c, a
	ld	b, e
	mlt	bc
	ld	c, b
	xor	a, a
	ld	b, a
	add	hl, bc
	pop.s	bc
	add.s	hl, bc
end macro

macro fma? hl
	push	hl
	ld	h, b
	ld	l, d
	mlt	hl
	bit	7, b
	jr	z, $+5
	or	a, a
	sbc	hl, de
	bit	7, d
	jr	z, $+5
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
	ld	a, c
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	c, a
	ld	b, d
	mlt	bc
	add	hl, bc
	ld	c, a
	ld	b, e
	mlt	bc
	ld	c, b
	xor	a, a
	ld	b, a
	add	hl, bc
	pop	bc
	add	hl, bc
end macro

vxMath:

.sin_88:
; input a 0-255 angle and ouput a 8.8 fixed point sinus [hlu is undefined]
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	call	.sin
	add	hl, hl
	sbc	a, a
	add	hl, hl
	adc	a, a
	ld	l, h
	ld	h, a
	ret
.cos_88:
; input a 0-255 angle and ouput a 8.8 fixed point cosinus [hlu is undefined]
	or	a, a
	sbc	hl, hl
	ld	l, a
	add	hl, hl
	add	hl, hl
	call	.cos
	add	hl, hl
	sbc	a, a
	add	hl, hl
	adc	a, a
	ld	l, h
	ld	h, a
	ret

; sin cos take a 1024 units circle (that is, 1024 = 2pi)
; output a 2.14 fixed point number
assert	VX_LUT_SIN < $D10000
assert	VX_LUT_SIN mod 2 = 0
.cos:
	inc	h
.sin:
	bit	0, h
	ld	a, l
	jr	z, .sin_skip
	neg
	jr	z, .sin_index_zero
.sin_skip:
	bit	1, h
	ld	hl, VX_LUT_SIN shr 1
	ld	l, a
	add	hl, hl
	ld.s	hl, (hl)
	ret	z
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	ret
.sin_index_zero:
	bit	1, h
	jr	nz, .sin_index_negate
	ld	hl, $004000
	ret
.sin_index_negate:
	ld	hl, $FFC000
	ret

.sdiv256:
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ret
	
.udiv:
;; divide 16 bits DE by 16 bits BC and output the 16 bits BC result. HL is the remainder
;; Thanks Xeda for this routine
;; Inputs: DE is the numerator, BC is the divisor
;; Outputs: DE is the result
;;         A is a copy of E
;;         HL is the remainder
;;         BC is not changed
	xor	a, a
	sbc	hl, hl
	ld	a, d
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	cpl
	ld	d, a
	ld	a, e
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	adc	hl, hl
	sbc	hl, bc
	jr	nc, $+3
	add	hl, bc
	adc	a, a
	cpl
	ld	e, a
	ret 

_mulf16:
; hl = hl * de fixed point 8.8 multiplication (hl is 8.8 fixed point)
	xor	a, a
	bit	7, h
	ld	b, h
	ld	c, l
	ld	l, d
	mlt	hl
	jr	z, $+4
	sbc	hl, de
	bit	7, d
	jr	z, $+5
	or	a, a
	sbc	hl, bc
	ld	h, l
	ld	l, a
	ld	a, c
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	c, a
	ld	b, d
	mlt	bc
	add	hl, bc
	ld	c, a
	ld	b, e
	mlt	bc
	ld	c, b
	xor	a, a
	ld	b, a
	add	hl, bc
	ret

; sqrt24:
; ;;Expects ADL mode
; ;;Inputs: HL
; ;;Outputs: DE is the integer square root
; ;;         HL is the difference inputHL-DE^2
; ;;         c flag reset
;     xor a \ ld b,l \ push bc \ ld b,a \ ld d,a \ ld c,a \ ld l,a \ ld e,a
; ;Iteration 1
;     add hl,hl \ rl c \ add hl,hl \ rl c
;     sub c \ jr nc,$+6 \ inc e \ inc e \ cpl \ ld c,a
; ;Iteration 2
;     add hl,hl \ rl c \ add hl,hl \ rl c \ rl e \ ld a,e
;     sub c \ jr nc,$+6 \ inc e \ inc e \ cpl \ ld c,a
; ;Iteration 3
;     add hl,hl \ rl c \ add hl,hl \ rl c \ rl e \ ld a,e
;     sub c \ jr nc,$+6 \ inc e \ inc e \ cpl \ ld c,a
; ;Iteration 4
;     add hl,hl \ rl c \ add hl,hl \ rl c \ rl e \ ld a,e
;     sub c \ jr nc,$+6 \ inc e \ inc e \ cpl \ ld c,a
; ;Iteration 5
;     add hl,hl \ rl c \ add hl,hl \ rl c \ rl e \ ld a,e
;     sub c \ jr nc,$+6 \ inc e \ inc e \ cpl \ ld c,a
; ;Iteration 6
;     add hl,hl \ rl c \ add hl,hl \ rl c \ rl e \ ld a,e
;     sub c \ jr nc,$+6 \ inc e \ inc e \ cpl \ ld c,a
; 
; ;Iteration 7
;     add hl,hl \ rl c \ add hl,hl \ rl c \ rl b
;     ex de,hl \ add hl,hl \ push hl \ sbc hl,bc \ jr nc,$+8
;     ld a,h \ cpl \ ld b,a
;     ld a,l \ cpl \ ld c,a
;     pop hl
;     jr nc,$+4 \ inc hl \ inc hl
;     ex de,hl
; ;Iteration 8
;     add hl,hl \ ld l,c \ ld h,b \ adc hl,hl \ adc hl,hl
;     ex de,hl \ add hl,hl \ sbc hl,de \ add hl,de \ ex de,hl
;     jr nc,$+6 \ sbc hl,de \ inc de \ inc de
; ;Iteration 9
;     pop af
;     rla \ adc hl,hl \ rla \ adc hl,hl
;     ex de,hl \ add hl,hl \ sbc hl,de \ add hl,de \ ex de,hl
;     jr nc,$+6 \ sbc hl,de \ inc de \ inc de
; ;Iteration 10
;     rla \ adc hl,hl \ rla \ adc hl,hl
;     ex de,hl \ add hl,hl \ sbc hl,de \ add hl,de \ ex de,hl
;     jr nc,$+6 \ sbc hl,de \ inc de \ inc de
; ;Iteration 11
;     rla \ adc hl,hl \ rla \ adc hl,hl
;     ex de,hl \ add hl,hl \ sbc hl,de \ add hl,de \ ex de,hl
;     jr nc,$+6 \ sbc hl,de \ inc de \ inc de
; ;Iteration 11
;     rla \ adc hl,hl \ rla \ adc hl,hl
;     ex de,hl \ add hl,hl \ sbc hl,de \ add hl,de \ ex de,hl
;     jr nc,$+6 \ sbc hl,de \ inc de \ inc de
;     rr d \ rr e \ ret
