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

; WARNING : this routine assume vertex buffer is in the first 64K of RAM
assert VX_PATCH_VERTEX_POOL < $D10000
assert VX_VERTEX_BUFFER < $D10000
	inc	hl
	inc	de
	inc	bc
	ld	a, (de)
	sub	a, (hl)
	jr	c, .colorSwap0
	ex	de, hl
.colorSwap0:
	ld	a, (bc)
	sub	a, (hl)
	jr	nc, .colorSwap1
	push	hl
	or	a, a
	sbc	hl, hl
	add	hl, bc
	pop	bc
.colorSwap1:
	ld	a, (de)
	sub	a, (hl)
	jr	nc, .colorSwap2
	ex	de, hl
.colorSwap2:
	ld	a, (bc)
	sub	a, (hl)
	ret	z
	cce	ge_pxl_raster
	ld	ix, $FF0000
	lea	iy, ix+0
	ld	ixl, a
	neg
	ld	(vxDeltaY0), a
; x1-x0
	ld	a, (de)
	ld	(vxValueY1), a
	sub	a, (hl)
	push	af
	ld	iyl, a
	neg
	ld	(vxDeltaY1), a
	ld	a, (hl)
	push	af
	push	bc
	inc	hl
	ld.s	bc, (hl)
	ex	de, hl
	inc	hl
	ld.s	hl, (hl)
	ld	(vxValueX1), hl
	jr	z, .rasterNoEdgeWrite
	ld	a, $13
	or	a, a
	sbc	hl, bc
	jr	nc, .rasterEdge1
	or	a, $08
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
.rasterEdge1:
	ld	(vxDeltaX1), hl
	ld	(vxSMC_Code1), a
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
.rasterNoEdgeWrite:
	pop	hl
; x2-x0
	inc	hl
	ld.s	hl, (hl)
	ld	(vxValueX2), hl
	ld	a, $23			; inc hl
	or	a, a
	sbc	hl, bc
; if x0>x1, edge goes to left
	jr	nc, .rasterEdge0
	or	a, $08			; dec hl
; edge goes to left
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
.rasterEdge0:
	ld	(vxDeltaX0), hl
	ld	(vxSMC_Code0), a
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
	call	nz, .rasterTriangleInner
	ld	a, (vxDeltaY0) ; y2-y0
	ld	c, a
	ld	a, (vxDeltaY1)
	sub	a, c
	ret	z
	cce	ge_pxl_raster
	push	af
	ld	iyl, a
	neg
	ld	(vxDeltaY1), a
	push	hl
vxValueX2:=$+1
	ld	hl, $000000
vxValueX1:=$+1
	ld	bc, $000000
	or	a, a
	sbc	hl, bc
	ld	a, $13
; if x0>x1, edge goes to left
	jr	nc, .rasterEdge2
	or	a, $08
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
.rasterEdge2:
	ld	(vxDeltaX1), hl
	ld	(vxSMC_Code1), a
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
vxValueY1:=$+1
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
.rasterTriangleInner:
vxDeltaX0:=$+1
	ld	bc, $000000
	add	ix, bc
	jr	nc, $+11
vxDeltaY0:=$+1
	ld	bc, $FFFF00
vxSMC_Code0:=$
	nop
	add	ix, bc
	jr	c, $-3
vxDeltaX1:=$+1
	ld	bc, $000000
	add	iy, bc
	jr	nc, $+13
vxDeltaY1:=$+1
	ld	bc, $FFFF00
vxSMC_Code1:=$
	nop
	add	iy, bc
	jr	c, $-3
	inc.s	bc ;reset bcu set by restoring ld bc,$FFxxxx
; hl = adress1, de = adress2
	sbc	hl, de
	jr	c, .rasterInverted
	jr	z, .rasterNoPixel
	ld	b, h
	ld	c, l

	ld	hl, VX_PRIMITIVE_COLOR_RBG
	ldi
	jp	po, .rasterContinue
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
	jr	nz,.rasterTriangleInner
if defined VX_DEBUG_CC_INSTRUCTION
	push	hl
	push	de
	ccr	ge_pxl_raster
	pop	de
	pop	hl
end if
	ret
.rasterContinue:
	scf
	sbc	hl, hl
.rasterNoPixel:
	add	hl, de
	ld	bc, 320
	add	hl, bc
	ex	de, hl
	add	hl, bc
	dec	a
	jr	nz, .rasterTriangleInner
if defined VX_DEBUG_CC_INSTRUCTION
	push	hl
	push	de
	ccr	ge_pxl_raster
	pop	de
	pop	hl
end if
	ret
.rasterInverted:
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
	jr	z, .rasterSize1
	push	de
	sbc	hl, hl
	add	hl, de
	inc	de
	ldir
	pop	de
.rasterSize1:
	inc	hl
	ld	c, 64
	inc	b
	add	hl, bc
	ex	de, hl
	add	hl, bc
	dec	a
	jq	nz, .rasterTriangleInner
if defined VX_DEBUG_CC_INSTRUCTION
	push	hl
	push	de
	ccr	ge_pxl_raster
	pop	de
	pop	hl
end if
	ret
