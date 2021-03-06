alphaShader:
	db	VX_PIXEL_SHADER		; shader type
	dl	alphaEnd-alphaCode	; shader size
	db	2			; two pixel are written per loop
	db	16			; total size of per pixel code
relocate	VX_PIXEL_SHADER_CODE
alphaCode:
	add	hl, de
	ld	a, h
	exx
	adc	hl, sp
	ld	h, a
	ld	b, (hl)			; fetch the texture
	ld	a, (de)			; fetch the fb color
	ld	c, a			;
	ld	a, (bc)			;
	set	7, h
	add	a, (hl)			; add up both color
	ld	(de), a			; and write it to fb
	inc	de
	exx
	add	hl, de
	ld	a, h
	exx
	adc	hl, sp
	ld	h, a
	ld	b, (hl)			; fetch the texture
	ld	a, (de)			; fetch the fb color
	ld	c, a			;
	ld	a, (bc)			;
	set	7, h
	add	a, (hl)			; add up both color
	ld	(de), a			; and write it to fb
	inc	de
	exx
	djnz	alphaCode
alphaEnd:
end relocate
