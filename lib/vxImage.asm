#define	VX_IMAGE_RLE_COMPRESSED	%01000000
#define	VX_IMAGE_ZX7_COMPRESSED	%10000000
#define	VX_IMAGE_UNCOMPRESSED		%00100000

#define	VX_IMAGE_PAGE			$D30000

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
_inner_copyLoop:
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
	jr	nz, _inner_copyLoop
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
	jr	c, _inner_ZX7Uncompress
	rla
	jr	c, _inner_RLEUncompress
	ld	bc, 65536
	ldir
	ret
_inner_RLEUncompress:
	ret
_inner_ZX7Uncompress:
; Routine copied from the C toolchain & speed optimized
;  Input:
;   HL = compressed data pointer
;   DE = output data pointer
	ld	a, 128
_inner_copybyteloop:
	ldi
_inner_mainloop:
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	jr	nc, _inner_copybyteloop
	push	de
	ld	de, 0
	ld	bc, 1
_inner_lensizeloop:
	inc	d
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	jr	nc, _inner_lensizeloop
	jr	_inner_lenvaluestart
_inner_lenvalueloop:
	add	a, a
	jr	nz, $+5
	ld	a, (hl)
	inc	hl
	rla
	rl	c
	rl	b
	jr	c, _inner_exit
_inner_lenvaluestart:
	dec	d
	jr	nz, _inner_lenvalueloop
	inc	bc
	ld	e, (hl)
	inc	hl
	sla	e
	inc	e
	jr	nc, _inner_offsetend
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
	jr	c, _inner_offsetend
	inc	d
_inner_offsetend:
	rr	e
	ex	(sp), hl
	push	hl
	sbc	hl, de
	pop	de
	ldir
_inner_exit:
	pop	hl
	jr	nc, _inner_mainloop
	ret
