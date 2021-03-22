; code start - framebuffer functions

define	VX_FRAMEBUFFER_AUX0	$D40000		; first VRAM buffer
define	VX_FRAMEBUFFER_AUX1	$D52C00		; second VRAM buffer
define	VX_FRAMEBUFFER_SIZE	$12C00
define	VX_VRAM			$E30800
define	VX_BPP8			ti.lcdBpp8	; LCD 8 bpp mode bits
define	VX_BPP16		ti.lcdBpp16	; LCD 16 bpp mode bits
define	VX_LCD_CTRL		ti.mpLcdCtrl	; LCD control port
define	VX_LCD_IMSC		$E3001C		; LCD Interrupt Mask Register
define	VX_LCD_ICR		$E30028		; LCD Interrupt Clear/Set Register
define	VX_LCD_ISR		$E30020		; LCD Interrupt Status Register
define	VX_LCD_BUFFER		$E30010		; base adress of LCD
define	VX_LCD_PALETTE		ti.mpLcdPalette	; palette (r3g3b2)
define	VX_LCD_TIMING		$E30000
define	VX_GREEN_BITS		00000111b
define	VX_RED_BITS		11100000b
define	VX_BLUE_BITS		00011000b
define	vxFramebuffer		$E30014
define	vxFrontbuffer		$E30010

; w x h x option
VX_LCD_SETTING:
 db	0, 0, 0

vxFramebufferSetup:
	ld	hl, VX_LCD_IMSC
	set	2, (hl)
	ld	l, VX_LCD_ICR and $FF
	ld	(hl), $FF
; setup 8bpp mode
	ld	l, VX_LCD_CTRL and $FF
	ld	(hl), VX_BPP8
; load vram buffer
	ld	l, VX_LCD_BUFFER and $FF
	ld	bc, VX_FRAMEBUFFER_AUX0
	ld	(hl), bc
	call	vxFramebufferAllocate
; setup LCD timings
; assume c is 0
; .swapTiming:
; 	ld	l, (VX_LCD_TIMING+1) and $FF
; 	ld	de, VX_LCD_TIMING_CACHE
; 	ex	de, hl
; 	ld	b, 8 + 1
; .swapLoop:			; exchange stored and active timing
; 	ld	a,(de)
; 	ldi
; 	dec	hl
; 	ld	(hl),a
; 	inc	hl
; 	djnz	.swapLoop
; ; continue
	
vxFramebufferResetPalette:
; load palette :
; color is 3-3-2 format, RGB
; calculate 1555 format color
	ld	hl,VX_LCD_PALETTE  ; palette mem
	ld	b, 0
.resetLoop:      ; this loop is from wikiti
	ld	d, b
	ld	a, b
	and	a, 11000000b
	srl	d
	rra
	ld	e, a
	ld	a, 00011111b
	and	a, b
	or	a, e
	ld	(hl), a
	inc	hl
	ld	(hl), d
	inc	hl
	inc	b
	jr	nz, .resetLoop
	ret

vxFramebufferRestore:
; restore timings and other
	ld	hl, VX_LCD_IMSC
	res	2, (hl)
	ld	l, VX_LCD_ICR and $FF
	ld	(hl), $FF
	ld	l, VX_LCD_CTRL and $FF
	ld	(hl), VX_BPP16
	ld	bc, VX_FRAMEBUFFER_AUX0
	ld	l, VX_LCD_BUFFER and $FF
	ld	(hl), bc
; c is 0 here
; 	jr	vxFramebufferSetup.swapTiming
	ret
	
vxFramebufferSetPalette:
; set the framebuffer palette
; input : hl
	ld	de, VX_LCD_PALETTE
	ld	bc, 512
	ldir
	ret
	
vxFramebufferAllocate:
; setup buffer of correct resolution
; 160x120 : we need one buffer for rendering, one buffer for DMA with screen
; 320x240 : two buffer, one back buffer, one front buffer



	ld	hl, VX_FRAMEBUFFER_AUX0
	ld	(VX_LCD_BUFFER), hl
	ld	hl, VX_FRAMEBUFFER_AUX1
	ld	(vxFramebuffer), hl
	ret

vxFramebufferSwap:
; wait for the possibility to swap base pointer ?
	ld	hl, (VX_LCD_BUFFER) 
	ld	de, (vxFramebuffer)
	ld	(vxFramebuffer), hl
	ld	(VX_LCD_BUFFER), de

vxFramebufferVsync:
	ld	hl, VX_LCD_ISR
.waitVcomp:
	bit	2, (hl)
	jr	z, .waitVcomp
; wait until the LCD finish displaying the frame
	ld	l, VX_LCD_ICR and $FF
	set	2, (hl)
	ret

	
vxFramebufferClearColor:
	cce	fb_ops
	or	a, a
	sbc	hl, hl
	ld	h, c
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	h, c
	ld	l, c
	ex	de, hl
	sbc	hl, hl
	jr	vxFramebufferClear.entry

vxFramebufferClear:
	cce	fb_ops
	or      a, a
	sbc     hl, hl
	ex	de, hl
	sbc	hl, hl
.entry:
	add     hl, sp           ; saves SP in HL
	ld	ix, (vxFramebuffer)
	ld	bc, 76800
	add	ix, bc
	ld	sp, ix
	ld      b, 213
	di
.loop:
	db	120 dup $D5
	djnz	.loop
	db	40 dup $D5
	ld      sp, hl
	ccr	fb_ops
	ret
	
vxFramebufferScale2x:
	cce	fb_ops
	call	vxFramebufferVsync
	ld	hl, (vxFramebuffer)
	ld	de, (VX_LCD_BUFFER)
	ld	bc, 0
	ld	a, 120
.outerWriteVram:
	push	af
	ld	c, 160
	push	de
.innerWriteVram:
	ld	a, (hl)
	ldi
	ld	(de), a
	inc	de
	ld	a, (hl)
	ldi
	ld	(de), a
	inc	de
	ld	a, (hl)
	ldi
	ld	(de), a
	inc	de
	ld	a, (hl)
	ldi
	ld	(de), a
	inc	de
	jp	pe, .innerWriteVram
; copy the line just writed
	ex	(sp), hl
	ld	c, 64
	inc	b
	ldir
	pop	hl
	ld	c, 160
	add	hl, bc
	pop	af
	dec	a
	jr	nz, .outerWriteVram
	ccr	fb_ops
	ret
	
; VX_LCD_TIMING_CACHE:
; ;	db	14 shl 2		; PPL shl 2
; 	db	7			; HSW
; 	db	87			; HFP
; 	db	63			; HBP
; 	dw	(0 shl 10)+319		; (VSW shl 10)+LPP
; 	db	179			; VFP
; 	db	0			; VBP
; 	db	(0 shl 6)+(0 shl 5)+0	; (ACB shl 6)+(CLKSEL shl 5)+PCD_LO
;  H = ((PPL+1)*16)+(HSW+1)+(HFP+1)+(HBP+1) = 240+8+88+64 = 400
;  V = (LPP+1)+(VSW+1)+VFP+VBP = 320+1+179+0 = 500
; CC = H*V*PCD*2 = 400*500*2*2 = 800000
; Hz = 48000000/CC = 60
