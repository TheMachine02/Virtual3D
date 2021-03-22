vxImage:

vxImageSubCopy:
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
.copyLoop:
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
	jr	nz, .copyLoop
	ret
	
vxImageSubSwap:
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

vxImageClear:
	ld	bc, 65535
	xor	a, a
	ld	(hl), a
	ex	de, hl
	sbc	hl, hl
	add	hl, de
	inc	de
	ldir
	ret

vxImageCopy:
; hl : org, de : copy, a : format
	rla
	jr	c, .ZX7Uncompress
	rla
	jr	c, .RLEUncompress
	ld	bc, 65536
	ldir
	ret
.RLEUncompress:
	ret
.ZX7Uncompress:
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
