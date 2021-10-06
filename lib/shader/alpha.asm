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

.alpha:
	db	VX_PIXEL_SHADER		; shader type
	dl	.alpha_fragment_size	; shader size
	db	2			; two pixel are written per loop
	db	16			; total size of per pixel code
relocate	VX_PIXEL_SHADER_CODE
.alpha_fragment:
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
	djnz	.alpha_fragment
.alpha_fragment_size:=$-.alpha_fragment
end relocate
