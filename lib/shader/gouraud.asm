gouraudShader:

	db	VX_PIXEL_SHADER
	dl	gouraudEnd-gouraudCode
	db	2	; two pixel are written per loop
	db	8	; total size of per pixel code
relocate	VX_PIXEL_SHADER_CODE
gouraudCode:
; use v as light intensity
; 22 cycles per pixel + 7 cycles per two pixel
	add	hl, de
	ld	a, h
	exx
	ld	b, a
	ld	a, (bc)
	ld	(de), a
	inc	de
	exx
	add	hl, de
	ld	a, h
	exx
	ld	b, a
	ld	a, (bc)
	ld	(de), a
	inc	de
	exx
	djnz	gouraudCode
gouraudEnd:
end relocate
