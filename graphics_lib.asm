; quickly hacked C routines to be able to display digits


;-------------------------------------------------------------------------------
; Used throughout the library
lcdSize                 equ lcdWidth*lcdHeight
currDrawBuffer          equ 0E30014h
_GetTextX:
; Gets the X position of the text cursor
; Arguments:
;  None
; Returns:
;  X Text cursor posistion
	ld	hl,(TextXPos_SMC) 
	ret

;-------------------------------------------------------------------------------
_GetTextY:
; Gets the Y position of the text cursor
; Arguments:
;  None
; Returns:
;  Y Text cursor posistion
	ld	a,(TextYPos_SMC) 
	ret

;-------------------------------------------------------------------------------
_SetTextBGColorC:
; Sets the background text color for text routines
; Arguments:
;  arg0 : Color index to set BG to
; Returns:
;  Previous text color palette index
	pop	hl
	pop	de
	push	de
	push	hl
	ld	hl,TextBGColor_SMC 
	ld	a,(hl)
	ld	(hl),e
	ret

;-------------------------------------------------------------------------------
_SetTextFGColorC:
; Sets the foreground text color for text routines
; Arguments:
;  arg0 : Color index to set FG to
; Returns:
;  Previous text color palette index
	pop	hl
	pop	de
	push	de
	push	hl
	ld	hl,TextFGColor_SMC 
	ld	a,(hl)
	ld	(hl),e
	ret

;-------------------------------------------------------------------------------
_SetTextTransparentColorC:
; Sets the transparency text color for text routines
; Arguments:
;  arg0 : Color index to set transparent text to
; Returns:
;  Previous text color palette index
	pop	hl
	pop	de
	push	de
	push	hl
	ld	hl,TextTransColor_SMC 
	ld	a,(hl)
	ld	(hl),e
	ret
	
;-------------------------------------------------------------------------------
_SetTextXY:
; Sets the transparency text color for text routines
; Arguments:
;  arg0 : Text X Pos
;  arg1 : Text Y Pos
; Returns:
;  None
	ld	hl,3
	add	hl,sp
	ld	de,TextXPos_SMC 
	ldi
	ldi
	inc	hl
	ld	a,(hl)
	ld	(TextYPos_SMC),a 
	ret
_PrintChar:
; Places a character at the current cursor position
; Arguments:
;  arg0 : Character to draw
; Returns:
;  None
	ld	iy,0
	add	iy,sp
	ld	a,(iy+3)
_PrintChar_ASM:
	push	ix				; save stack pointer
	push	hl				; save hl pointer if string
	ld	e,a				; e = char
MonoFlag_SMC =$+1
	ld	a,0
	or	a,a
	jr	nz,+_
	sbc	hl,hl
	ld	l,e				; hl = character
	ld	bc,(CharSpacing_ASM) 
	add	hl,bc
	ld	a,(hl)				; a = char width
TextXPos_SMC = $+1
_:	ld	bc,0
	sbc	hl,hl
	ld	l,a
	ld	ixh,a				; ixh = char width
	add	hl,bc
	ld	(TextXPos_SMC),hl 
TextYPos_SMC = $+1
	ld	l,0
	ld	h,lcdWidth/2
	mlt	hl
	add	hl,hl
	add	hl,bc
	ld	bc,(vxFramebuffer)
	add	hl,bc
	ex	de,hl				; de = draw location
	ld	a,l				; l = character
	sbc	hl,hl
	ld	l,a				; hl = character
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	bc,(TextData_ASM) 		; get text data array
	add	hl,bc
	ld	iy,0
UseLargeFont_SMC =$+1
	ld	a,0
	or	a,a
	jr	nz,_PrintLargeFont_ASM
	ld	ixl,8
_:	ld	c,(hl)				; c = 8 pixels
	add	iy,de				; get draw location
	lea	de,iy
	ld	b,ixh
TextBGColor_SMC =$+1
_:	ld	a,0
	rlc	c
	jr	nc,+_
TextFGColor_SMC =$+1
	ld	a,255
TextTransColor_SMC =$+1
_:	cp	a,0				; check if transparent
	jr	z,+_
	ld	(de),a
_:	inc	de				; move to next pixel
	djnz	---_
	ld	de,lcdWidth
	inc	hl
	dec	ixl
	jr	nz,----_
	pop	hl				; restore hl and stack pointer
	pop	ix
	ret
	
_PrintLargeFont_ASM:
	ld	ixl,16
_:	ld	c,(hl)				; c = 8 pixels
	add	iy,de				; get draw location
	lea	de,iy
	ld	b,ixh
_:	ld	a,(TextBGColor_SMC)
	rlc	c
	jr	nc,+_
	ld	a,(TextFGColor_SMC)
_:	cp	a,ixl				; check if transparent
	jr	z,+_
	ld	(de),a
	inc	de
	ld	(de),a
_:	inc	de				; move to next pixel
	djnz	---_
	ld	de,lcdWidth
	inc	hl
	dec	ixl
	jr	nz,----_
	pop	hl				; restore hl and stack pointer
	pop	ix
	ret
	
;-------------------------------------------------------------------------------
_PrintUInt:
; Places an unsigned int at the current cursor position
; Arguments:
;  arg0 : Number to print
;  arg1 : Number of characters to print
; Returns:
;  None
	ld	iy,0
	add	iy,sp
	ld	hl,(iy+3)
	ld	c,(iy+6)
_PrintUInt_ASM:
	ld	a,8
	sub	a,c
	ret	c
	ld	c,a
	ld	b,8
	mlt	bc
	ld	a,c
	ld	(Offset_SMC),a 
Offset_SMC =$+1
	jr	$
	ld	bc,-10000000
	call	Num1 
	ld	bc,-1000000
	call	Num1 
	ld	bc,-100000
	call	Num1 
	ld	bc,-10000
	call	Num1 
	ld	bc,-1000
	call 	Num1 
	ld	bc,-100
	call	Num1 
	ld	bc,-10
	call	Num1 
	ld	bc,-1
Num1:	ld	a,'0'-1
Num2:	inc	a
	add	hl,bc
	jr	c,Num2
	sbc	hl,bc
	jp	_PrintChar_ASM 
 
;-------------------------------------------------------------------------------
_PrintInt:
; Places an int at the current cursor position
; Arguments:
;  arg0 : Number to print
;  arg1 : Number of characters to print
; Returns:
;  None
	ld	iy,0
	lea	bc,iy
	add	iy,sp
	ld	c,(iy+6)
	ld	hl,(iy+3)
	bit	7,(iy+5)
	jr	z,+_
	push	bc
	push	hl
	pop	bc
	sbc	hl,hl
	sbc	hl,bc
	ld	a,'-'
	call	_PrintChar_ASM 
	pop	bc
_:	jp	_PrintUInt_ASM 

;-------------------------------------------------------------------------------
_GetStringWidth:
; Gets the width of a string
; Arguments:
;  arg0 : Pointer to string
; Returns:
;  Width of string in pixels
	pop	de
	pop	hl
	push	hl
	push	de
	ld	bc,0
_:	ld	a,(hl)
	or	a,a
	jr	z,+_
	push	hl
	call	_GetCharWidth_ASM 
	pop	hl
	inc	hl
	jr	-_
_:	push	bc
	pop	hl
	ret

;-------------------------------------------------------------------------------	
_GetCharWidth:
; Gets the width of a character
; Arguments:
;  arg0 : Character
; Returns:
;  Width of character in pixels
	ld	iy,0
	lea	bc,iy
	add	iy,sp
	ld	a,(iy+3)
_GetCharWidth_ASM:
	or	a,a
	sbc	hl,hl
	ld	l,a
	ld	a,(MonoFlag_SMC) 
	or	a,a
	jr	nz,+_
	ld	de,(CharSpacing_ASM) 
	add	hl,de
	ld	a,(hl)
	sbc	hl,hl
	ld	l,a
	add	hl,bc
	push	hl
	pop	bc
	ret
_:	sbc	hl,hl
	ld	l,a
	add	hl,bc
	ret

;-------------------------------------------------------------------------------
_SetCustomFontData:
; Sets the font to be custom
; Arguments:
;  arg0 : Pointer to font data
;  Set Pointer to NULL to use default font
; Returns:
;  None
	pop	de
	pop	hl
	push	hl
	push	de
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	nz,+_
	ld	hl,Char000 
_:	ld	(TextData_ASM),hl 
	ret

;-------------------------------------------------------------------------------
_SetCustomFontSpacing:
; Sets the font to be custom spacing
; Arguments:
;  arg0 : Pointer to font spacing
;  Set Pointer to NULL to use default font spacing
; Returns:
;  None
	pop	de
	pop	hl
	push	hl
	push	de
	add	hl,de
	or	a,a
	sbc	hl,de
	jr	nz,+_
	ld	hl,DefaultCharSpacing_ASM 
_:	ld	(CharSpacing_ASM),hl 
	ret

;-------------------------------------------------------------------------------
_SetMonospaceFont:
; Sets the font to be monospace
; Arguments:
;  arg0 : Monospace spacing amount
; Returns:
;  None
	pop	hl
	pop	de
	push	de
	push	hl
	ld	a,e
	ld	(MonoFlag_SMC),a 
	ret


;-------------------------------------------------------------------------------
_Max_ASM:
; Calculate the resut of a signed comparison
; Inputs:
;  DE,HL=numbers
; Oututs:
;  HL=max number
	or	a,a
	sbc	hl,de
	add	hl,de
	jp	p,+_ 
	ret	pe
	ex	de,hl
_:	ret	po
	ex	de,hl
	ret

;-------------------------------------------------------------------------------
_Min_ASM:
; Calculate the resut of a signed comparison
; Inputs:
;  DE,HL=numbers
; Oututs:
;  HL=min number
	or	a,a
	sbc	hl,de
	ex	de,hl
	jp	p,_ 
	ret	pe
	add	hl,de
_:	ret	po
	add	hl,de
	ret

;-------------------------------------------------------------------------------
_ClipRectangularRegion_ASM:
; Calculates the new coordinates given the clip  and inputs
; Inputs:
;  None
; Outputs:
;  Modifies data registers
;  Sets C flag if offscreen
	ld	hl,(_xmin) 
	ld	de,(iy+3)
	call	_Max_ASM 
	ld	(iy+3),hl
	ld	hl,(_xmax) 
	ld	de,(iy+9)
	call	_Min_ASM 
	ld	(iy+9),hl
	ld	de,(iy+3)
	call	_SignedCompare_ASM 
	ret	c
	ld	hl,(_ymin) 
	ld	de,(iy+6)
	call	_Max_ASM 
	ld	(iy+6),hl
	ld	hl,(_ymax) 
	ld	de,(iy+12)
	call	_Min_ASM 
	ld	(iy+12),hl
	ld	de,(iy+6)
_SignedCompare_ASM:
	or	a,a
	sbc	hl,de
	add	hl,hl
	ret	po
	ccf
	ret

;-------------------------------------------------------------------------------
_SetFullScreenClipping_ASM:
; Sets the clipping  to the entire screen
; Inputs:
;  None
; Outputs:
;  HL=0
	ld	hl,lcdWidth
	ld	(_xmax),hl 
	ld	hl,lcdHeight
	ld	(_ymax),hl 
	ld	l,0
	ld	(_xmin),hl 
	ld	(_ymin),hl 
	ret

;-------------------------------------------------------------------------------
__idivs_ASM:
; Performs signed interger division
; Inputs:
;  HL : Operand 1
;  BC : Operand 2
; Outputs:
;  HL = HL/BC
	ex	de,hl
	xor	a,a
	sbc	hl,hl
	sbc	hl,bc
	jp	p,+_ 
	push	hl
	pop	bc
	inc	a

_:	or	a,a
	sbc	hl,hl
	sbc	hl,de
	jp	m,+_ 
	ex	de,hl
	inc	a

_:	add	hl,de
	rra
	ld	a,24

_:	ex	de,hl
	adc	hl,hl
	ex	de,hl
	adc	hl,hl
	add	hl,bc
	jr	c,+_
	sbc	hl,bc
_:	dec	a
	jr	nz,--_

	ex	de,hl
	adc	hl,hl
	ret	c
	ex	de,hl
	sbc	hl,hl
	sbc	hl,de
	ret

;-------------------------------------------------------------------------------
__imuls_ASM:
__imulu_ASM:
; Performs (un)signed integer multiplication
; Inputs:
;  HL : Operand 1
;  BC : Operand 2
; Outputs:
;  HL = HL*BC
	push	bc
	push	hl
	ex	de,hl
	ld	hl,2
	add	hl,sp
	ld	b,(hl)
	mlt	bc
	inc	hl
	inc	hl
	inc	hl
	ld	a,d
	ld	d,(hl)
	mlt	de
	dec	hl
	ld	l,(hl)
	ld	h,a
	mlt	hl
	ld	a,l
	add	a,e
	add	a,c
	pop	de
	pop	bc
	push	bc
	or	a,a
	sbc	hl,hl
	add.s	hl,de
	ex	de,hl
	ld	h,b
	mlt	hl
	ld	b,d
	mlt	bc
	add	hl,bc
	add	a,h
	ld	h,a
	pop	bc
	ld	d,c
	mlt	de
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,de
	ret

;-------------------------------------------------------------------------------
_ComputeOutcode_ASM:
; Compute the bitcode for a point (x, y) using the clip rectangle
; bounded diagonally by (xmin, ymin), and (xmax, ymax)
; Inputs:
;  HL : X Argument
;  DE : Y Argument
; Outputs:
;   A : Bitcode
	ld	bc,(_xmin) 
	push	hl
	xor	a,a
	sbc	hl,bc
	pop	bc
	add	hl,hl
	jp	po,+_ 
	ccf
_:	rla
	ld	hl,(_xmax) 
	sbc	hl,bc
	add	hl,hl
	jp	po,+_ 
	ccf
_:	rla
	ld	hl,(_ymin) 
	scf
	sbc	hl,de
	add	hl,hl
	jp	pe,+_ 
	ccf
_:	rla
	ld	hl,(_ymax) 
	sbc	hl,de
	add	hl,hl
	rla
	ret	po
	xor	a,1
	ret

;-------------------------------------------------------------------------------
CharSpacing_ASM:
	.dl DefaultCharSpacing_ASM 
TextData_ASM:
	.dl DefaultTextData_ASM 

DefaultCharSpacing_ASM:
	;   0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F
	.db 8,8,8,8,8,8,8,8,8,8,8,8,8,2,8,8
	.db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	.db 3,4,6,8,8,8,8,5,5,5,8,7,4,7,3,8
	.db 8,7,8,8,8,8,8,8,8,8,3,4,6,7,6,7
	.db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	.db 8,8,8,8,8,8,8,8,8,8,8,5,8,5,8,8
	.db 4,8,8,8,8,8,8,8,8,5,8,8,5,8,8,8
	.db 8,8,8,8,7,8,8,8,8,8,8,7,3,7,8,8
	.db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
	.db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
 
;-------------------------------------------------------------------------------
DefaultTextData_ASM:
Char000: .db $00,$00,$00,$00,$00,$00,$00,$00	; .
Char001: .db $7E,$81,$A5,$81,$BD,$BD,$81,$7E	; .
Char002: .db $7E,$FF,$DB,$FF,$C3,$C3,$FF,$7E	; .
Char003: .db $6C,$FE,$FE,$FE,$7C,$38,$10,$00	; .
Char004: .db $10,$38,$7C,$FE,$7C,$38,$10,$00	; .
Char005: .db $38,$7C,$38,$FE,$FE,$10,$10,$7C	; .
Char006: .db $00,$18,$3C,$7E,$FF,$7E,$18,$7E	; .
Char007: .db $00,$00,$18,$3C,$3C,$18,$00,$00	; .
Char008: .db $FF,$FF,$E7,$C3,$C3,$E7,$FF,$FF	; .
Char009: .db $00,$3C,$66,$42,$42,$66,$3C,$00	; .
Char010: .db $FF,$C3,$99,$BD,$BD,$99,$C3,$FF	; .
Char011: .db $0F,$07,$0F,$7D,$CC,$CC,$CC,$78	; .
Char012: .db $3C,$66,$66,$66,$3C,$18,$7E,$18	; .
Char013: .db $3F,$33,$3F,$30,$30,$70,$F0,$E0	; .
Char014: .db $7F,$63,$7F,$63,$63,$67,$E6,$C0	; .
Char015: .db $99,$5A,$3C,$E7,$E7,$3C,$5A,$99	; .
Char016: .db $80,$E0,$F8,$FE,$F8,$E0,$80,$00	; .
Char017: .db $02,$0E,$3E,$FE,$3E,$0E,$02,$00	; .
Char018: .db $18,$3C,$7E,$18,$18,$7E,$3C,$18	; .
Char019: .db $66,$66,$66,$66,$66,$00,$66,$00	; .
Char020: .db $7F,$DB,$DB,$7B,$1B,$1B,$1B,$00	; .
Char021: .db $3F,$60,$7C,$66,$66,$3E,$06,$FC	; .
Char022: .db $00,$00,$00,$00,$7E,$7E,$7E,$00	; .
Char023: .db $18,$3C,$7E,$18,$7E,$3C,$18,$FF	; .
Char024: .db $18,$3C,$7E,$18,$18,$18,$18,$00	; .
Char025: .db $18,$18,$18,$18,$7E,$3C,$18,$00	; .
Char026: .db $00,$18,$0C,$FE,$0C,$18,$00,$00	; .
Char027: .db $00,$30,$60,$FE,$60,$30,$00,$00	; .
Char028: .db $00,$00,$C0,$C0,$C0,$FE,$00,$00	; .
Char029: .db $00,$24,$66,$FF,$66,$24,$00,$00	; .
Char030: .db $00,$18,$3C,$7E,$FF,$FF,$00,$00	; .
Char031: .db $00,$FF,$FF,$7E,$3C,$18,$00,$00	; .
Char032: .db $00,$00,$00,$00,$00,$00,$00,$00	;  
Char033: .db $C0,$C0,$C0,$C0,$C0,$00,$C0,$00	; !
Char034: .db $D8,$D8,$D8,$00,$00,$00,$00,$00	; "
Char035: .db $6C,$6C,$FE,$6C,$FE,$6C,$6C,$00	; #
Char036: .db $18,$7E,$C0,$7C,$06,$FC,$18,$00	; $
Char037: .db $00,$C6,$CC,$18,$30,$66,$C6,$00	; %
Char038: .db $38,$6C,$38,$76,$DC,$CC,$76,$00	; &
Char039: .db $30,$30,$60,$00,$00,$00,$00,$00	; '
Char040: .db $30,$60,$C0,$C0,$C0,$60,$30,$00	; (
Char041: .db $C0,$60,$30,$30,$30,$60,$C0,$00	; )
Char042: .db $00,$66,$3C,$FF,$3C,$66,$00,$00	; *
Char043: .db $00,$30,$30,$FC,$FC,$30,$30,$00	; +
Char044: .db $00,$00,$00,$00,$00,$60,$60,$C0	; ,
Char045: .db $00,$00,$00,$FC,$00,$00,$00,$00	; -
Char046: .db $00,$00,$00,$00,$00,$C0,$C0,$00	; .
Char047: .db $06,$0C,$18,$30,$60,$C0,$80,$00	; /
Char048: .db $7C,$CE,$DE,$F6,$E6,$C6,$7C,$00	; 0
Char049: .db $30,$70,$30,$30,$30,$30,$FC,$00	; 1
Char050: .db $7C,$C6,$06,$7C,$C0,$C0,$FE,$00	; 2
Char051: .db $FC,$06,$06,$3C,$06,$06,$FC,$00	; 3
Char052: .db $0C,$CC,$CC,$CC,$FE,$0C,$0C,$00	; 4
Char053: .db $FE,$C0,$FC,$06,$06,$C6,$7C,$00	; 5
Char054: .db $7C,$C0,$C0,$FC,$C6,$C6,$7C,$00	; 6
Char055: .db $FE,$06,$06,$0C,$18,$30,$30,$00	; 7
Char056: .db $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	; 8
Char057: .db $7C,$C6,$C6,$7E,$06,$06,$7C,$00	; 9
Char058: .db $00,$C0,$C0,$00,$00,$C0,$C0,$00	; :
Char059: .db $00,$60,$60,$00,$00,$60,$60,$C0	; ;
Char060: .db $18,$30,$60,$C0,$60,$30,$18,$00	; <
Char061: .db $00,$00,$FC,$00,$FC,$00,$00,$00	; =
Char062: .db $C0,$60,$30,$18,$30,$60,$C0,$00	; >
Char063: .db $78,$CC,$18,$30,$30,$00,$30,$00	; ?
Char064: .db $7C,$C6,$DE,$DE,$DE,$C0,$7E,$00	; @
Char065: .db $38,$6C,$C6,$C6,$FE,$C6,$C6,$00	; A
Char066: .db $FC,$C6,$C6,$FC,$C6,$C6,$FC,$00	; B
Char067: .db $7C,$C6,$C0,$C0,$C0,$C6,$7C,$00	; C
Char068: .db $F8,$CC,$C6,$C6,$C6,$CC,$F8,$00	; D
Char069: .db $FE,$C0,$C0,$F8,$C0,$C0,$FE,$00	; E
Char070: .db $FE,$C0,$C0,$F8,$C0,$C0,$C0,$00	; F
Char071: .db $7C,$C6,$C0,$C0,$CE,$C6,$7C,$00	; G
Char072: .db $C6,$C6,$C6,$FE,$C6,$C6,$C6,$00	; H
Char073: .db $7E,$18,$18,$18,$18,$18,$7E,$00	; I
Char074: .db $06,$06,$06,$06,$06,$C6,$7C,$00	; J
Char075: .db $C6,$CC,$D8,$F0,$D8,$CC,$C6,$00	; K
Char076: .db $C0,$C0,$C0,$C0,$C0,$C0,$FE,$00	; L
Char077: .db $C6,$EE,$FE,$FE,$D6,$C6,$C6,$00	; M
Char078: .db $C6,$E6,$F6,$DE,$CE,$C6,$C6,$00	; N
Char079: .db $7C,$C6,$C6,$C6,$C6,$C6,$7C,$00	; O
Char080: .db $FC,$C6,$C6,$FC,$C0,$C0,$C0,$00	; P
Char081: .db $7C,$C6,$C6,$C6,$D6,$DE,$7C,$06	; Q
Char082: .db $FC,$C6,$C6,$FC,$D8,$CC,$C6,$00	; R
Char083: .db $7C,$C6,$C0,$7C,$06,$C6,$7C,$00	; S
Char084: .db $FF,$18,$18,$18,$18,$18,$18,$00	; T
Char085: .db $C6,$C6,$C6,$C6,$C6,$C6,$FE,$00	; U
Char086: .db $C6,$C6,$C6,$C6,$C6,$7C,$38,$00	; V
Char087: .db $C6,$C6,$C6,$C6,$D6,$FE,$6C,$00	; W
Char088: .db $C6,$C6,$6C,$38,$6C,$C6,$C6,$00	; X
Char089: .db $C6,$C6,$C6,$7C,$18,$30,$E0,$00	; Y
Char090: .db $FE,$06,$0C,$18,$30,$60,$FE,$00	; Z
Char091: .db $F0,$C0,$C0,$C0,$C0,$C0,$F0,$00	; [
Char092: .db $C0,$60,$30,$18,$0C,$06,$02,$00	; \
Char093: .db $F0,$30,$30,$30,$30,$30,$F0,$00	; ]
Char094: .db $10,$38,$6C,$C6,$00,$00,$00,$00	; ^
Char095: .db $00,$00,$00,$00,$00,$00,$00,$FF	; _
Char096: .db $C0,$C0,$60,$00,$00,$00,$00,$00	; `
Char097: .db $00,$00,$7C,$06,$7E,$C6,$7E,$00	; a
Char098: .db $C0,$C0,$C0,$FC,$C6,$C6,$FC,$00	; b
Char099: .db $00,$00,$7C,$C6,$C0,$C6,$7C,$00	; c
Char100: .db $06,$06,$06,$7E,$C6,$C6,$7E,$00	; d
Char101: .db $00,$00,$7C,$C6,$FE,$C0,$7C,$00	; e
Char102: .db $1C,$36,$30,$78,$30,$30,$78,$00	; f
Char103: .db $00,$00,$7E,$C6,$C6,$7E,$06,$FC	; g
Char104: .db $C0,$C0,$FC,$C6,$C6,$C6,$C6,$00	; h
Char105: .db $60,$00,$E0,$60,$60,$60,$F0,$00	; i
Char106: .db $06,$00,$06,$06,$06,$06,$C6,$7C	; j
Char107: .db $C0,$C0,$CC,$D8,$F8,$CC,$C6,$00	; k
Char108: .db $E0,$60,$60,$60,$60,$60,$F0,$00	; l
Char109: .db $00,$00,$CC,$FE,$FE,$D6,$D6,$00	; m
Char110: .db $00,$00,$FC,$C6,$C6,$C6,$C6,$00	; n
Char111: .db $00,$00,$7C,$C6,$C6,$C6,$7C,$00	; o
Char112: .db $00,$00,$FC,$C6,$C6,$FC,$C0,$C0	; p
Char113: .db $00,$00,$7E,$C6,$C6,$7E,$06,$06	; q
Char114: .db $00,$00,$FC,$C6,$C0,$C0,$C0,$00	; r
Char115: .db $00,$00,$7E,$C0,$7C,$06,$FC,$00	; s
Char116: .db $30,$30,$FC,$30,$30,$30,$1C,$00	; t
Char117: .db $00,$00,$C6,$C6,$C6,$C6,$7E,$00	; u
Char118: .db $00,$00,$C6,$C6,$C6,$7C,$38,$00	; v
Char119: .db $00,$00,$C6,$C6,$D6,$FE,$6C,$00	; w
Char120: .db $00,$00,$C6,$6C,$38,$6C,$C6,$00	; x
Char121: .db $00,$00,$C6,$C6,$C6,$7E,$06,$FC	; y
Char122: .db $00,$00,$FE,$0C,$38,$60,$FE,$00	; z
Char123: .db $1C,$30,$30,$E0,$30,$30,$1C,$00	; {
Char124: .db $C0,$C0,$C0,$00,$C0,$C0,$C0,$00	; |
Char125: .db $E0,$30,$30,$1C,$30,$30,$E0,$00	; }
Char126: .db $76,$DC,$00,$00,$00,$00,$00,$00	; ~
Char127: .db $00,$10,$38,$6C,$C6,$C6,$FE,$00	; .

;-------------------------------------------------------------------------------
; Inner library data
;-------------------------------------------------------------------------------
 
_xmin:
	.dl 0
_ymin:
	.dl 0
_xmax:
	.dl lcdWidth
_ymax:
	.dl lcdHeight

tmpWidth:
	.dl 0,0,0