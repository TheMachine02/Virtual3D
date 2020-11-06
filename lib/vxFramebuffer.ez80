; code start - framebuffer functions

#define VX_FRAMEBUFFER_AUX0 $D40000	; first VRAM buffer
#define VX_FRAMEBUFFER_AUX1 $D52C00	; second VRAM buffer
#define VX_FRAMEBUFFER_SIZE $12C00
#define VX_VRAM             $E30800
#define VX_BPP8             lcdBpp8   ; LCD 8 bpp mode bits
#define VX_BPP16            lcdBpp16	; LCD 16 bpp mode bits
#define VX_LCD_CTRL         mpLcdCtrl	; LCD control port
#define VX_LCD_IMSC         $E3001C	; LCD Interrupt Mask Register
#define VX_LCD_ICR          $E30028	; LCD Interrupt Clear/Set Register
#define VX_LCD_ISR          $E30020	; LCD Interrupt Status Register
#define VX_LCD_BUFFER       $E30010	; base adress of LCD
#define VX_LCD_PALETTE      mpLcdPalette ; palette (r3g3b2)
#define VX_LCD_TIMING2      $E30008

#define VX_GREEN_BITS	      %00000111
#define VX_RED_BITS         %11100000
#define VX_BLUE_BITS        %00011000
#define VX_COLOR_LOW_BIT    %00101001

#define vxFramebuffer       $E30014

#define WAIT_VSYNC ld	hl, VX_LCD_ICR \ set	2, (hl) \ 	ld l, VX_LCD_ISR&$FF \ bit 2, (hl) \ jr z, $-2

vxResetPalette:
; load palette :
; color is 3-3-2 format, RGB
; calculate 1555 format color
	ld	hl,VX_LCD_PALETTE  ; palette mem
	ld	b,0
vxLoadPaletteLoop:      ; this loop is from wikiti
	ld	d,b
	ld	a,b
	and	%11000000
	srl	d
	rra
	ld	e,a
	ld	a,%00011111
	and	b
	or	e
	ld	(hl),a
	inc	hl
	ld	(hl),d
	inc	hl
	inc	b
	jr nz,vxLoadPaletteLoop
	ret
vxSetPalette:
; set the framebuffer palette
; input : hl
	ld	de, VX_LCD_PALETTE
	ld	bc, 512
	ldir
	ret
vxClearBuffer:
; reset framebuffer with color
; input : c
; output : none
; destroyed : all except ix,iy
	ld	hl, (vxFramebuffer)
	ld	(hl), c
	ex	de, hl
	or	a, a
	sbc	hl, hl
	add	hl, de
	inc	de
	ld	bc, 76799
	ldir
	ret
vxFlushLCD:
; swap the framebuffer and synchronize with LCD
	ld	hl, (VX_LCD_BUFFER) 
	ld	de, (vxFramebuffer)
	ld	(vxFramebuffer), hl
	ld	(VX_LCD_BUFFER), de
;vxWaitLCD:
; wait until the LCD finish displaying the frame
;	ld	hl, VX_LCD_ICR
;	set	2, (hl)
;	ld	l, VX_LCD_ISR&$FF
;vxWaitLoop:
;	bit	2, (hl)
;	jr	z, vxWaitLoop
;	ret
	WAIT_VSYNC
	ret
vxSwapLCD:
; swap buffer without LCD acknowledge
	ld	hl, (VX_LCD_BUFFER) 
	ld	de, (vxFramebuffer)
	ld	(vxFramebuffer), hl
	ld	(VX_LCD_BUFFER), de
	ret
vxLitRBG:
	ld	hl, VX_LUT_CONVOLVE
	ld	l, c
	ld	h, a
	ld	a, (hl)
	ret

vxSpiParam:
 scf ; First bit is set for data
 .db 030h ; jr nc,? ; skips over one byte
vxSpiCmd:
 or a,a ; First bit is clear for commands
 ld hl,0F80818h
 call vxSpiWrite
 ld l,h
 ld (hl),001h
vxSpiWait:
 ld l,00Dh
vxSpiWait1:
 ld a,(hl)
 and a,0F0h
 jr nz,vxSpiWait1
 dec l
vxSpiWait2:
 bit 2,(hl)
 jr nz,vxSpiWait2
 ld l,h
 ld (hl),a
 ret
vxSpiWrite:
 ld b,3
vxSpiWriteLoop:
 rla
 rla
 rla
 ld (hl),a ; send 3 bits
 djnz vxSpiWriteLoop
 ret