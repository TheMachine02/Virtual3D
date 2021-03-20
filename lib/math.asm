Math:

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
