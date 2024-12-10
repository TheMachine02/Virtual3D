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

; code start - vector utility fonctions

; multiply a vec3 by a matrix
vxVector:
.mlt3:
; vec3(hl) = mat3(ix) * vec3(iy)
	exx
	call	.dot3
	add	hl, hl
	add	hl, hl
	ld	a, h
	rl	l
	adc	a, 0
	exx
	ld	(hl), a
	inc	hl
	lea	ix, ix+3
	exx
	call	.dot3
	add	hl, hl
	add	hl, hl
	ld	a, h
	rl	l
	adc	a, 0
	exx
	ld	(hl), a
	inc	hl
	lea	ix, ix+3
	exx
	call	.dot3
	add	hl, hl
	add	hl, hl
	ld	a, h
	rl	l
	adc	a, 0
	exx
	ld	(hl), a
	lea	ix, ix-6
	ld	bc, -2
	add	hl, bc
	ret

.cross3:
; (hl) = (ix) cross (iy)
; 774 TStates, 177 Bytes
; v1.y*v2.z-v1.z*v2.y
; v1.z*v2.x-v1.x*v2.z
; v1.x*v2.y-v1.y*v2.x
	ex	de, hl
; v1.y
	ld	h, (ix+1)
; v2.z
	ld	l, (iy+2)
	xor	a, a
	bit	7, h
	jr	z, $+3
	add	a, l
	bit	7, l
	jr	z, $+3
	add	a, h
	mlt	hl
	inc.s	bc
	ld	b, a
	xor	a, a
	ld	c, a
	sbc	hl, bc
; v1.z
	ld	b, (ix+2)
; v2.y
	ld	c, (iy+1)
	bit	7, b
	jr	z, $+3
	add	a, c
	bit	7, c
	jr	z, $+3
	add	a, b
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	b, a
	xor	a, a
	ld	c, a
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ld	a, h
	ld	(de), a
	inc	de
; v1.z
	ld	h, (ix+2)
; v2.x
	ld	l, (iy+0)
	xor	a, a
	bit	7, h
	jr	z, $+3
	add	a, l
	bit	7, l
	jr	z, $+3
	add	a, h
	mlt	hl
	ld	b, a
	xor	a, a
	ld	c, a
	sbc	hl, bc
; v1.x
	ld	b, (ix+0)
; v2.z
	ld	c, (iy+2)
	bit	7, b
	jr	z, $+3
	add	a, c
	bit	7, c
	jr	z, $+3
	add	a, b
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	b, a
	xor	a, a
	ld	c, a
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ld	a, h
	ld	(de), a
	inc	de
; v1.x
	ld	h, (ix+0)
; v2.y
	ld	l, (iy+1)
	xor	a, a
	bit	7, h
	jr	z, $+3
	add	a, l
	bit	7, l
	jr	z, $+3
	add	a, h
	mlt	hl
	ld	b, a
	xor	a, a
	ld	c, a
	sbc	hl, bc
; v1.y
	ld	b, (ix+1)
; v2.x
	ld	c, (iy+0)
	bit	7, b
	jr	z, $+3
	add	a, c
	bit	7, c
	jr	z, $+3
	add	a, b
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	b, a
	xor	a, a
	ld	c, a
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	(hl), d
	dec	hl
	dec	hl
	ret

.dot3:
; hl (16 bits signed) = (ix) dot (iy)
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
	ld	c, (iy+1)
	bit	7, b
	jr	z, $+3
	sub	a, c
	bit	7, c
	jr	z, $+3
	sub	a, b
	mlt	bc
	add	hl, bc
	ld	b, (ix+2)
	ld	c, (iy+2)
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
	ret

.normalize3:
; iy vector, hl output
	ret

.length3:
	ret

.reflect3:
; I = ix, N = iy, hl = result
; reflection direction I-2*dot(N,I)*N
	push	hl
	call	.dot3
	add	hl, hl
	add	hl, hl
	add	hl, hl
; scale N vector
	ld	b, h
	pop	de
	ld	l, (iy+0)
	ld	a, h
	rla
	sbc	a, a
	and	a, l
	ld	c, a
	ld	a, l
	rla
	sbc	a, a
	and	a, h
	add	a, c
	ld	c, a
	mlt	hl
	ld	a, h
	sub	a, c
	ld	h, a
	add	hl, hl
	add	hl, hl
	ld	a, (ix+0)
	sub	a, h
	ld	(de), a
	inc	de

	ld	h, b
	ld	l, (iy+1)
	ld	a, h
	rla
	sbc	a, a
	and	a, l
	ld	c, a
	ld	a, l
	rla
	sbc	a, a
	and	a, h
	add	a, c
	ld	c, a
	mlt	hl
	ld	a, h
	sub	a, c
	ld	h, a
	add	hl, hl
	add	hl, hl
	ld	a, (ix+1)
	sub	a, h
	ld	(de), a
	inc	de

	ld	h, b
	ld	l, (iy+2)
	ld	a, h
	rla
	sbc	a, a
	and	a, l
	ld	c, a
	ld	a, l
	rla
	sbc	a, a
	and	a, h
	add	a, c
	ld	c, a
	mlt	hl
	ld	a, h
	sub	a, c
	ld	h, a
	add	hl, hl
	add	hl, hl
	ld	a, (ix+2)
	sub	a, h
	ld	(de), a
	ret
