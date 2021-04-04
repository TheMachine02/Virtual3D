vxPixelShader:
	db	VX_PIXEL_SHADER
	dl	.texture_end-.texture
	db	2	; two pixel are written per loop
	db	10	; total size of per pixel code
relocate	VX_PIXEL_SHADER_CODE
.texture:
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
	djnz	.texture
.texture_end:
end relocate
