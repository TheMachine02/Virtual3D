; include standard shader
#include	"shader/vxTextureShader.asm"
#include	"shader/vxGouraudShader.asm"
#include	"shader/vxLightShader.asm"
#include	"shader/vxAlphaShader.asm"

vxShaderJump:
	.dl	0		; actual adress where pixel shader is
vxShaderAdress0:
	.dl	0		; sub adress to change inc/dec
vxShaderAdress1:
	.dl	0		; second sub adress
vxShaderAdress2:
	.dl	0		; sub adress to change inc/dec
vxShaderAdress3:
	.dl	0		; second sub adress

vxShaderLoad:
	ld	hl, vxPixelShaderExit
	ld	(vxPixelShaderExitLUT+1), hl
	ld	bc, (ix+VX_SHADER_SIZE)	; load size
	lea	hl, ix+VX_SHADER_CODE		; load shader
	ld	de, VX_PIXEL_SHADER_CODE
	ldir			; copy first part
	push de
	ld	hl, vxShaderGeneralInterpolation0
	ld	c, 32
	ldir			; copy constant part
	pop de
	ld	hl, VX_SMC_EDGEFIX - vxShaderGeneralInterpolation0
	add hl, de
	ld	(vxShaderAdress2), hl
	ld	(vxShaderAdress3), hl

; TODO : generation of the shading table
; VX_CALL1_NEG
	ld	c, (ix+VX_SHADER_DATA1)
	ld	hl, VX_PIXEL_SHADER_CODE
	add	hl, bc
; VX_CALL0_NEG
	ld	de, VX_PIXEL_SHADER_CODE
	ld	b, 160
	ld	iy, VX_LUT_PIXEL_LENGTH-(320*4)
vxShaderCreate0:
	ld	(iy+1), de
	ld	(iy+5), hl
	lea	iy, iy+8
	djnz vxShaderCreate0

	ld	a, (ix+VX_SHADER_DATA1)
	inc	a
	add	a, a
	add	a, VX_PIXEL_SHADER_CODE%256
	ld	l, a
	ld	(iy+1), hl
	ld	(vxShaderJump), hl
	lea	iy, iy+4

; de = VX_CALL1_POS
	ld	de, 0

	ld	e, (ix+VX_SHADER_DATA1)
	ld	hl, VX_PIXEL_SHADER_CODE
	add	hl, de
	dec hl
	dec hl
	ld	(vxShaderAdress0), hl
	ex	de, hl
; hl = VX_CALL0_POS
	add hl, de
	ld	(vxShaderAdress1), hl
	ld	b, 160

	inc hl
	inc hl
	inc de
	inc de

vxShaderCreate1:
	ld	(iy+1), de
	ld	(iy+5), hl
	lea	iy, iy+8
	djnz vxShaderCreate1

	ret

vxShaderGeneralInterpolation0:
	ld	hl, (iy+VX_REGISTER2)	; v
	exx
	ld	hl, (iy+VX_REGISTER1) ; lut adress
	ld	de, (iy+VX_REGISTER0)	; screen adress
	add	hl, de
	add	hl, hl
	add	hl, hl
VX_SMC_EDGEFIX=$
	nop
	ld	a, (hl)			; fetch correct size
	inc	hl
	ld	ix, (hl)			; fetch jump \o/
	ld	hl, (iy+VX_REGISTER3)	; u
	exx
	ld	b, a
	lea	iy, iy+VX_REGISTER_SIZE
	jp	(ix)

   .align  4
VX_LUT_PIXEL_TABLE:
   .db 160 \ .dl 0
   .db 160 \ .dl 0
   .db 159 \ .dl 0
   .db 159 \ .dl 0
   .db 158 \ .dl 0
   .db 158 \ .dl 0
   .db 157 \ .dl 0
   .db 157 \ .dl 0
   .db 156 \ .dl 0
   .db 156 \ .dl 0
   .db 155 \ .dl 0
   .db 155 \ .dl 0
   .db 154 \ .dl 0
   .db 154 \ .dl 0
   .db 153 \ .dl 0
   .db 153 \ .dl 0
   .db 152 \ .dl 0
   .db 152 \ .dl 0
   .db 151 \ .dl 0
   .db 151 \ .dl 0
   .db 150 \ .dl 0
   .db 150 \ .dl 0
   .db 149 \ .dl 0
   .db 149 \ .dl 0
   .db 148 \ .dl 0
   .db 148 \ .dl 0
   .db 147 \ .dl 0
   .db 147 \ .dl 0
   .db 146 \ .dl 0
   .db 146 \ .dl 0
   .db 145 \ .dl 0
   .db 145 \ .dl 0
   .db 144 \ .dl 0
   .db 144 \ .dl 0
   .db 143 \ .dl 0
   .db 143 \ .dl 0
   .db 142 \ .dl 0
   .db 142 \ .dl 0
   .db 141 \ .dl 0
   .db 141 \ .dl 0
   .db 140 \ .dl 0
   .db 140 \ .dl 0
   .db 139 \ .dl 0
   .db 139 \ .dl 0
   .db 138 \ .dl 0
   .db 138 \ .dl 0
   .db 137 \ .dl 0
   .db 137 \ .dl 0
   .db 136 \ .dl 0
   .db 136 \ .dl 0
   .db 135 \ .dl 0
   .db 135 \ .dl 0
   .db 134 \ .dl 0
   .db 134 \ .dl 0
   .db 133 \ .dl 0
   .db 133 \ .dl 0
   .db 132 \ .dl 0
   .db 132 \ .dl 0
   .db 131 \ .dl 0
   .db 131 \ .dl 0
   .db 130 \ .dl 0
   .db 130 \ .dl 0
   .db 129 \ .dl 0
   .db 129 \ .dl 0
   .db 128 \ .dl 0
   .db 128 \ .dl 0
   .db 127 \ .dl 0
   .db 127 \ .dl 0
   .db 126 \ .dl 0
   .db 126 \ .dl 0
   .db 125 \ .dl 0
   .db 125 \ .dl 0
   .db 124 \ .dl 0
   .db 124 \ .dl 0
   .db 123 \ .dl 0
   .db 123 \ .dl 0
   .db 122 \ .dl 0
   .db 122 \ .dl 0
   .db 121 \ .dl 0
   .db 121 \ .dl 0
   .db 120 \ .dl 0
   .db 120 \ .dl 0
   .db 119 \ .dl 0
   .db 119 \ .dl 0
   .db 118 \ .dl 0
   .db 118 \ .dl 0
   .db 117 \ .dl 0
   .db 117 \ .dl 0
   .db 116 \ .dl 0
   .db 116 \ .dl 0
   .db 115 \ .dl 0
   .db 115 \ .dl 0
   .db 114 \ .dl 0
   .db 114 \ .dl 0
   .db 113 \ .dl 0
   .db 113 \ .dl 0
   .db 112 \ .dl 0
   .db 112 \ .dl 0
   .db 111 \ .dl 0
   .db 111 \ .dl 0
   .db 110 \ .dl 0
   .db 110 \ .dl 0
   .db 109 \ .dl 0
   .db 109 \ .dl 0
   .db 108 \ .dl 0
   .db 108 \ .dl 0
   .db 107 \ .dl 0
   .db 107 \ .dl 0
   .db 106 \ .dl 0
   .db 106 \ .dl 0
   .db 105 \ .dl 0
   .db 105 \ .dl 0
   .db 104 \ .dl 0
   .db 104 \ .dl 0
   .db 103 \ .dl 0
   .db 103 \ .dl 0
   .db 102 \ .dl 0
   .db 102 \ .dl 0
   .db 101 \ .dl 0
   .db 101 \ .dl 0
   .db 100 \ .dl 0
   .db 100 \ .dl 0
   .db 99 \ .dl 0
   .db 99 \ .dl 0
   .db 98 \ .dl 0
   .db 98 \ .dl 0
   .db 97 \ .dl 0
   .db 97 \ .dl 0
   .db 96 \ .dl 0
   .db 96 \ .dl 0
   .db 95 \ .dl 0
   .db 95 \ .dl 0
   .db 94 \ .dl 0
   .db 94 \ .dl 0
   .db 93 \ .dl 0
   .db 93 \ .dl 0
   .db 92 \ .dl 0
   .db 92 \ .dl 0
   .db 91 \ .dl 0
   .db 91 \ .dl 0
   .db 90 \ .dl 0
   .db 90 \ .dl 0
   .db 89 \ .dl 0
   .db 89 \ .dl 0
   .db 88 \ .dl 0
   .db 88 \ .dl 0
   .db 87 \ .dl 0
   .db 87 \ .dl 0
   .db 86 \ .dl 0
   .db 86 \ .dl 0
   .db 85 \ .dl 0
   .db 85 \ .dl 0
   .db 84 \ .dl 0
   .db 84 \ .dl 0
   .db 83 \ .dl 0
   .db 83 \ .dl 0
   .db 82 \ .dl 0
   .db 82 \ .dl 0
   .db 81 \ .dl 0
   .db 81 \ .dl 0
   .db 80 \ .dl 0
   .db 80 \ .dl 0
   .db 79 \ .dl 0
   .db 79 \ .dl 0
   .db 78 \ .dl 0
   .db 78 \ .dl 0
   .db 77 \ .dl 0
   .db 77 \ .dl 0
   .db 76 \ .dl 0
   .db 76 \ .dl 0
   .db 75 \ .dl 0
   .db 75 \ .dl 0
   .db 74 \ .dl 0
   .db 74 \ .dl 0
   .db 73 \ .dl 0
   .db 73 \ .dl 0
   .db 72 \ .dl 0
   .db 72 \ .dl 0
   .db 71 \ .dl 0
   .db 71 \ .dl 0
   .db 70 \ .dl 0
   .db 70 \ .dl 0
   .db 69 \ .dl 0
   .db 69 \ .dl 0
   .db 68 \ .dl 0
   .db 68 \ .dl 0
   .db 67 \ .dl 0
   .db 67 \ .dl 0
   .db 66 \ .dl 0
   .db 66 \ .dl 0
   .db 65 \ .dl 0
   .db 65 \ .dl 0
   .db 64 \ .dl 0
   .db 64 \ .dl 0
   .db 63 \ .dl 0
   .db 63 \ .dl 0
   .db 62 \ .dl 0
   .db 62 \ .dl 0
   .db 61 \ .dl 0
   .db 61 \ .dl 0
   .db 60 \ .dl 0
   .db 60 \ .dl 0
   .db 59 \ .dl 0
   .db 59 \ .dl 0
   .db 58 \ .dl 0
   .db 58 \ .dl 0
   .db 57 \ .dl 0
   .db 57 \ .dl 0
   .db 56 \ .dl 0
   .db 56 \ .dl 0
   .db 55 \ .dl 0
   .db 55 \ .dl 0
   .db 54 \ .dl 0
   .db 54 \ .dl 0
   .db 53 \ .dl 0
   .db 53 \ .dl 0
   .db 52 \ .dl 0
   .db 52 \ .dl 0
   .db 51 \ .dl 0
   .db 51 \ .dl 0
   .db 50 \ .dl 0
   .db 50 \ .dl 0
   .db 49 \ .dl 0
   .db 49 \ .dl 0
   .db 48 \ .dl 0
   .db 48 \ .dl 0
   .db 47 \ .dl 0
   .db 47 \ .dl 0
   .db 46 \ .dl 0
   .db 46 \ .dl 0
   .db 45 \ .dl 0
   .db 45 \ .dl 0
   .db 44 \ .dl 0
   .db 44 \ .dl 0
   .db 43 \ .dl 0
   .db 43 \ .dl 0
   .db 42 \ .dl 0
   .db 42 \ .dl 0
   .db 41 \ .dl 0
   .db 41 \ .dl 0
   .db 40 \ .dl 0
   .db 40 \ .dl 0
   .db 39 \ .dl 0
   .db 39 \ .dl 0
   .db 38 \ .dl 0
   .db 38 \ .dl 0
   .db 37 \ .dl 0
   .db 37 \ .dl 0
   .db 36 \ .dl 0
   .db 36 \ .dl 0
   .db 35 \ .dl 0
   .db 35 \ .dl 0
   .db 34 \ .dl 0
   .db 34 \ .dl 0
   .db 33 \ .dl 0
   .db 33 \ .dl 0
   .db 32 \ .dl 0
   .db 32 \ .dl 0
   .db 31 \ .dl 0
   .db 31 \ .dl 0
   .db 30 \ .dl 0
   .db 30 \ .dl 0
   .db 29 \ .dl 0
   .db 29 \ .dl 0
   .db 28 \ .dl 0
   .db 28 \ .dl 0
   .db 27 \ .dl 0
   .db 27 \ .dl 0
   .db 26 \ .dl 0
   .db 26 \ .dl 0
   .db 25 \ .dl 0
   .db 25 \ .dl 0
   .db 24 \ .dl 0
   .db 24 \ .dl 0
   .db 23 \ .dl 0
   .db 23 \ .dl 0
   .db 22 \ .dl 0
   .db 22 \ .dl 0
   .db 21 \ .dl 0
   .db 21 \ .dl 0
   .db 20 \ .dl 0
   .db 20 \ .dl 0
   .db 19 \ .dl 0
   .db 19 \ .dl 0
   .db 18 \ .dl 0
   .db 18 \ .dl 0
   .db 17 \ .dl 0
   .db 17 \ .dl 0
   .db 16 \ .dl 0
   .db 16 \ .dl 0
   .db 15 \ .dl 0
   .db 15 \ .dl 0
   .db 14 \ .dl 0
   .db 14 \ .dl 0
   .db 13 \ .dl 0
   .db 13 \ .dl 0
   .db 12 \ .dl 0
   .db 12 \ .dl 0
   .db 11 \ .dl 0
   .db 11 \ .dl 0
   .db 10 \ .dl 0
   .db 10 \ .dl 0
   .db 9 \ .dl 0
   .db 9 \ .dl 0
   .db 8 \ .dl 0
   .db 8 \ .dl 0
   .db 7 \ .dl 0
   .db 7 \ .dl 0
   .db 6 \ .dl 0
   .db 6 \ .dl 0
   .db 5 \ .dl 0
   .db 5 \ .dl 0
   .db 4 \ .dl 0
   .db 4 \ .dl 0
   .db 3 \ .dl 0
   .db 3 \ .dl 0
   .db 2 \ .dl 0
   .db 2 \ .dl 0
   .db 1 \ .dl 0
   .db 1 \ .dl 0
VX_LUT_PIXEL_LENGTH:
   .db 0 \ .dl 0
   .db 1 \ .dl 0
   .db 2 \ .dl 0
   .db 2 \ .dl 0
   .db 3 \ .dl 0
   .db 3 \ .dl 0
   .db 4 \ .dl 0
   .db 4 \ .dl 0
   .db 5 \ .dl 0
   .db 5 \ .dl 0
   .db 6 \ .dl 0
   .db 6 \ .dl 0
   .db 7 \ .dl 0
   .db 7 \ .dl 0
   .db 8 \ .dl 0
   .db 8 \ .dl 0
   .db 9 \ .dl 0
   .db 9 \ .dl 0
   .db 10 \ .dl 0
   .db 10 \ .dl 0
   .db 11 \ .dl 0
   .db 11 \ .dl 0
   .db 12 \ .dl 0
   .db 12 \ .dl 0
   .db 13 \ .dl 0
   .db 13 \ .dl 0
   .db 14 \ .dl 0
   .db 14 \ .dl 0
   .db 15 \ .dl 0
   .db 15 \ .dl 0
   .db 16 \ .dl 0
   .db 16 \ .dl 0
   .db 17 \ .dl 0
   .db 17 \ .dl 0
   .db 18 \ .dl 0
   .db 18 \ .dl 0
   .db 19 \ .dl 0
   .db 19 \ .dl 0
   .db 20 \ .dl 0
   .db 20 \ .dl 0
   .db 21 \ .dl 0
   .db 21 \ .dl 0
   .db 22 \ .dl 0
   .db 22 \ .dl 0
   .db 23 \ .dl 0
   .db 23 \ .dl 0
   .db 24 \ .dl 0
   .db 24 \ .dl 0
   .db 25 \ .dl 0
   .db 25 \ .dl 0
   .db 26 \ .dl 0
   .db 26 \ .dl 0
   .db 27 \ .dl 0
   .db 27 \ .dl 0
   .db 28 \ .dl 0
   .db 28 \ .dl 0
   .db 29 \ .dl 0
   .db 29 \ .dl 0
   .db 30 \ .dl 0
   .db 30 \ .dl 0
   .db 31 \ .dl 0
   .db 31 \ .dl 0
   .db 32 \ .dl 0
   .db 32 \ .dl 0
   .db 33 \ .dl 0
   .db 33 \ .dl 0
   .db 34 \ .dl 0
   .db 34 \ .dl 0
   .db 35 \ .dl 0
   .db 35 \ .dl 0
   .db 36 \ .dl 0
   .db 36 \ .dl 0
   .db 37 \ .dl 0
   .db 37 \ .dl 0
   .db 38 \ .dl 0
   .db 38 \ .dl 0
   .db 39 \ .dl 0
   .db 39 \ .dl 0
   .db 40 \ .dl 0
   .db 40 \ .dl 0
   .db 41 \ .dl 0
   .db 41 \ .dl 0
   .db 42 \ .dl 0
   .db 42 \ .dl 0
   .db 43 \ .dl 0
   .db 43 \ .dl 0
   .db 44 \ .dl 0
   .db 44 \ .dl 0
   .db 45 \ .dl 0
   .db 45 \ .dl 0
   .db 46 \ .dl 0
   .db 46 \ .dl 0
   .db 47 \ .dl 0
   .db 47 \ .dl 0
   .db 48 \ .dl 0
   .db 48 \ .dl 0
   .db 49 \ .dl 0
   .db 49 \ .dl 0
   .db 50 \ .dl 0
   .db 50 \ .dl 0
   .db 51 \ .dl 0
   .db 51 \ .dl 0
   .db 52 \ .dl 0
   .db 52 \ .dl 0
   .db 53 \ .dl 0
   .db 53 \ .dl 0
   .db 54 \ .dl 0
   .db 54 \ .dl 0
   .db 55 \ .dl 0
   .db 55 \ .dl 0
   .db 56 \ .dl 0
   .db 56 \ .dl 0
   .db 57 \ .dl 0
   .db 57 \ .dl 0
   .db 58 \ .dl 0
   .db 58 \ .dl 0
   .db 59 \ .dl 0
   .db 59 \ .dl 0
   .db 60 \ .dl 0
   .db 60 \ .dl 0
   .db 61 \ .dl 0
   .db 61 \ .dl 0
   .db 62 \ .dl 0
   .db 62 \ .dl 0
   .db 63 \ .dl 0
   .db 63 \ .dl 0
   .db 64 \ .dl 0
   .db 64 \ .dl 0
   .db 65 \ .dl 0
   .db 65 \ .dl 0
   .db 66 \ .dl 0
   .db 66 \ .dl 0
   .db 67 \ .dl 0
   .db 67 \ .dl 0
   .db 68 \ .dl 0
   .db 68 \ .dl 0
   .db 69 \ .dl 0
   .db 69 \ .dl 0
   .db 70 \ .dl 0
   .db 70 \ .dl 0
   .db 71 \ .dl 0
   .db 71 \ .dl 0
   .db 72 \ .dl 0
   .db 72 \ .dl 0
   .db 73 \ .dl 0
   .db 73 \ .dl 0
   .db 74 \ .dl 0
   .db 74 \ .dl 0
   .db 75 \ .dl 0
   .db 75 \ .dl 0
   .db 76 \ .dl 0
   .db 76 \ .dl 0
   .db 77 \ .dl 0
   .db 77 \ .dl 0
   .db 78 \ .dl 0
   .db 78 \ .dl 0
   .db 79 \ .dl 0
   .db 79 \ .dl 0
   .db 80 \ .dl 0
   .db 80 \ .dl 0
   .db 81 \ .dl 0
   .db 81 \ .dl 0
   .db 82 \ .dl 0
   .db 82 \ .dl 0
   .db 83 \ .dl 0
   .db 83 \ .dl 0
   .db 84 \ .dl 0
   .db 84 \ .dl 0
   .db 85 \ .dl 0
   .db 85 \ .dl 0
   .db 86 \ .dl 0
   .db 86 \ .dl 0
   .db 87 \ .dl 0
   .db 87 \ .dl 0
   .db 88 \ .dl 0
   .db 88 \ .dl 0
   .db 89 \ .dl 0
   .db 89 \ .dl 0
   .db 90 \ .dl 0
   .db 90 \ .dl 0
   .db 91 \ .dl 0
   .db 91 \ .dl 0
   .db 92 \ .dl 0
   .db 92 \ .dl 0
   .db 93 \ .dl 0
   .db 93 \ .dl 0
   .db 94 \ .dl 0
   .db 94 \ .dl 0
   .db 95 \ .dl 0
   .db 95 \ .dl 0
   .db 96 \ .dl 0
   .db 96 \ .dl 0
   .db 97 \ .dl 0
   .db 97 \ .dl 0
   .db 98 \ .dl 0
   .db 98 \ .dl 0
   .db 99 \ .dl 0
   .db 99 \ .dl 0
   .db 100 \ .dl 0
   .db 100 \ .dl 0
   .db 101 \ .dl 0
   .db 101 \ .dl 0
   .db 102 \ .dl 0
   .db 102 \ .dl 0
   .db 103 \ .dl 0
   .db 103 \ .dl 0
   .db 104 \ .dl 0
   .db 104 \ .dl 0
   .db 105 \ .dl 0
   .db 105 \ .dl 0
   .db 106 \ .dl 0
   .db 106 \ .dl 0
   .db 107 \ .dl 0
   .db 107 \ .dl 0
   .db 108 \ .dl 0
   .db 108 \ .dl 0
   .db 109 \ .dl 0
   .db 109 \ .dl 0
   .db 110 \ .dl 0
   .db 110 \ .dl 0
   .db 111 \ .dl 0
   .db 111 \ .dl 0
   .db 112 \ .dl 0
   .db 112 \ .dl 0
   .db 113 \ .dl 0
   .db 113 \ .dl 0
   .db 114 \ .dl 0
   .db 114 \ .dl 0
   .db 115 \ .dl 0
   .db 115 \ .dl 0
   .db 116 \ .dl 0
   .db 116 \ .dl 0
   .db 117 \ .dl 0
   .db 117 \ .dl 0
   .db 118 \ .dl 0
   .db 118 \ .dl 0
   .db 119 \ .dl 0
   .db 119 \ .dl 0
   .db 120 \ .dl 0
   .db 120 \ .dl 0
   .db 121 \ .dl 0
   .db 121 \ .dl 0
   .db 122 \ .dl 0
   .db 122 \ .dl 0
   .db 123 \ .dl 0
   .db 123 \ .dl 0
   .db 124 \ .dl 0
   .db 124 \ .dl 0
   .db 125 \ .dl 0
   .db 125 \ .dl 0
   .db 126 \ .dl 0
   .db 126 \ .dl 0
   .db 127 \ .dl 0
   .db 127 \ .dl 0
   .db 128 \ .dl 0
   .db 128 \ .dl 0
   .db 129 \ .dl 0
   .db 129 \ .dl 0
   .db 130 \ .dl 0
   .db 130 \ .dl 0
   .db 131 \ .dl 0
   .db 131 \ .dl 0
   .db 132 \ .dl 0
   .db 132 \ .dl 0
   .db 133 \ .dl 0
   .db 133 \ .dl 0
   .db 134 \ .dl 0
   .db 134 \ .dl 0
   .db 135 \ .dl 0
   .db 135 \ .dl 0
   .db 136 \ .dl 0
   .db 136 \ .dl 0
   .db 137 \ .dl 0
   .db 137 \ .dl 0
   .db 138 \ .dl 0
   .db 138 \ .dl 0
   .db 139 \ .dl 0
   .db 139 \ .dl 0
   .db 140 \ .dl 0
   .db 140 \ .dl 0
   .db 141 \ .dl 0
   .db 141 \ .dl 0
   .db 142 \ .dl 0
   .db 142 \ .dl 0
   .db 143 \ .dl 0
   .db 143 \ .dl 0
   .db 144 \ .dl 0
   .db 144 \ .dl 0
   .db 145 \ .dl 0
   .db 145 \ .dl 0
   .db 146 \ .dl 0
   .db 146 \ .dl 0
   .db 147 \ .dl 0
   .db 147 \ .dl 0
   .db 148 \ .dl 0
   .db 148 \ .dl 0
   .db 149 \ .dl 0
   .db 149 \ .dl 0
   .db 150 \ .dl 0
   .db 150 \ .dl 0
   .db 151 \ .dl 0
   .db 151 \ .dl 0
   .db 152 \ .dl 0
   .db 152 \ .dl 0
   .db 153 \ .dl 0
   .db 153 \ .dl 0
   .db 154 \ .dl 0
   .db 154 \ .dl 0
   .db 155 \ .dl 0
   .db 155 \ .dl 0
   .db 156 \ .dl 0
   .db 156 \ .dl 0
   .db 157 \ .dl 0
   .db 157 \ .dl 0
   .db 158 \ .dl 0
   .db 158 \ .dl 0
   .db 159 \ .dl 0
   .db 159 \ .dl 0
   .db 160 \ .dl 0
   .db 160 \ .dl 0
   .db 161 \ .dl 0
vxPixelShaderExitLUT:
   .db 0 \ .dl vxPixelShaderExit
