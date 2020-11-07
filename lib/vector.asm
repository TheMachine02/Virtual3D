; code start - vector utility fonctions

vxCrossProduct:
; (hl) = (ix) cross (iy)
; 774 TStates, 177 Bytes
; v1.y*v2.z-v1.z*v2.y
; v1.z*v2.x-v1.x*v2.z
; v1.x*v2.y-v1.y*v2.x
	ex	de, hl
; v1.y
	ld	b, (ix+1)
; v2.z
	ld	c, (iy+2)
	xor	a, a
	sbc	hl, hl
	bit	7, b
	jr	z, $+3
	add	a, c
	bit	7, c
	jr	z, $+3
	add	a, b
	mlt	bc
	add	hl, bc
	ld	b, a
	xor	a, a
	ld	c, a
	sbc	hl, bc
; v1.z
	ld	b, (ix+2)
; v2.y
	ld	c, (iy+1)
	xor	a, a
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
	xor	a, a
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
	xor	a, a
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

vxDotProduct:
; hl = (ix) dot (iy)
	ld	h, (ix+0)
	ld	l, (iy+0)
	ld	a, h
	rla
	sbc	a, a
	and	l
	ld	e, a
	ld	a, l
	rla
	sbc	a, a
	and	h
	add	a, e
	mlt	hl
	ld	e, a
	ld	b, (ix+1)
	ld	c, (iy+1)
	ld	a, b
	rla
	sbc	a, a
	and	c
	ld	d, a
	ld	a, c
	rla
	sbc	a, a
	and	b
	add	a, d
	mlt	bc
	add	hl, bc
	ld	d, a
	ld	b, (ix+2)
	ld	c, (iy+2)
	xor	a, a
	bit	7, b
	jr	z, $+3
	add	a, c
	bit	7, c
	jr	z, $+3
	add	a, b
	mlt	bc
	add	hl, bc
	ld	b, a
	xor	a, a
	ld	c, a
	sbc	hl, bc
	ld	b, e
	sbc	hl, bc
	ld	b, d
	sbc	hl, bc
	ret
vxNormalize:
; iy vector, hl output
	ret
vxLength:
	ret

vxReflect:
; I = ix, N = iy, hl = result
; reflection direction I-2*dot(N,I)*N
	push	hl
	call	vxDotProduct
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
	and	l
	ld	c, a
	ld	a, l
	rla
	sbc	a, a
	and	h
	add	a, c
	ld	c, a
	mlt	hl
	ld	a, h
	sub	c
	ld	h, a
	add	hl, hl
	add	hl, hl
	ld	c, h
	ld	a, (ix+0)
	sub	a, c
	ld	(de), a
	inc	de

	ld	h, b
	ld	l, (iy+1)
	ld	a, h
	rla
	sbc	a, a
	and	l
	ld	c, a
	ld	a, l
	rla
	sbc	a, a
	and	h
	add	a, c
	ld	c, a
	mlt	hl
	ld	a, h
	sub	c
	ld	h, a
	add	hl, hl
	add	hl, hl
	ld	c, h
	ld	a, (ix+1)
	sub	a, c
	ld	(de), a
	inc	de

	ld	h, b
	ld	l, (iy+2)
	ld	a, h
	rla
	sbc	a, a
	and	l
	ld	c, a
	ld	a, l
	rla
	sbc	a, a
	and	h
	add	a, c
	ld	c, a
	mlt	hl
	ld	a, h
	sub	c
	ld	h, a
	add	hl, hl
	add	hl, hl
	ld	c, h
	ld	a, (ix+2)
	sub	a, c
	ld	(de), a
	ret
