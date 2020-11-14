font:

.glyph_string:
; use the kernel function
; display string bc @ hl (y - x)
	call	.glyph_adress
.putstring_loop:
	ld	a, (bc)
	or	a, a
	ret	z
	push	bc
	call	.glyph_char
	pop	bc
	inc	bc
	jr	.putstring_loop

.glyph_adress:
	ld	d, 220
	ld	e, h
	mlt	de
	ex	de, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	d, 6
	mlt	de
	add	hl, de
	ld	de, (vxFramebuffer)
	add	hl, de
	ex	de, hl
	ret
 
.glyph_char:
; ix color pattern, hl position (screen)
	push	iy
	ld	l, a
	ld	h, 3
	mlt	hl
	ld	bc, font.TRANSLATION_TABLE
	add	hl, bc
	lea	bc, ix+0
	ld	iy, (hl)
	ex	de, hl
	ld	de, 315
; c = background b = foreground bcu = background
.putchar_loop:
	ld	a, (iy+0)
	inc	iy
	ld	(hl), bc
	add	a, a
	jr	nc, $+3
	ld	(hl), b
	inc	hl
	add	a, a
	jr	c, $+3
	ld	(hl), c
	inc	hl
	add	a, a
	jr	nc, $+3
	ld	(hl), b
	inc	hl
	ld	(hl), bc
	add	a, a
	jr	nc, $+3
	ld	(hl), b
	inc	hl
	add	a, a
	jr	c, $+3
	ld	(hl), c
	inc	hl
	add	a, a
	jr	nc, $+3
	ld	(hl), b
	add	hl, de
	jr	z, .putchar_loop
; hl is the last line position
; so hl - 320*11 + 6 = next character position
	ld	de, -320*11+6
	add	hl, de
	ex	de, hl
	pop	iy
	ret

.glyph_hex:
; bc = number to blit in hex format [8 characters]
	call	.glyph_adress
.glyph_hex_address:
	push	iy
	push	bc
	ld	iy, 0
	add	iy, sp
	ld	a, '0'
	call	.glyph_char
	ld	a, 'x'
	call	.glyph_char
	ld	a, (iy+2)
	call	.glyph_8bit_digit
	ld	a, (iy+1)
	call	.glyph_8bit_digit
	ld	a, (iy+0)
	call	.glyph_8bit_digit
	pop	bc
	pop	iy
	ret

.glyph_integer:
	ld	a, 8
.glyph_integer_format:
	call	.glyph_adress
.glyph_integer_address:
	push	iy
	push	bc
	ex	de, hl
	ld	e, a
	ld	a, 8
	sub	a, e
	jr	nc, $+3
	xor	a, a
	ld	d, a
	ld	a, e
	ld	e, 3
	mlt	de
	ld	iy, .TABLE_OF_TEN
	add	iy, de
	ex	de, hl
	pop	hl
.glyph_integer_loop:
	push	af
	ld	bc, (iy+0)
	lea	iy, iy+3
	ld	a,'0'-1
	or	a, a
.glyph_find_digit:
	inc	a
	sbc	hl, bc
	jr	nc, .glyph_find_digit
	add	hl, bc
	push	hl
	call	.glyph_char
	pop	hl
	pop	af
	dec	a
	jr	nz, .glyph_integer_loop
	pop	iy
	ret

.TABLE_OF_TEN:
 dl	10000000
 dl	1000000
 dl	100000
 dl	10000
 dl	1000
 dl	100
 dl	10
 dl	1
 
 .glyph_8bit_digit:
; input c
	push	af
	rra
	rra
	rra
	rra
	call	.glyph_4bit_digit
	pop	af
.glyph_4bit_digit:
	and	$0F
	add	a, $90
	daa
	jr	nc, $+4
	adc	a, $C0		; $60 + ($90 - $30)
	sub	a, $60		; ($90-$30)
	jp	.glyph_char	

include	'gohufont.inc'

__idivs:
; Performs signed interger division
; Inputs:
;  HL : Operand 1
;  BC : Operand 2
; Outputs:
;  HL = HL/BC
	ex	de,hl
	xor	a,a
	sbc	hl,hl
	sbc	hl,bc
	jp	p,.v
	push	hl
	pop	bc
	inc	a

.v:	or	a,a
	sbc	hl,hl
	sbc	hl,de
	jp	m,.vb
	ex	de,hl
	inc	a

.vb:	add	hl,de
	rra
	ld	a,24

.vc:	ex	de,hl
	adc	hl,hl
	ex	de,hl
	adc	hl,hl
	add	hl,bc
	jr	c,.vd
	sbc	hl,bc
.vd:	dec	a
	jr	nz,.vc

	ex	de,hl
	adc	hl,hl
	ret	c
	ex	de,hl
	sbc	hl,hl
	sbc	hl,de
	ret
