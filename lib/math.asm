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
	add	hl, hl	; sure c flag will be reset!
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
