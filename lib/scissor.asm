vxScissor:

.set:
; a, c
; hl, de
	ld	(.SBLY0), a
	ld	(.SBLY1), a
	ld	(.SBLY2), a
	ld	a, c
	ld	(.SBRY0), a
	ld	(.SBRY1), a
	ld	(.SBRY2), a
	ld	(.SBLX0), hl
	ld	(.SBRX0), de
	ret

; reset state machine at the render triangle texture and render triangle color (simple SMC code)
.enable:
	ret
.disable:
	ret

.box:
; compute a rectangular box based on a list of 4 vertices
	ret

.test:
; carry is out, nc is in
; test a triangle (3 vertices) against the current box
; doesn't clip, but fast reject / accept
; (vx < x0) << 3 | (vx > x1) << 2 | (vy < y0) << 1 | (vy > y1) << 0
; for the three vertices
; return false if clip.0 & clip.1 & clip.2 return true, ie all vertices are classified against an edge
; compare all three y against y0 first, return if all sided, repeat for y1, repeat for x1 and x2
	ld	a, (hl)
.SBLY0:=$+1
	cp	a, $CC
; vy > y0 ? discard_e, continue
	jr	nc, .discard_e0
	ld	a, (de)
.SBLY1:=$+1
	cp	a, $CC
	jr	nc, .discard_e0
	ld	a, (bc)
.SBLY2:=$+1
	cp	a, $CC
	ret	c
.discard_e0:
; check other edge
; vy < y1 ? discard_e, continue
	ld	a, (hl)
.SBRY0:=$+1
	cp	a, $CC
	jr	c, .discard_e1
	ld	a, (de)
.SBRY1:=$+1
	cp	a, $CC
	jr	c, .discard_e1
	ld	a, (bc)
.SBRY2:=$+1
	cp	a, $CC
	ccf
	ret	c
.discard_e1:
	inc	hl
	inc	de
	inc	bc
	push	hl
	push	de
	push	bc
; we need to check x coordinate now
	ld	hl, (hl)
	push	de
.SBLX0:=$+1
	ld	de, $CCCCCC
	or	a, a
	sbc.s	hl, de
	pop	hl
	jr	nc, .discard_e2
	ld	hl, (hl)
	or	a, a
	sbc.s	hl, de
	jr	nc, .discard_e2
	push	bc
	pop	hl
	ld	hl, (hl)
	or	a, a
	sbc.s	hl, de
	jr	c, .pop_out
.discard_e2:
	pop	bc
	pop	de
	pop	hl
	
	push	hl
	push	de
	push	bc
	ld	hl, (hl)
	push	de
.SBRX0:=$+1
	ld	de, $CCCCCC
	or	a, a
	sbc.s	hl, de
	pop	hl
	jr	c, .discard_e3
	ld	hl, (hl)
	or	a, a
	sbc.s	hl, de
	jr	c, .discard_e3
	push	bc
	pop	hl
	ld	hl, (hl)
	or	a, a
	sbc.s	hl, de
	jr	nc, .pop_out
.discard_e3:
	pop	bc
	pop	de
	pop	hl
	dec	bc
	dec	de
	dec	hl
	or	a, a
	ret
.pop_out:
	pop	bc
	pop	de
	pop	hl
	scf
	ret
