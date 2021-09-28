.default:
	db	VX_PIXEL_SHADER
	dl	.fragment_size
	db	2	; two pixel are written per loop
	db	10	; total size of per pixel code
relocate	VX_PIXEL_SHADER_CODE
.fragment:
	add	hl, de
	ld	a, h
	exx
	adc	hl, sp
	ld	h, a
	ld	a, (hl)
	ld	(de), a
	inc	de
	exx
	add	hl, de
	ld	a, h
	exx
	adc	hl, sp
	ld	h, a
	ld	a, (hl)
	ld	(de), a
	inc	de
	exx
	djnz	.fragment
.fragment_size:=$-.fragment
end relocate
