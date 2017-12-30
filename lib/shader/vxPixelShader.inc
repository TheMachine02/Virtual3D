#define	VX_PIXEL_SHADER			%00000001
#define	VX_PIXEL_SHADER_CODE		$E10010
#define	VX_PIXEL_SHADER_DATA		$D00000
#define	VX_PIXEL_SHADER_SIZE		64
#define	VX_PIXEL_SHADER_MAX_SIZE	38
#define	VX_PIXEL_SHADER_SUBSIZE	18	; 11

#define	VX_REGISTER_SIZE			12
#define	VX_REGISTER0			0
#define	VX_REGISTER1			3
#define	VX_REGISTER2			6
#define	VX_REGISTER3			9

VX_PIXEL_SHADER_COPY:

.relocate	VX_PIXEL_SHADER_CODE

vxPixelShader:
#comment
	ld	a, h
	add	hl, sp
	exx
	ld	h, a
	ld	e, (hl)
	ld	a, (de)
;	ld	a, (hl)
	adc	hl, bc
;	ld	a, c
;	cp	$FF
;	ld	a, (bc)
	exx
;	jr	z, $+3
	ld	(de), a
	inc	de
	ld	a, h
	add	hl, sp
	exx
	ld	h, a
	ld	e, (hl)
	ld	a, (de)
;	ld	a, (hl)
	adc	hl, bc
;	ld	a, c
;	cp	$FF
;	ld	a, (bc)
	exx
;	jr	z, $+3
	ld	(de), a
	inc	de
#endcomment
	add	hl, sp
	ld	a, h
	exx
	adc	hl, bc
	ld	h, a
	ld	d, (hl)
	exx
	ld	a, (de)
	exx
	ld	e, a
	ld	a, (de)
	set	7, h
	add	a, (hl)
	exx
	ld	(de), a
	inc	de

	add	hl, sp
	ld	a, h
	exx
	adc	hl, bc
	ld	h, a
	ld	d, (hl)
	exx
	ld	a, (de)
	exx
	ld	e, a
	ld	a, (de)
	set	7, h
	add	a, (hl)
	exx
	ld	(de), a
	inc	de
#endcomment
	djnz	vxPixelShader
vxShaderGeneralInterpolation:
	ld	hl, (iy+VX_REGISTER1)
	ld	de, (iy+VX_REGISTER0)
	add	hl, de
	add	hl, hl
	add	hl, hl
	ld	b, (hl)
	inc	hl
	ld	ix, (hl)
	ld	hl, (iy+VX_REGISTER2)	; v
	exx
	ld	hl, (iy+VX_REGISTER3)	; u
	exx
	lea	iy, iy+VX_REGISTER_SIZE
	jp	(ix)
; exactly 64 bytes

.endrelocate

#define	VX_CALL0_POS	VX_PIXEL_SHADER_SUBSIZE*2-1+VX_PIXEL_SHADER_CODE
#define	VX_CALL1_POS	VX_PIXEL_SHADER_SUBSIZE-1+VX_PIXEL_SHADER_CODE
#define	VX_CALL_NULL	(VX_PIXEL_SHADER_SUBSIZE+1)*2+ VX_PIXEL_SHADER_CODE
#define	VX_CALL1_NEG	VX_PIXEL_SHADER_SUBSIZE+VX_PIXEL_SHADER_CODE
#define	VX_CALL0_NEG	VX_PIXEL_SHADER_CODE
#define	VX_CALL_EXIT	vxPixelShaderExit
; pad to four bytes
   .align  4
   .db 161 \ .dl VX_CALL1_NEG
   .db 160 \ .dl VX_CALL0_NEG
   .db 160 \ .dl VX_CALL1_NEG
   .db 159 \ .dl VX_CALL0_NEG
   .db 159 \ .dl VX_CALL1_NEG
   .db 158 \ .dl VX_CALL0_NEG
   .db 158 \ .dl VX_CALL1_NEG
   .db 157 \ .dl VX_CALL0_NEG
   .db 157 \ .dl VX_CALL1_NEG
   .db 156 \ .dl VX_CALL0_NEG
   .db 156 \ .dl VX_CALL1_NEG
   .db 155 \ .dl VX_CALL0_NEG
   .db 155 \ .dl VX_CALL1_NEG
   .db 154 \ .dl VX_CALL0_NEG
   .db 154 \ .dl VX_CALL1_NEG
   .db 153 \ .dl VX_CALL0_NEG
   .db 153 \ .dl VX_CALL1_NEG
   .db 152 \ .dl VX_CALL0_NEG
   .db 152 \ .dl VX_CALL1_NEG
   .db 151 \ .dl VX_CALL0_NEG
   .db 151 \ .dl VX_CALL1_NEG
   .db 150 \ .dl VX_CALL0_NEG
   .db 150 \ .dl VX_CALL1_NEG
   .db 149 \ .dl VX_CALL0_NEG
   .db 149 \ .dl VX_CALL1_NEG
   .db 148 \ .dl VX_CALL0_NEG
   .db 148 \ .dl VX_CALL1_NEG
   .db 147 \ .dl VX_CALL0_NEG
   .db 147 \ .dl VX_CALL1_NEG
   .db 146 \ .dl VX_CALL0_NEG
   .db 146 \ .dl VX_CALL1_NEG
   .db 145 \ .dl VX_CALL0_NEG
   .db 145 \ .dl VX_CALL1_NEG
   .db 144 \ .dl VX_CALL0_NEG
   .db 144 \ .dl VX_CALL1_NEG
   .db 143 \ .dl VX_CALL0_NEG
   .db 143 \ .dl VX_CALL1_NEG
   .db 142 \ .dl VX_CALL0_NEG
   .db 142 \ .dl VX_CALL1_NEG
   .db 141 \ .dl VX_CALL0_NEG
   .db 141 \ .dl VX_CALL1_NEG
   .db 140 \ .dl VX_CALL0_NEG
   .db 140 \ .dl VX_CALL1_NEG
   .db 139 \ .dl VX_CALL0_NEG
   .db 139 \ .dl VX_CALL1_NEG
   .db 138 \ .dl VX_CALL0_NEG
   .db 138 \ .dl VX_CALL1_NEG
   .db 137 \ .dl VX_CALL0_NEG
   .db 137 \ .dl VX_CALL1_NEG
   .db 136 \ .dl VX_CALL0_NEG
   .db 136 \ .dl VX_CALL1_NEG
   .db 135 \ .dl VX_CALL0_NEG
   .db 135 \ .dl VX_CALL1_NEG
   .db 134 \ .dl VX_CALL0_NEG
   .db 134 \ .dl VX_CALL1_NEG
   .db 133 \ .dl VX_CALL0_NEG
   .db 133 \ .dl VX_CALL1_NEG
   .db 132 \ .dl VX_CALL0_NEG
   .db 132 \ .dl VX_CALL1_NEG
   .db 131 \ .dl VX_CALL0_NEG
   .db 131 \ .dl VX_CALL1_NEG
   .db 130 \ .dl VX_CALL0_NEG
   .db 130 \ .dl VX_CALL1_NEG
   .db 129 \ .dl VX_CALL0_NEG
   .db 129 \ .dl VX_CALL1_NEG
   .db 128 \ .dl VX_CALL0_NEG
   .db 128 \ .dl VX_CALL1_NEG
   .db 127 \ .dl VX_CALL0_NEG
   .db 127 \ .dl VX_CALL1_NEG
   .db 126 \ .dl VX_CALL0_NEG
   .db 126 \ .dl VX_CALL1_NEG
   .db 125 \ .dl VX_CALL0_NEG
   .db 125 \ .dl VX_CALL1_NEG
   .db 124 \ .dl VX_CALL0_NEG
   .db 124 \ .dl VX_CALL1_NEG
   .db 123 \ .dl VX_CALL0_NEG
   .db 123 \ .dl VX_CALL1_NEG
   .db 122 \ .dl VX_CALL0_NEG
   .db 122 \ .dl VX_CALL1_NEG
   .db 121 \ .dl VX_CALL0_NEG
   .db 121 \ .dl VX_CALL1_NEG
   .db 120 \ .dl VX_CALL0_NEG
   .db 120 \ .dl VX_CALL1_NEG
   .db 119 \ .dl VX_CALL0_NEG
   .db 119 \ .dl VX_CALL1_NEG
   .db 118 \ .dl VX_CALL0_NEG
   .db 118 \ .dl VX_CALL1_NEG
   .db 117 \ .dl VX_CALL0_NEG
   .db 117 \ .dl VX_CALL1_NEG
   .db 116 \ .dl VX_CALL0_NEG
   .db 116 \ .dl VX_CALL1_NEG
   .db 115 \ .dl VX_CALL0_NEG
   .db 115 \ .dl VX_CALL1_NEG
   .db 114 \ .dl VX_CALL0_NEG
   .db 114 \ .dl VX_CALL1_NEG
   .db 113 \ .dl VX_CALL0_NEG
   .db 113 \ .dl VX_CALL1_NEG
   .db 112 \ .dl VX_CALL0_NEG
   .db 112 \ .dl VX_CALL1_NEG
   .db 111 \ .dl VX_CALL0_NEG
   .db 111 \ .dl VX_CALL1_NEG
   .db 110 \ .dl VX_CALL0_NEG
   .db 110 \ .dl VX_CALL1_NEG
   .db 109 \ .dl VX_CALL0_NEG
   .db 109 \ .dl VX_CALL1_NEG
   .db 108 \ .dl VX_CALL0_NEG
   .db 108 \ .dl VX_CALL1_NEG
   .db 107 \ .dl VX_CALL0_NEG
   .db 107 \ .dl VX_CALL1_NEG
   .db 106 \ .dl VX_CALL0_NEG
   .db 106 \ .dl VX_CALL1_NEG
   .db 105 \ .dl VX_CALL0_NEG
   .db 105 \ .dl VX_CALL1_NEG
   .db 104 \ .dl VX_CALL0_NEG
   .db 104 \ .dl VX_CALL1_NEG
   .db 103 \ .dl VX_CALL0_NEG
   .db 103 \ .dl VX_CALL1_NEG
   .db 102 \ .dl VX_CALL0_NEG
   .db 102 \ .dl VX_CALL1_NEG
   .db 101 \ .dl VX_CALL0_NEG
   .db 101 \ .dl VX_CALL1_NEG
   .db 100 \ .dl VX_CALL0_NEG
   .db 100 \ .dl VX_CALL1_NEG
   .db 99 \ .dl VX_CALL0_NEG
   .db 99 \ .dl VX_CALL1_NEG
   .db 98 \ .dl VX_CALL0_NEG
   .db 98 \ .dl VX_CALL1_NEG
   .db 97 \ .dl VX_CALL0_NEG
   .db 97 \ .dl VX_CALL1_NEG
   .db 96 \ .dl VX_CALL0_NEG
   .db 96 \ .dl VX_CALL1_NEG
   .db 95 \ .dl VX_CALL0_NEG
   .db 95 \ .dl VX_CALL1_NEG
   .db 94 \ .dl VX_CALL0_NEG
   .db 94 \ .dl VX_CALL1_NEG
   .db 93 \ .dl VX_CALL0_NEG
   .db 93 \ .dl VX_CALL1_NEG
   .db 92 \ .dl VX_CALL0_NEG
   .db 92 \ .dl VX_CALL1_NEG
   .db 91 \ .dl VX_CALL0_NEG
   .db 91 \ .dl VX_CALL1_NEG
   .db 90 \ .dl VX_CALL0_NEG
   .db 90 \ .dl VX_CALL1_NEG
   .db 89 \ .dl VX_CALL0_NEG
   .db 89 \ .dl VX_CALL1_NEG
   .db 88 \ .dl VX_CALL0_NEG
   .db 88 \ .dl VX_CALL1_NEG
   .db 87 \ .dl VX_CALL0_NEG
   .db 87 \ .dl VX_CALL1_NEG
   .db 86 \ .dl VX_CALL0_NEG
   .db 86 \ .dl VX_CALL1_NEG
   .db 85 \ .dl VX_CALL0_NEG
   .db 85 \ .dl VX_CALL1_NEG
   .db 84 \ .dl VX_CALL0_NEG
   .db 84 \ .dl VX_CALL1_NEG
   .db 83 \ .dl VX_CALL0_NEG
   .db 83 \ .dl VX_CALL1_NEG
   .db 82 \ .dl VX_CALL0_NEG
   .db 82 \ .dl VX_CALL1_NEG
   .db 81 \ .dl VX_CALL0_NEG
   .db 81 \ .dl VX_CALL1_NEG
   .db 80 \ .dl VX_CALL0_NEG
   .db 80 \ .dl VX_CALL1_NEG
   .db 79 \ .dl VX_CALL0_NEG
   .db 79 \ .dl VX_CALL1_NEG
   .db 78 \ .dl VX_CALL0_NEG
   .db 78 \ .dl VX_CALL1_NEG
   .db 77 \ .dl VX_CALL0_NEG
   .db 77 \ .dl VX_CALL1_NEG
   .db 76 \ .dl VX_CALL0_NEG
   .db 76 \ .dl VX_CALL1_NEG
   .db 75 \ .dl VX_CALL0_NEG
   .db 75 \ .dl VX_CALL1_NEG
   .db 74 \ .dl VX_CALL0_NEG
   .db 74 \ .dl VX_CALL1_NEG
   .db 73 \ .dl VX_CALL0_NEG
   .db 73 \ .dl VX_CALL1_NEG
   .db 72 \ .dl VX_CALL0_NEG
   .db 72 \ .dl VX_CALL1_NEG
   .db 71 \ .dl VX_CALL0_NEG
   .db 71 \ .dl VX_CALL1_NEG
   .db 70 \ .dl VX_CALL0_NEG
   .db 70 \ .dl VX_CALL1_NEG
   .db 69 \ .dl VX_CALL0_NEG
   .db 69 \ .dl VX_CALL1_NEG
   .db 68 \ .dl VX_CALL0_NEG
   .db 68 \ .dl VX_CALL1_NEG
   .db 67 \ .dl VX_CALL0_NEG
   .db 67 \ .dl VX_CALL1_NEG
   .db 66 \ .dl VX_CALL0_NEG
   .db 66 \ .dl VX_CALL1_NEG
   .db 65 \ .dl VX_CALL0_NEG
   .db 65 \ .dl VX_CALL1_NEG
   .db 64 \ .dl VX_CALL0_NEG
   .db 64 \ .dl VX_CALL1_NEG
   .db 63 \ .dl VX_CALL0_NEG
   .db 63 \ .dl VX_CALL1_NEG
   .db 62 \ .dl VX_CALL0_NEG
   .db 62 \ .dl VX_CALL1_NEG
   .db 61 \ .dl VX_CALL0_NEG
   .db 61 \ .dl VX_CALL1_NEG
   .db 60 \ .dl VX_CALL0_NEG
   .db 60 \ .dl VX_CALL1_NEG
   .db 59 \ .dl VX_CALL0_NEG
   .db 59 \ .dl VX_CALL1_NEG
   .db 58 \ .dl VX_CALL0_NEG
   .db 58 \ .dl VX_CALL1_NEG
   .db 57 \ .dl VX_CALL0_NEG
   .db 57 \ .dl VX_CALL1_NEG
   .db 56 \ .dl VX_CALL0_NEG
   .db 56 \ .dl VX_CALL1_NEG
   .db 55 \ .dl VX_CALL0_NEG
   .db 55 \ .dl VX_CALL1_NEG
   .db 54 \ .dl VX_CALL0_NEG
   .db 54 \ .dl VX_CALL1_NEG
   .db 53 \ .dl VX_CALL0_NEG
   .db 53 \ .dl VX_CALL1_NEG
   .db 52 \ .dl VX_CALL0_NEG
   .db 52 \ .dl VX_CALL1_NEG
   .db 51 \ .dl VX_CALL0_NEG
   .db 51 \ .dl VX_CALL1_NEG
   .db 50 \ .dl VX_CALL0_NEG
   .db 50 \ .dl VX_CALL1_NEG
   .db 49 \ .dl VX_CALL0_NEG
   .db 49 \ .dl VX_CALL1_NEG
   .db 48 \ .dl VX_CALL0_NEG
   .db 48 \ .dl VX_CALL1_NEG
   .db 47 \ .dl VX_CALL0_NEG
   .db 47 \ .dl VX_CALL1_NEG
   .db 46 \ .dl VX_CALL0_NEG
   .db 46 \ .dl VX_CALL1_NEG
   .db 45 \ .dl VX_CALL0_NEG
   .db 45 \ .dl VX_CALL1_NEG
   .db 44 \ .dl VX_CALL0_NEG
   .db 44 \ .dl VX_CALL1_NEG
   .db 43 \ .dl VX_CALL0_NEG
   .db 43 \ .dl VX_CALL1_NEG
   .db 42 \ .dl VX_CALL0_NEG
   .db 42 \ .dl VX_CALL1_NEG
   .db 41 \ .dl VX_CALL0_NEG
   .db 41 \ .dl VX_CALL1_NEG
   .db 40 \ .dl VX_CALL0_NEG
   .db 40 \ .dl VX_CALL1_NEG
   .db 39 \ .dl VX_CALL0_NEG
   .db 39 \ .dl VX_CALL1_NEG
   .db 38 \ .dl VX_CALL0_NEG
   .db 38 \ .dl VX_CALL1_NEG
   .db 37 \ .dl VX_CALL0_NEG
   .db 37 \ .dl VX_CALL1_NEG
   .db 36 \ .dl VX_CALL0_NEG
   .db 36 \ .dl VX_CALL1_NEG
   .db 35 \ .dl VX_CALL0_NEG
   .db 35 \ .dl VX_CALL1_NEG
   .db 34 \ .dl VX_CALL0_NEG
   .db 34 \ .dl VX_CALL1_NEG
   .db 33 \ .dl VX_CALL0_NEG
   .db 33 \ .dl VX_CALL1_NEG
   .db 32 \ .dl VX_CALL0_NEG
   .db 32 \ .dl VX_CALL1_NEG
   .db 31 \ .dl VX_CALL0_NEG
   .db 31 \ .dl VX_CALL1_NEG
   .db 30 \ .dl VX_CALL0_NEG
   .db 30 \ .dl VX_CALL1_NEG
   .db 29 \ .dl VX_CALL0_NEG
   .db 29 \ .dl VX_CALL1_NEG
   .db 28 \ .dl VX_CALL0_NEG
   .db 28 \ .dl VX_CALL1_NEG
   .db 27 \ .dl VX_CALL0_NEG
   .db 27 \ .dl VX_CALL1_NEG
   .db 26 \ .dl VX_CALL0_NEG
   .db 26 \ .dl VX_CALL1_NEG
   .db 25 \ .dl VX_CALL0_NEG
   .db 25 \ .dl VX_CALL1_NEG
   .db 24 \ .dl VX_CALL0_NEG
   .db 24 \ .dl VX_CALL1_NEG
   .db 23 \ .dl VX_CALL0_NEG
   .db 23 \ .dl VX_CALL1_NEG
   .db 22 \ .dl VX_CALL0_NEG
   .db 22 \ .dl VX_CALL1_NEG
   .db 21 \ .dl VX_CALL0_NEG
   .db 21 \ .dl VX_CALL1_NEG
   .db 20 \ .dl VX_CALL0_NEG
   .db 20 \ .dl VX_CALL1_NEG
   .db 19 \ .dl VX_CALL0_NEG
   .db 19 \ .dl VX_CALL1_NEG
   .db 18 \ .dl VX_CALL0_NEG
   .db 18 \ .dl VX_CALL1_NEG
   .db 17 \ .dl VX_CALL0_NEG
   .db 17 \ .dl VX_CALL1_NEG
   .db 16 \ .dl VX_CALL0_NEG
   .db 16 \ .dl VX_CALL1_NEG
   .db 15 \ .dl VX_CALL0_NEG
   .db 15 \ .dl VX_CALL1_NEG
   .db 14 \ .dl VX_CALL0_NEG
   .db 14 \ .dl VX_CALL1_NEG
   .db 13 \ .dl VX_CALL0_NEG
   .db 13 \ .dl VX_CALL1_NEG
   .db 12 \ .dl VX_CALL0_NEG
   .db 12 \ .dl VX_CALL1_NEG
   .db 11 \ .dl VX_CALL0_NEG
   .db 11 \ .dl VX_CALL1_NEG
   .db 10 \ .dl VX_CALL0_NEG
   .db 10 \ .dl VX_CALL1_NEG
   .db 9 \ .dl VX_CALL0_NEG
   .db 9 \ .dl VX_CALL1_NEG
   .db 8 \ .dl VX_CALL0_NEG
   .db 8 \ .dl VX_CALL1_NEG
   .db 7 \ .dl VX_CALL0_NEG
   .db 7 \ .dl VX_CALL1_NEG
   .db 6 \ .dl VX_CALL0_NEG
   .db 6 \ .dl VX_CALL1_NEG
   .db 5 \ .dl VX_CALL0_NEG
   .db 5 \ .dl VX_CALL1_NEG
   .db 4 \ .dl VX_CALL0_NEG
   .db 4 \ .dl VX_CALL1_NEG
   .db 3 \ .dl VX_CALL0_NEG
   .db 3 \ .dl VX_CALL1_NEG
   .db 2 \ .dl VX_CALL0_NEG
   .db 2 \ .dl VX_CALL1_NEG
   .db 1 \ .dl VX_CALL0_NEG
   .db 1 \ .dl VX_CALL1_NEG
VX_LUT_PIXEL_LENGTH:
   .db 1 \ .dl VX_CALL_NULL 
   .db 1 \ .dl VX_CALL1_POS
   .db 2 \ .dl VX_CALL0_POS
   .db 2 \ .dl VX_CALL1_POS
   .db 3 \ .dl VX_CALL0_POS
   .db 3 \ .dl VX_CALL1_POS
   .db 4 \ .dl VX_CALL0_POS
   .db 4 \ .dl VX_CALL1_POS
   .db 5 \ .dl VX_CALL0_POS
   .db 5 \ .dl VX_CALL1_POS
   .db 6 \ .dl VX_CALL0_POS
   .db 6 \ .dl VX_CALL1_POS
   .db 7 \ .dl VX_CALL0_POS
   .db 7 \ .dl VX_CALL1_POS
   .db 8 \ .dl VX_CALL0_POS
   .db 8 \ .dl VX_CALL1_POS
   .db 9 \ .dl VX_CALL0_POS
   .db 9 \ .dl VX_CALL1_POS
   .db 10 \ .dl VX_CALL0_POS
   .db 10 \ .dl VX_CALL1_POS
   .db 11 \ .dl VX_CALL0_POS
   .db 11 \ .dl VX_CALL1_POS
   .db 12 \ .dl VX_CALL0_POS
   .db 12 \ .dl VX_CALL1_POS
   .db 13 \ .dl VX_CALL0_POS
   .db 13 \ .dl VX_CALL1_POS
   .db 14 \ .dl VX_CALL0_POS
   .db 14 \ .dl VX_CALL1_POS
   .db 15 \ .dl VX_CALL0_POS
   .db 15 \ .dl VX_CALL1_POS
   .db 16 \ .dl VX_CALL0_POS
   .db 16 \ .dl VX_CALL1_POS
   .db 17 \ .dl VX_CALL0_POS
   .db 17 \ .dl VX_CALL1_POS
   .db 18 \ .dl VX_CALL0_POS
   .db 18 \ .dl VX_CALL1_POS
   .db 19 \ .dl VX_CALL0_POS
   .db 19 \ .dl VX_CALL1_POS
   .db 20 \ .dl VX_CALL0_POS
   .db 20 \ .dl VX_CALL1_POS
   .db 21 \ .dl VX_CALL0_POS
   .db 21 \ .dl VX_CALL1_POS
   .db 22 \ .dl VX_CALL0_POS
   .db 22 \ .dl VX_CALL1_POS
   .db 23 \ .dl VX_CALL0_POS
   .db 23 \ .dl VX_CALL1_POS
   .db 24 \ .dl VX_CALL0_POS
   .db 24 \ .dl VX_CALL1_POS
   .db 25 \ .dl VX_CALL0_POS
   .db 25 \ .dl VX_CALL1_POS
   .db 26 \ .dl VX_CALL0_POS
   .db 26 \ .dl VX_CALL1_POS
   .db 27 \ .dl VX_CALL0_POS
   .db 27 \ .dl VX_CALL1_POS
   .db 28 \ .dl VX_CALL0_POS
   .db 28 \ .dl VX_CALL1_POS
   .db 29 \ .dl VX_CALL0_POS
   .db 29 \ .dl VX_CALL1_POS
   .db 30 \ .dl VX_CALL0_POS
   .db 30 \ .dl VX_CALL1_POS
   .db 31 \ .dl VX_CALL0_POS
   .db 31 \ .dl VX_CALL1_POS
   .db 32 \ .dl VX_CALL0_POS
   .db 32 \ .dl VX_CALL1_POS
   .db 33 \ .dl VX_CALL0_POS
   .db 33 \ .dl VX_CALL1_POS
   .db 34 \ .dl VX_CALL0_POS
   .db 34 \ .dl VX_CALL1_POS
   .db 35 \ .dl VX_CALL0_POS
   .db 35 \ .dl VX_CALL1_POS
   .db 36 \ .dl VX_CALL0_POS
   .db 36 \ .dl VX_CALL1_POS
   .db 37 \ .dl VX_CALL0_POS
   .db 37 \ .dl VX_CALL1_POS
   .db 38 \ .dl VX_CALL0_POS
   .db 38 \ .dl VX_CALL1_POS
   .db 39 \ .dl VX_CALL0_POS
   .db 39 \ .dl VX_CALL1_POS
   .db 40 \ .dl VX_CALL0_POS
   .db 40 \ .dl VX_CALL1_POS
   .db 41 \ .dl VX_CALL0_POS
   .db 41 \ .dl VX_CALL1_POS
   .db 42 \ .dl VX_CALL0_POS
   .db 42 \ .dl VX_CALL1_POS
   .db 43 \ .dl VX_CALL0_POS
   .db 43 \ .dl VX_CALL1_POS
   .db 44 \ .dl VX_CALL0_POS
   .db 44 \ .dl VX_CALL1_POS
   .db 45 \ .dl VX_CALL0_POS
   .db 45 \ .dl VX_CALL1_POS
   .db 46 \ .dl VX_CALL0_POS
   .db 46 \ .dl VX_CALL1_POS
   .db 47 \ .dl VX_CALL0_POS
   .db 47 \ .dl VX_CALL1_POS
   .db 48 \ .dl VX_CALL0_POS
   .db 48 \ .dl VX_CALL1_POS
   .db 49 \ .dl VX_CALL0_POS
   .db 49 \ .dl VX_CALL1_POS
   .db 50 \ .dl VX_CALL0_POS
   .db 50 \ .dl VX_CALL1_POS
   .db 51 \ .dl VX_CALL0_POS
   .db 51 \ .dl VX_CALL1_POS
   .db 52 \ .dl VX_CALL0_POS
   .db 52 \ .dl VX_CALL1_POS
   .db 53 \ .dl VX_CALL0_POS
   .db 53 \ .dl VX_CALL1_POS
   .db 54 \ .dl VX_CALL0_POS
   .db 54 \ .dl VX_CALL1_POS
   .db 55 \ .dl VX_CALL0_POS
   .db 55 \ .dl VX_CALL1_POS
   .db 56 \ .dl VX_CALL0_POS
   .db 56 \ .dl VX_CALL1_POS
   .db 57 \ .dl VX_CALL0_POS
   .db 57 \ .dl VX_CALL1_POS
   .db 58 \ .dl VX_CALL0_POS
   .db 58 \ .dl VX_CALL1_POS
   .db 59 \ .dl VX_CALL0_POS
   .db 59 \ .dl VX_CALL1_POS
   .db 60 \ .dl VX_CALL0_POS
   .db 60 \ .dl VX_CALL1_POS
   .db 61 \ .dl VX_CALL0_POS
   .db 61 \ .dl VX_CALL1_POS
   .db 62 \ .dl VX_CALL0_POS
   .db 62 \ .dl VX_CALL1_POS
   .db 63 \ .dl VX_CALL0_POS
   .db 63 \ .dl VX_CALL1_POS
   .db 64 \ .dl VX_CALL0_POS
   .db 64 \ .dl VX_CALL1_POS
   .db 65 \ .dl VX_CALL0_POS
   .db 65 \ .dl VX_CALL1_POS
   .db 66 \ .dl VX_CALL0_POS
   .db 66 \ .dl VX_CALL1_POS
   .db 67 \ .dl VX_CALL0_POS
   .db 67 \ .dl VX_CALL1_POS
   .db 68 \ .dl VX_CALL0_POS
   .db 68 \ .dl VX_CALL1_POS
   .db 69 \ .dl VX_CALL0_POS
   .db 69 \ .dl VX_CALL1_POS
   .db 70 \ .dl VX_CALL0_POS
   .db 70 \ .dl VX_CALL1_POS
   .db 71 \ .dl VX_CALL0_POS
   .db 71 \ .dl VX_CALL1_POS
   .db 72 \ .dl VX_CALL0_POS
   .db 72 \ .dl VX_CALL1_POS
   .db 73 \ .dl VX_CALL0_POS
   .db 73 \ .dl VX_CALL1_POS
   .db 74 \ .dl VX_CALL0_POS
   .db 74 \ .dl VX_CALL1_POS
   .db 75 \ .dl VX_CALL0_POS
   .db 75 \ .dl VX_CALL1_POS
   .db 76 \ .dl VX_CALL0_POS
   .db 76 \ .dl VX_CALL1_POS
   .db 77 \ .dl VX_CALL0_POS
   .db 77 \ .dl VX_CALL1_POS
   .db 78 \ .dl VX_CALL0_POS
   .db 78 \ .dl VX_CALL1_POS
   .db 79 \ .dl VX_CALL0_POS
   .db 79 \ .dl VX_CALL1_POS
   .db 80 \ .dl VX_CALL0_POS
   .db 80 \ .dl VX_CALL1_POS
   .db 81 \ .dl VX_CALL0_POS
   .db 81 \ .dl VX_CALL1_POS
   .db 82 \ .dl VX_CALL0_POS
   .db 82 \ .dl VX_CALL1_POS
   .db 83 \ .dl VX_CALL0_POS
   .db 83 \ .dl VX_CALL1_POS
   .db 84 \ .dl VX_CALL0_POS
   .db 84 \ .dl VX_CALL1_POS
   .db 85 \ .dl VX_CALL0_POS
   .db 85 \ .dl VX_CALL1_POS
   .db 86 \ .dl VX_CALL0_POS
   .db 86 \ .dl VX_CALL1_POS
   .db 87 \ .dl VX_CALL0_POS
   .db 87 \ .dl VX_CALL1_POS
   .db 88 \ .dl VX_CALL0_POS
   .db 88 \ .dl VX_CALL1_POS
   .db 89 \ .dl VX_CALL0_POS
   .db 89 \ .dl VX_CALL1_POS
   .db 90 \ .dl VX_CALL0_POS
   .db 90 \ .dl VX_CALL1_POS
   .db 91 \ .dl VX_CALL0_POS
   .db 91 \ .dl VX_CALL1_POS
   .db 92 \ .dl VX_CALL0_POS
   .db 92 \ .dl VX_CALL1_POS
   .db 93 \ .dl VX_CALL0_POS
   .db 93 \ .dl VX_CALL1_POS
   .db 94 \ .dl VX_CALL0_POS
   .db 94 \ .dl VX_CALL1_POS
   .db 95 \ .dl VX_CALL0_POS
   .db 95 \ .dl VX_CALL1_POS
   .db 96 \ .dl VX_CALL0_POS
   .db 96 \ .dl VX_CALL1_POS
   .db 97 \ .dl VX_CALL0_POS
   .db 97 \ .dl VX_CALL1_POS
   .db 98 \ .dl VX_CALL0_POS
   .db 98 \ .dl VX_CALL1_POS
   .db 99 \ .dl VX_CALL0_POS
   .db 99 \ .dl VX_CALL1_POS
   .db 100 \ .dl VX_CALL0_POS
   .db 100 \ .dl VX_CALL1_POS
   .db 101 \ .dl VX_CALL0_POS
   .db 101 \ .dl VX_CALL1_POS
   .db 102 \ .dl VX_CALL0_POS
   .db 102 \ .dl VX_CALL1_POS
   .db 103 \ .dl VX_CALL0_POS
   .db 103 \ .dl VX_CALL1_POS
   .db 104 \ .dl VX_CALL0_POS
   .db 104 \ .dl VX_CALL1_POS
   .db 105 \ .dl VX_CALL0_POS
   .db 105 \ .dl VX_CALL1_POS
   .db 106 \ .dl VX_CALL0_POS
   .db 106 \ .dl VX_CALL1_POS
   .db 107 \ .dl VX_CALL0_POS
   .db 107 \ .dl VX_CALL1_POS
   .db 108 \ .dl VX_CALL0_POS
   .db 108 \ .dl VX_CALL1_POS
   .db 109 \ .dl VX_CALL0_POS
   .db 109 \ .dl VX_CALL1_POS
   .db 110 \ .dl VX_CALL0_POS
   .db 110 \ .dl VX_CALL1_POS
   .db 111 \ .dl VX_CALL0_POS
   .db 111 \ .dl VX_CALL1_POS
   .db 112 \ .dl VX_CALL0_POS
   .db 112 \ .dl VX_CALL1_POS
   .db 113 \ .dl VX_CALL0_POS
   .db 113 \ .dl VX_CALL1_POS
   .db 114 \ .dl VX_CALL0_POS
   .db 114 \ .dl VX_CALL1_POS
   .db 115 \ .dl VX_CALL0_POS
   .db 115 \ .dl VX_CALL1_POS
   .db 116 \ .dl VX_CALL0_POS
   .db 116 \ .dl VX_CALL1_POS
   .db 117 \ .dl VX_CALL0_POS
   .db 117 \ .dl VX_CALL1_POS
   .db 118 \ .dl VX_CALL0_POS
   .db 118 \ .dl VX_CALL1_POS
   .db 119 \ .dl VX_CALL0_POS
   .db 119 \ .dl VX_CALL1_POS
   .db 120 \ .dl VX_CALL0_POS
   .db 120 \ .dl VX_CALL1_POS
   .db 121 \ .dl VX_CALL0_POS
   .db 121 \ .dl VX_CALL1_POS
   .db 122 \ .dl VX_CALL0_POS
   .db 122 \ .dl VX_CALL1_POS
   .db 123 \ .dl VX_CALL0_POS
   .db 123 \ .dl VX_CALL1_POS
   .db 124 \ .dl VX_CALL0_POS
   .db 124 \ .dl VX_CALL1_POS
   .db 125 \ .dl VX_CALL0_POS
   .db 125 \ .dl VX_CALL1_POS
   .db 126 \ .dl VX_CALL0_POS
   .db 126 \ .dl VX_CALL1_POS
   .db 127 \ .dl VX_CALL0_POS
   .db 127 \ .dl VX_CALL1_POS
   .db 128 \ .dl VX_CALL0_POS
   .db 128 \ .dl VX_CALL1_POS
   .db 129 \ .dl VX_CALL0_POS
   .db 129 \ .dl VX_CALL1_POS
   .db 130 \ .dl VX_CALL0_POS
   .db 130 \ .dl VX_CALL1_POS
   .db 131 \ .dl VX_CALL0_POS
   .db 131 \ .dl VX_CALL1_POS
   .db 132 \ .dl VX_CALL0_POS
   .db 132 \ .dl VX_CALL1_POS
   .db 133 \ .dl VX_CALL0_POS
   .db 133 \ .dl VX_CALL1_POS
   .db 134 \ .dl VX_CALL0_POS
   .db 134 \ .dl VX_CALL1_POS
   .db 135 \ .dl VX_CALL0_POS
   .db 135 \ .dl VX_CALL1_POS
   .db 136 \ .dl VX_CALL0_POS
   .db 136 \ .dl VX_CALL1_POS
   .db 137 \ .dl VX_CALL0_POS
   .db 137 \ .dl VX_CALL1_POS
   .db 138 \ .dl VX_CALL0_POS
   .db 138 \ .dl VX_CALL1_POS
   .db 139 \ .dl VX_CALL0_POS
   .db 139 \ .dl VX_CALL1_POS
   .db 140 \ .dl VX_CALL0_POS
   .db 140 \ .dl VX_CALL1_POS
   .db 141 \ .dl VX_CALL0_POS
   .db 141 \ .dl VX_CALL1_POS
   .db 142 \ .dl VX_CALL0_POS
   .db 142 \ .dl VX_CALL1_POS
   .db 143 \ .dl VX_CALL0_POS
   .db 143 \ .dl VX_CALL1_POS
   .db 144 \ .dl VX_CALL0_POS
   .db 144 \ .dl VX_CALL1_POS
   .db 145 \ .dl VX_CALL0_POS
   .db 145 \ .dl VX_CALL1_POS
   .db 146 \ .dl VX_CALL0_POS
   .db 146 \ .dl VX_CALL1_POS
   .db 147 \ .dl VX_CALL0_POS
   .db 147 \ .dl VX_CALL1_POS
   .db 148 \ .dl VX_CALL0_POS
   .db 148 \ .dl VX_CALL1_POS
   .db 149 \ .dl VX_CALL0_POS
   .db 149 \ .dl VX_CALL1_POS
   .db 150 \ .dl VX_CALL0_POS
   .db 150 \ .dl VX_CALL1_POS
   .db 151 \ .dl VX_CALL0_POS
   .db 151 \ .dl VX_CALL1_POS
   .db 152 \ .dl VX_CALL0_POS
   .db 152 \ .dl VX_CALL1_POS
   .db 153 \ .dl VX_CALL0_POS
   .db 153 \ .dl VX_CALL1_POS
   .db 154 \ .dl VX_CALL0_POS
   .db 154 \ .dl VX_CALL1_POS
   .db 155 \ .dl VX_CALL0_POS
   .db 155 \ .dl VX_CALL1_POS
   .db 156 \ .dl VX_CALL0_POS
   .db 156 \ .dl VX_CALL1_POS
   .db 157 \ .dl VX_CALL0_POS
   .db 157 \ .dl VX_CALL1_POS
   .db 158 \ .dl VX_CALL0_POS
   .db 158 \ .dl VX_CALL1_POS
   .db 159 \ .dl VX_CALL0_POS
   .db 159 \ .dl VX_CALL1_POS
   .db 160 \ .dl VX_CALL0_POS
   .db 160 \ .dl VX_CALL1_POS
vxPixelShaderExitLUT:
   .db 0 \ .dl VX_CALL_EXIT