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

vxImageSub:

.copy:
; hl : org, bc : rect size, de : copy
	push	bc
	ld	bc, VX_IMAGE_PAGE
	add	hl, bc
	ex	de, hl
	add	hl, bc
	ex	de, hl
	pop	bc
	ld	a, b
	ld	b, 0
; ready to copy
.copy_loop:
	push	bc
	ldir
	pop	bc
	inc	h
	inc	d
	dec	a
	ret	z
	dec	hl
	dec	de
	push	bc
	lddr
	pop	bc
	inc	h
	inc	d
	dec	a
	jr	nz, .copy_loop
	ret
	
.swap:
; hl : org, bc : rect size, de : copy
	push	bc
	ld	bc, VX_IMAGE_PAGE
	add	hl, bc
	ex	de, hl
	add	hl, bc
	ex	de, hl
	pop	bc
	ld	a, b
	ld	b, 0
; ready to copy
.swap_loop:
	push	af
	push	bc
	push	de
	push	hl
.swap_inner:
	ld	a, (de)
	ldi
	dec	hl
	ld	(hl), a
	inc	hl
	jp	pe, .swap_inner
	pop	hl
	inc	b
	add	hl, bc
	pop	de
	ex	de, hl
	add	hl, bc
	ex	de, hl
	pop	bc
	pop	af
	dec	a
	jr	nz, .swap_loop
	ret	

vxImage:

.clear:
	ld	bc, 65535
	xor	a, a
	ld	(hl), a
	ex	de, hl
	sbc	hl, hl
	add	hl, de
	inc	de
	ldir
	ret

.copy:
; hl : org, de : copy, a : format
	rla
	jr	c, .ZX7_uncompress
	rla
	jr	c, .RLE_uncompress
	ld	bc, 65536
	ldir
	ret
.RLE_uncompress:
	ret
.ZX7_uncompress:
; Routine copied from the C toolchain & speed optimized
;  Input:
;   HL = compressed data pointer
;   DE = output data pointer
	ld	a, 128
.copybyteloop:
	ldi
.mainloop:
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	jr	nc, .copybyteloop
	push	de
	ld	de, 0
	ld	bc, 1
.lensizeloop:
	inc	d
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	jr	nc, .lensizeloop
	jr	.lenvaluestart
.lenvalueloop:
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	rl	c
	rl	b
	jr	c, .exit
.lenvaluestart:
	dec	d
	jr	nz, .lenvalueloop
	inc	bc
	ld	e, (hl)
	inc	hl
	sla	e
	inc	e
	jr	nc, .offsetend
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	rl	d
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	rl	d
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	rl	d
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	ccf
	jr	c, .offsetend
	inc	d
.offsetend:
	rr	e
	ex	(sp), hl
	push	hl
	sbc	hl, de
	pop	de
	ldir
.exit:
	pop	hl
	jr	nc, .mainloop
	ret
