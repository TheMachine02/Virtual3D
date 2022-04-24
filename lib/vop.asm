; Virtual-3D library, version 1.0
;
; MIT License
; 
; Copyright (c) 2017 - 2022 TheMachine02
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

; matrix multiplication incremental step
macro	mtxi
; do (de)=(ix+0)*(iy+0) + (ix+1)*(iy+3) + (ix+2)*(iy+6)
	ld	h, (ix+0)
	ld	l, (iy+0)
	xor	a, a
	bit	7, h
	jr	z, $+3
	sub	a, l
	bit	7, l
	jr	z, $+3
	sub	a, h
	mlt	hl
	ld	b, (ix+1)
	ld	c, (iy+3)
	bit	7, b
	jr	z, $+3
	sub	a, c
	bit	7, c
	jr	z, $+3
	sub	a, b
	mlt	bc
	add	hl, bc
	ld	b, (ix+2)
	ld	c, (iy+6)
	bit	7, b
	jr	z, $+3
	sub	a, c
	bit	7, c
	jr	z, $+3
	sub	a, b
	mlt	bc
	add	hl, bc
	add	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	ld	a, h
	ld	(de), a
	inc	de
end	macro

; matrix multiply accumulate 18.6 = 18.6 * 0.6 + 18.6 
macro	fma	arg
	match (=IY?+cc), arg
; do de = de + (iy+d)*a
		push	de
		ld	bc, (iy+cc)
		ld	h, a
		ld	l, (iy+2+cc)
		mlt	hl
		ld	d, b
		ld	e, a
		bit	7, (iy+2+cc)
		jr	z, $+6
		neg
		add	a, h
		ld	h, a
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		bit	7, e
		jr	z, $+5
		or	a, a
		sbc	hl, bc
		ld	b, e
		mlt	bc
		mlt	de
		add	hl, de
		ld	a, c
		ld	c, b
		ld	b, 0
		add	hl, bc
		rla
		adc	hl, hl
		rla
		adc	hl, hl
		pop	de
		add	hl, de
		ex	de, hl
	end	match
end	macro

macro	fmlt	arg2
	match	(=IY?+cc), arg2
		ld	bc, (iy+cc)
		ld	h, a
		ld	l, (iy+2+cc)
		mlt	hl
		ld	d, b
		ld	e, a
		bit	7, (iy+2+cc)
		jr	z, $+6
		neg
		add	a, h
		ld	h, a
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		bit	7, e
		jr	z, $+5
		or	a, a
		sbc	hl, bc
		ld	b, e
		mlt	bc
		mlt	de
		add	hl, de
		ld	a, c
		ld	c, b
		ld	b, 0
		add	hl, bc
		rla
		adc	hl, hl
		rla
		adc	hl, hl
	end	match
end	macro
