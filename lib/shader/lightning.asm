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

.lightning:
	db	VX_PIXEL_SHADER
	dl	.lightning_fragment_size
	db	2	; two pixel are written per loop
	db	11	; total size of per pixel code
relocate	VX_PIXEL_SHADER_CODE
.lightning_fragment:
; 	ld  a, h    	; a=v (integer part)
; 	add hl, sp  	; v=v+dv : on hlu, compute u=u+du for fractionnal part
; 	exx		 	; swap
; 	ld  h, a    	; paste integer v on high byte
; 	ld  e, (hl) 	; fetch texture at $D3VVUU
; 	ld  a, (de) 	; fetch lighted color
; 	adc hl, bc  	; u=u+du (integer part)
; 	exx		 	; swap
; 	ld  (de), a	; write the pixel to the framebuffer
; 	inc de		; advance next pixel
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
	djnz	.lightning_fragment
.lightning_fragment_size:=$-.lightning_fragment
end relocate
