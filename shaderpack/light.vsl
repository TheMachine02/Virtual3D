#include	"vxVSL.inc"

lightShader:

	.db	VX_PIXEL_SHADER
	.dl	lightEnd-lightCode
	.db	2	; two pixel are written per loop
	.db	11	; total size of per pixel code
.relocate	VX_PIXEL_SHADER_CODE
lightCode:
#comment
	ld  a, h    	; a=v (integer part)
	add hl, sp  	; v=v+dv : on hlu, compute u=u+du for fractionnal part
	exx		 	; swap
	ld  h, a    	; paste integer v on high byte
	ld  e, (hl) 	; fetch texture at $D3VVUU
	ld  a, (de) 	; fetch lighted color
	adc hl, bc  	; u=u+du (integer part)
	exx		 	; swap
	ld  (de), a	; write the pixel to the framebuffer
	inc de		; advance next pixel
#endcomment
	add	hl, de
	ld	a, h
	exx
	adc	hl, sp
	ld	h, a
	ld	c, (hl)
	ld	a, (bc)
	ld	(de), a
	inc	de
	exx
	add	hl, de
	ld	a, h
	exx
	adc	hl, sp
	ld	h, a
	ld	c, (hl)
	ld	a, (bc)
	ld	(de), a
	inc	de
	exx
	djnz	lightCode
lightEnd:
.endrelocate
