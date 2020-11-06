vxIdentityMatrix:
.db	64,0,0
.db	0,64,0
.db	0,0,64
.dl	0,0,0
vxProjectionMatrix:
.db	64,0,0
.db	0,85,0
.db	0,0,64
.dl	0,0,0
vxTmpVector:
.dw	0,0,0
.db	0	; pad
vxLookAtMatrix:
.db	0,0,0
.db	0,0,0
.db	0,0,0
.dl	0,0,0

vxMatrixLoadIdentity:
; input : hl matrix
	ex	de, hl
	ld	hl, vxIdentityMatrix
	ld	bc, VX_MATRIX_SIZE
	ldir
	ex	de, hl
	dec	bc
	ld	c, -VX_MATRIX_SIZE
	add	hl, bc
	ret
vxMatrixRotationX:
	push	hl
	call	vxSin
	ld	a, h
	ld	(ix+VX_MATRIX_C7), a
	neg
	ld	(ix+VX_MATRIX_C5), a
	pop	hl
	call	vxCos
	ld	(ix+VX_MATRIX_C4), h
	ld	(ix+VX_MATRIX_C8), h
	ld	(ix+VX_MATRIX_C0), 64
	xor	a, a
	ld	(ix+VX_MATRIX_C1), a
	ld	(ix+VX_MATRIX_C2), a
	ld	(ix+VX_MATRIX_C3), a
	ld	(ix+VX_MATRIX_C6), a
	ret
vxMatrixRotationZ:
	push	hl
	call	vxSin
	ld	a, h
	ld	(ix+VX_MATRIX_C3), a
	neg
	ld	(ix+VX_MATRIX_C1), a
	pop	hl
	call	vxCos
	ld	(ix+VX_MATRIX_C0), h
	ld	(ix+VX_MATRIX_C4), h
	ld	(ix+VX_MATRIX_C8), 64
	xor	a, a
	ld	(ix+VX_MATRIX_C2), a
	ld	(ix+VX_MATRIX_C6), a
	ld	(ix+VX_MATRIX_C7), a
	ld	(ix+VX_MATRIX_C5), a
	ret
vxMatrixRotationY:
	push	hl
	call	vxSin
	ld	a, h
	ld	(ix+VX_MATRIX_C2), a
	neg
	ld	(ix+VX_MATRIX_C6), a
	pop	hl
	call	vxCos
	ld	(ix+VX_MATRIX_C0), h
	ld	(ix+VX_MATRIX_C8), h
	ld	(ix+VX_MATRIX_C4), 64
	xor	a, a
	ld	(ix+VX_MATRIX_C1), a
	ld	(ix+VX_MATRIX_C3), a
	ld	(ix+VX_MATRIX_C5), a
	ld	(ix+VX_MATRIX_C7), a
	ret
vxMatrixMlt:
; (hl) = (iy) * (ix)
; WARNING : hl can't be equal to ix
; 116 bytes, ~3800 TStates
	ex	de, hl
	ld	bc, 768
vxMatrixColLoop:
	push	bc
	ld	b, 3
	ld	c, b
vxMatrixRowLoop:
	push	bc
	ld	h, (ix+0)
	ld	l, (iy+0)
	xor	a, a
	bit	7, h \ jr z, $+3 \ sub a, l
	bit	7, l \ jr z, $+3 \ sub a, h
	mlt	hl
	ld	b, (ix+1)
	ld	c, (iy+3)
	bit	7, b \ jr z, $+3 \ sub a, c
	bit	7, c \ jr z, $+3 \ sub a, b
	mlt	bc
	add	hl, bc
	ld	b, (ix+2)
	ld	c, (iy+6)
	bit	7, b \ jr z, $+3 \ sub a, c
	bit	7, c \ jr z, $+3 \ sub a, b
	mlt	bc
	add	hl, bc
	ld	b, a
	xor	a, a
	ld	c, a
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ld	a, h
	ld	(de), a
	inc	de
	inc	iy
	pop	bc
	djnz	vxMatrixRowLoop
	add	ix, bc
	lea	iy, iy-3
	pop	bc
	djnz	vxMatrixColLoop
	dec	bc
	ld	c,-9
	add	ix, bc
	ex	de, hl
	add	hl, bc
	ret
vxMatrixTransform:
; (hl) = (iy)*(ix) with translation
; iy is a animation matrix, ix is a world matrix, hl is world matrix
	push	hl
; load up the translation of matrix
	lea	iy, iy+VX_MATRIX_TX
	call	vxfTransform
	lea	iy, iy-VX_MATRIX_TX
	pop	hl
	call	vxMatrixMlt
; copy translation data to result (hl)
	ld	bc, 9
	add	hl, bc
	ld	de, vxPosition
	ex	de, hl
	ldir
	ld	bc, -VX_MATRIX_SIZE
	ex	de, hl
	add	hl, bc
	ret
vxMatrixTranspose:
; 192 TStates + translation
	ld	c, (ix+VX_MATRIX_C3)
	ld	a, (ix+VX_MATRIX_C1)
	ld	(ix+VX_MATRIX_C3), a
	ld	(ix+VX_MATRIX_C1), c
	ld	c, (ix+VX_MATRIX_C6)
	ld	a, (ix+VX_MATRIX_C2)
	ld	(ix+VX_MATRIX_C6), a
	ld	(ix+VX_MATRIX_C2), c
	ld	c, (ix+VX_MATRIX_C7)
	ld	a, (ix+VX_MATRIX_C5)
	ld	(ix+VX_MATRIX_C7), a
	ld	(ix+VX_MATRIX_C5), c	
	ld	de, (ix+VX_MATRIX_TX)
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ld	(ix+VX_MATRIX_TX), hl
	ld	de, (ix+VX_MATRIX_TY)
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ld	(ix+VX_MATRIX_TY), hl
	ld	de, (ix+VX_MATRIX_TZ)
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ld	(ix+VX_MATRIX_TZ), hl
	ret
vxMatrixLightning:
	ex	de, hl
	ld	b, 3
vxMatrixLightLoop:
	push	bc
	push	de
	call	vxDotProduct
	pop	de
	add	hl, hl
	add	hl, hl
	ld	a, h
	ld	(de), a
	inc	de
	lea	ix, ix+3
	pop	bc
	djnz	vxMatrixLightLoop
	lea	ix, ix-9
; ix = matrix, light = de, initial light = iy
	ex	de, hl
	ld	de, (iy+VX_LIGHT_AMBIENT)
	ld	(hl), de	; copy the three important bytes.
	ld	a, (iy+VX_LIGHT_PARAM)
	bit	VX_LIGHT_POINT_BIT, a
	ret	z
; we need to transform the light vector with the matrix
	inc	hl
	inc	hl
	inc	hl
	push	hl
	lea	iy, iy+VX_LIGHT_POSITION
	call	vxfTransform
; now copy back to my light !
; I need to divide the position by 64
	pop	de
	ld	hl, (vxPosition)
	add	hl, hl
	add	hl, hl
	ld	(vxPosition), hl
	ld	hl, (vxPosition+1)
	ex	de, hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
	inc	hl
	ex	de, hl

	ld	hl, (vxPosition+3)
	add	hl, hl
	add	hl, hl
	ld	(vxPosition+3), hl
	ld	hl, (vxPosition+4)
	ex	de, hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
	inc	hl
	ex	de, hl

	ld	hl, (vxPosition+6)
	add	hl, hl
	add	hl, hl
	ld	(vxPosition+6), hl
	ld	hl, (vxPosition+7)
	ex	de, hl
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ret
vxfTransform:
; input : iy vector, ix matrix
; [ix+0]*[iy]+[ix+1]*[iy+2]+[ix+2]*[iy+4]+[ix+9]=x
; [ix+3]*[iy]+[ix+4]*[iy+2]+{ix+5]*[iy+4]+[ix+12]=y
; [ix+6]*[iy]+[ix+7]*[iy+2]+[ix+8]*[iy+4]+[ix+15]=z
; From 1566+x? TStates to 1654 TStates, 333 bytes
; X coordinate
; you know, I am really madd ! *coder stare at you*
	ld	bc, (iy+0)
	ld	hl, (ix+9)
	ld	a, (ix+0)
	fma
	ld	a, (ix+1)
	ld	bc, (iy+2)
	fma
	ld	a, (ix+2)
	ld	bc, (iy+4)
	fma.f
	ld	(vxPosition), hl
; Y coordinate
	ld	hl, (ix+12)
	ld	a, (ix+5)
	fma
	ld	a, (ix+4)
	ld	bc, (iy+2)
	fma
	ld	a, (ix+3)
	ld	bc, (iy+0)
	fma.f
	ld	(vxPosition+3), hl
; Z coordinate
	ld	hl, (ix+15)
	ld	a, (ix+6)
	fma
	ld	a, (ix+7)
	ld	bc, (iy+2)
	fma
	ld	a, (ix+8)
	ld	bc, (iy+4)
	fma.f
	ld	(vxPosition+6), hl
	ret
vxMatrixLookAt:
; zaxis = normal(At - Eye)
; xaxis = normal(cross(Up, zaxis))
; yaxis = cross(zaxis, xaxis)
; xaxis.x           xaxis.y           xaxis.z          0
; yaxis.x           yaxis.y           yaxis.z          0
; zaxis.x           zaxis.y           zaxis.z          0
;-dot(xaxis, eye)  -dot(yaxis, eye)  -dot(zaxis, eye)  l
; ix is eye, iy is At, bc is Up
	ld	de, (ix+VX_VECTOR_WX)
	ld	hl, (iy+VX_VECTOR_WX)
	or	a, a
	sbc	hl, de
	ld	(vxTmpVector+VX_VECTOR_WX), hl

	ld	de, (ix+VX_VECTOR_WY)
	ld	hl, (iy+VX_VECTOR_WY)
	or	a, a
	sbc	hl, de
	ld	(vxTmpVector+VX_VECTOR_WY), hl

	ld	de, (ix+VX_VECTOR_WZ)
	ld	hl, (iy+VX_VECTOR_WZ)
	or	a, a
	sbc	hl, de
	ld	(vxTmpVector+VX_VECTOR_WZ), hl

	ld	iy, vxTmpVector
	ld	hl, vxLookAtMatrix+VX_MATRIX_C6
	call	vxNormalize

	push	ix
	push	bc
	pop	ix
	ld	iy, vxLookAtMatrix+VX_MATRIX_C6
	ld	hl, vxLookAtMatrix+VX_MATRIX_C0
	call	vxCrossProduct

	ld	ix, vxLookAtMatrix+VX_MATRIX_C6
	ld	iy, vxLookAtMatrix+VX_MATRIX_C0
	ld	hl, vxLookAtMatrix+VX_MATRIX_C3
	call	vxCrossProduct
	pop	iy
	ld	ix, vxLookAtMatrix
	call	vxfTransform
; here we copy negated value to translation part of the matrix
	ld	de, (vxPosition+VX_VECTOR_LX)
	or	a, a \ sbc hl,hl \ sbc hl, de
	ld	(ix+VX_MATRIX_TX), hl
	ld	de, (vxPosition+VX_VECTOR_LY)
	or	a, a \ sbc hl,hl \ sbc hl, de
	ld	(ix+VX_MATRIX_TY), hl
	ld	de, (vxPosition+VX_VECTOR_LZ)
	or	a, a \ sbc hl,hl \ sbc hl, de
	ld	(ix+VX_MATRIX_TZ), hl
	ret
