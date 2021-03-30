vxMath:

.sin88:
; input a 0-255 angle and ouput a 8.8 fixed point sinus [hlu is undefined]
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
.cos88:
; input a 0-255 angle and ouput a 8.8 fixed point cosinus [hlu is undefined]
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

; sin cos take a 1024 units circle (that is, 1024 = 2pi)
; output a 2.14 fixed point number
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
	ld	de, (hl)
	ex.s	de, hl
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
	
.div16:
;;Inputs: DE is the numerator, BC is the divisor
;;Outputs: DE is the result
;;         A is a copy of E
;;         HL is the remainder
;;         BC is not changed
;140 bytes
;145cc
	xor a, a
	sbc hl,hl
	ld a,d
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	cpl
	ld d,a

    ld a,e
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	adc hl,hl
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
	cpl
	ld e,a
	ret 
