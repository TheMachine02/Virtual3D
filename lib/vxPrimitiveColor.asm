	inc	hl
	inc	de
	inc	bc

    ld	a, (de)
    sub	a, (hl)
    jr	c, vxColorSwap0
    ex	de, hl
vxColorSwap0:
    ld	a, (bc)
    sub	a, (hl)
    jr	nc, vxColorSwap1
    push	hl
    or	a, a
    sbc	hl, hl
    add	hl, bc
    pop	bc
vxColorSwap1:
    ld	a, (de)
    sub	a, (hl)
    jr	nc, vxColorSwap2
    ex	de, hl
vxColorSwap2:

    ld	a, (bc)
    sub	(hl)
    ret	z

    ld	ix, $FF0000
    ld	iy, $FF0000
    ld	ixl, a
    neg
    ld	(IDeltaY0), a
; x1-x0
    ld	a, (de)
    ld	(IValueY1), a
    sub	(hl)
    push	af
    ld	iyl, a
    neg
    ld	(IDeltaY1), a

    ld	a, (hl)
    push	af

    push	bc
    inc	hl
    ld	bc, (hl)
	inc.s	bc \ dec.s bc
    ex	de, hl
    inc	hl
    ld	hl, (hl)
	inc.s	hl \ dec.s hl
    ld	(IValueX1), hl
    jr	z, IRasterNoEdgeWrite
    ld	a, $13
    or	a, a
    sbc	hl, bc
    jr	nc, IRasterEdge1
    or	a, $08
    ex	de, hl
    sbc	hl, hl
    sbc	hl, de
IRasterEdge1:
    ld	(IDeltaX1), hl
    ld	(ISMC_Code1), a

    lea	de, iy+0
    add	hl, de
    ex	de, hl
    sbc	hl, hl
    ccf
    sbc	hl, de
    sra	h
    rr	l
    ex	de, hl
    ld	iyh, d
    ld	iyl, e

IRasterNoEdgeWrite:
    pop	hl

; x2-x0
    inc	hl
    ld	hl, (hl)
	inc.s	hl \ dec.s hl
    ld	(IValueX2), hl
    ld	a, $23			; inc hl
    or	a, a
    sbc	hl, bc
; if x0>x1, edge goes to left
    jr	nc, IRasterEdge0
    or	a, $08			; dec hl
; edge goes to left
    ex	de, hl
    sbc	hl, hl
    sbc	hl, de
IRasterEdge0:
    ld	(IDeltaX0), hl
    ld	(ISMC_Code0), a

    lea	de, ix+0
    add	hl, de
    ex	de, hl
    sbc	hl, hl
    ccf
    sbc	hl, de
    sra	h
    rr	l
    ex	de, hl
    ld	ixh, d
    ld	ixl, e

	pop	de
	ld	e, 160
	mlt	de
	ld	hl, (vxFramebuffer)
	add	hl, de
	add	hl, de
	add	hl, bc
	ex	de, hl
	sbc	hl, hl
	add	hl, de

	pop	af
	call	nz, IRasterTriangleInner

	ld	a, (IDeltaY0) ; y2-y0
	ld	c, a
	ld	a, (IDeltaY1)
	sub	c
	ret	z
	push	af
	ld	iyl, a
	neg
	ld	(IDeltaY1), a

	push	hl

IValueX2=$+1
	ld	hl, $000000
IValueX1=$+1
	ld	bc, $000000
	or	a, a
	sbc	hl, bc
	ld	a, $13
; if x0>x1, edge goes to left
	jr	nc, IRasterEdge2
	or	a, $08
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
IRasterEdge2:
	ld	(IDeltaX1), hl
	ld	(ISMC_Code1), a

	lea	de, iy+0
	ld	d, $00 ;compensate due to previous looping
	add	hl, de
	ex	de, hl
	sbc	hl, hl
	ccf
	sbc	hl, de
	sra	h
	rr	l
	ex	de, hl
	ld	iyh, d
	ld	iyl, e

IValueY1=$+1
	ld	e, $00
	ld	d, 160
	mlt	de
	ld	hl, (vxFramebuffer)
	add	hl, de
	add	hl, de
	add	hl, bc
	ex	de, hl
	pop	hl

	pop	af
IRasterTriangleInner:
IDeltaX0=$+1
	ld	bc, $000000
	add	ix, bc
	jr	nc, $+11
IDeltaY0=$+1
	ld	bc, $FFFF00
ISMC_Code0=$
	nop
	add	ix, bc
	jr	c, $-3

IDeltaX1=$+1
	ld	bc, $000000
	add	iy, bc
	jr	nc, $+13
IDeltaY1=$+1
	ld	bc, $FFFF00
ISMC_Code1=$
	nop
	add	iy, bc
	jr	c, $-3
	inc.s	bc ;reset bcu set by restoring ld bc,$FFxxxx

; hl = adress1, de = adress2
	sbc	hl, de
	jr	c, IRasterInverted
	jr	z, IRasterNoPixel
	ld	b, h
	ld	c, l

	ld	hl, VX_PRIMITIVE_COLOR_RBG
	ldi
	jp	po, IRasterContinue
	scf
	sbc	hl, hl
	add	hl, de
	push	hl
	ldir
	pop	hl

	ld	c, 64
	inc	b
	add	hl, bc
	ex	de, hl
	add	hl, bc
	dec	a
	jr	nz,IRasterTriangleInner
	ret
IRasterContinue:
	scf
	sbc	hl, hl
IRasterNoPixel:
	add	hl, de
	ld	bc, 320
	add	hl, bc
	ex	de, hl
	add	hl, bc
	dec	a
	jr	nz,IRasterTriangleInner
	ret
IRasterInverted:
	add	hl, de
; hl --- de
VX_PRIMITIVE_COLOR_RBG=$+1
	ld	(hl), $FF
	ex	de, hl
; carry is set
	sbc	hl, de
	ld	b, h
	ld	c, l
	add	hl, de
	jr	z, IRasterSize1
	push	de
	sbc	hl, hl
	add	hl, de
	inc	de
	ldir
	pop	de
IRasterSize1:
	inc	hl

	ld	c, 64
	inc	b
	add	hl, bc
	ex	de, hl
	add	hl, bc
	dec	a
	jr	nz, IRasterTriangleInner
	ret