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

vxTmpVector:
 dw	0,0,0
 db	0	; pad
vxLookAtMatrix:
 db	0,0,0
 db	0,0,0
 db	0,0,0
 dl	0,0,0

; TODO : clean this file, remove useless function, optimize other (matrix multiplication could benefit from full unroll) 
; TODO : Use 8.8 and 16.8 for matrix instead of stranger format

vxMatrixLoadIdentity:
vxMatrix.loadIdentity:
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

.rotateX:
	push	hl
	call	vxMath.sin
	ld	a, h
	ld	(ix+VX_MATRIX_C7), a
	neg
	ld	(ix+VX_MATRIX_C5), a
	ld	hl, 64
	ld	(ix+VX_MATRIX_C0), hl
	ld	(ix+VX_MATRIX_C3), h
	ld	(ix+VX_MATRIX_C6), h
	pop	hl
	call	vxMath.cos
	ld	(ix+VX_MATRIX_C4), h
	ld	(ix+VX_MATRIX_C8), h
	ret

.rotateZ:
	push	hl
	call	vxMath.sin
	ld	a, h
	ld	(ix+VX_MATRIX_C3), a
	neg
	ld	(ix+VX_MATRIX_C1), a
	or	a, a
	sbc	hl, hl
	ld	(ix+VX_MATRIX_C2), l
	ld	(ix+VX_MATRIX_C5), hl
	pop	hl
	call	vxMath.cos
	ld	(ix+VX_MATRIX_C0), h
	ld	(ix+VX_MATRIX_C4), h
	ld	(ix+VX_MATRIX_C8), 64
	ret

.rotateY:
	push	hl
	call	vxMath.sin
	ld	a, h
	ld	(ix+VX_MATRIX_C2), a
	neg
	ld	(ix+VX_MATRIX_C6), a
	ld	hl, $004000
	ld	(ix+VX_MATRIX_C3), hl
	ld	(ix+VX_MATRIX_C1), l
	ld	(ix+VX_MATRIX_C7), l
	pop	hl
	call	vxMath.cos
	ld	(ix+VX_MATRIX_C0), h
	ld	(ix+VX_MATRIX_C8), h
	ret

vxMatrixMlt:
vxMatrix.mlt3:
; (hl) = (iy) * (ix)
; WARNING : hl can't be equal to ix
; 116 bytes, ~3800 TStates
	ex	de, hl
	ld	bc, $000303
vxMatrixColLoop:
	push	bc
	ld	b, c
vxMatrixRowLoop:
	push	bc
	ld	h, (ix+0)
	ld	l, (iy+0)
	xor	a, a
	bit	7, h
	jr	z, $+3
	sub	a, l
	bit	7, l
	jr	z, $+3
	sub	a, h
	mlt	hl
	ld	b, (ix+1)
	ld	c, (iy+3)
	bit	7, b
	jr	z, $+3
	sub	a, c
	bit	7, c
	jr	z, $+3
	sub	a, b
	mlt	bc
	add	hl, bc
	ld	b, (ix+2)
	ld	c, (iy+6)
	bit	7, b
	jr	z, $+3
	sub	a, c
	bit	7, c
	jr	z, $+3
	sub	a, b
	mlt	bc
	add	hl, bc
	ld	b, a
	xor	a, a
	ld	c, a
	add	hl, bc
	add	hl, hl
	add	hl, hl
	ld	a, h
	rl	l
	adc	a, c
	ld	(de), a
	inc	de
	inc	iy
	pop	bc
	djnz	vxMatrixRowLoop
	add	ix, bc
	lea	iy, iy-3
	pop	bc
	djnz	vxMatrixColLoop
	ld	bc, -9
	add	ix, bc
	ex	de, hl
	add	hl, bc
	ret
	
vxMatrixTransform:
vxMatrix.mlt4:
; (hl) = (iy)*(ix) with translation
; iy is a matrix, ix is a matrix, hl is matrix
	push	hl
; load up the translation of matrix
	lea	iy, iy+VX_MATRIX_TX
	call	vxfTransformDouble
	lea	iy, iy-VX_MATRIX_TX
	pop	hl
	call	vxMatrixMlt
; copy translation data to result (hl)
	ld	bc, 9
	add	hl, bc
	ld	de, vxPosition
	ex	de, hl
	ldir
	dec	bc
	ld	c, -VX_MATRIX_SIZE
	ex	de, hl
	add	hl, bc
	ret

vxMatrix.fixed_vector_transform:
; input : iy vector, ix matrix
; [ix+0]*[iy]+[ix+2]*[iy+2]+[ix+2]*[iy+4]+[ix+9]=x
; [ix+3]*[iy]+[ix+4]*[iy+2]+{ix+5]*[iy+4]+[ix+12]=y
; [ix+6]*[iy]+[ix+7]*[iy+2]+[ix+8]*[iy+4]+[ix+15]=z
	
	
vxMatrixTranspose:
vxMatrix.transpose:
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
	add	hl, de
	ld	de, (ix+VX_MATRIX_TY)
	or	a, a
	sbc	hl, de
	ld	(ix+VX_MATRIX_TY), hl
	add	hl, de
	ld	de, (ix+VX_MATRIX_TZ)
	or	a, a
	sbc	hl, de
	ld	(ix+VX_MATRIX_TZ), hl
	ret

vxMatrix.scale3:
; scale the matrix by a 3 wide 8.8 vector
; (iy) is the matrix, (ix) is the vector
; first line is multiplied by (ix), second by (ix+1) and third by (ix+2)


vxMatrix.scale4:
; scale a matrix by a 3 wide 8.8 vector
; also scale the translation part of the matrix
; (iy) is the matrix, (ix) is the vector
; first line is multiplied by (ix), second by (ix+1) and third by (ix+2)
; for translation, x is scaled by (ix), y is scaled by (ix+1) and z is scaled by (ix+2)

	ret

vxMatrixLightning:
	ld	b, 3
vxMatrixLightLoop:
	push	bc
	push	hl
	call	vxDotProduct
	add	hl, hl
	add	hl, hl
	ld	a, h
	pop	hl
	ld	(hl), a
	inc	hl
	lea	ix, ix+3
	pop	bc
	djnz	vxMatrixLightLoop
	lea	ix, ix-9
; ix = matrix, light = de, initial light = iy
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
	ld	hl, (vxPosition)
	add	hl, hl
	add	hl, hl
	ld	(vxPosition), hl
	ld	hl, (vxPosition+3)
	add	hl, hl
	add	hl, hl
	ld	(vxPosition+3), hl
	ld	hl, (vxPosition+6)
	add	hl, hl
	add	hl, hl
	ld	(vxPosition+6), hl
	pop	hl
	ld	de, (vxPosition+1)
	ld	(hl), e
	inc	hl
	ld	(hl), d
	inc	hl
	ld	de, (vxPosition+4)
	ld	(hl), e
	inc	hl
	ld	(hl), d
	inc	hl
	ld	de, (vxPosition+7)
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ret

vxfPositionExtract:
; vxPosition/64 -> de
	ld	hl, (vxPosition)
	add	hl, hl
	sbc	a, a
	add	hl, hl
	dec	sp
	push	hl
	inc	sp
	pop	bc
	rla
	ld	a, l
	sbc	hl, hl
	ld	h, b
	ld	l, c
	rla
	jr	nc, $+3
	inc	hl
	ex	de, hl
	ld	(hl), de
	inc	hl
	inc	hl
	inc	hl
	ex	de, hl
	ld	hl, (vxPosition+3)
	add	hl, hl
	sbc	a, a
	add	hl, hl
	dec	sp
	push	hl
	inc	sp
	pop	bc
	rla
	ld	a, l
	sbc	hl, hl
	ld	h, b
	ld	l, c
	rla
	jr	nc, $+3
	inc	hl
	ex	de, hl
	ld	(hl), de
	inc	hl
	inc	hl
	inc	hl
	ex	de, hl
	ld	hl, (vxPosition+6)
	add	hl, hl
	sbc	a, a
	add	hl, hl
	dec	sp
	push	hl
	inc	sp
	pop	bc
	rla
	ld	a, l
	sbc	hl, hl
	ld	h, b
	ld	l, c
	rla
	jr	nc, $+3
	inc	hl
	ex	de, hl
	ld	(hl), de
	ret

vxfMatrixPerspective:
; (hl) = transform the modelview matrix (iy) by a specific fov 90° aspect ratio 4:3 matrix
; first lign  *48/64 (signed*unsigned)
	ld	d, (iy+0)
	ld	e, 192
	xor	a, a
	bit	7, d
	jr	z, $+3
	sub	a, e
	mlt	de
	rl	e
	adc	a, d
	ld	(hl), a
	inc	hl

	ld	d, (iy+1)
	ld	e, 192
	xor	a, a
	bit	7, d
	jr	z, $+3
	sub	a, e
	mlt	de
	rl	e
	adc	a, d
	ld	(hl), a
	inc	hl
	
	ld	d, (iy+2)
	ld	e, 192
	xor	a, a
	bit	7, d
	jr	z, $+3
	sub	a, e
	mlt	de
	rl	e
	adc	a, d
	ld	(hl), a
	inc	hl

	ex	de, hl
	lea	hl, iy+3
	ld	bc, VX_MATRIX_SIZE - 3
	ldir
	ld	bc, -9
	ex	de, hl
	add	hl, bc
; hl is TX of created matrix
; iy is source
	push	hl
	ld	a, 192
	ld	h, (iy+VX_MATRIX_TX+2)
	ld	l, a
	bit	7, h
	mlt	hl
	jr	z, $+6
	neg
	add	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	e, (iy+VX_MATRIX_TX+1)
	ld	d, 192
	mlt	de
	add	hl, de
	ld	d, 192
	ld	e, (iy+VX_MATRIX_TX)
	mlt	de
	rl	e
	ld	e, d
	ld	d, 0
	adc	hl, de
	ex	de, hl
	pop	hl
	ld	(hl), de
	ret
	
vxfTransformDouble:
	lea	hl, iy+0
	ld	de, vxPosition
	ld	bc, 9
	ldir
	lea	de, iy+0
	call	vxfPositionExtract
vxfTransform:
; input : iy vector, ix matrix
; [ix+0]*[iy]+[ix+1]*[iy+2]+[ix+2]*[iy+4]+[ix+9]=x
; [ix+3]*[iy]+[ix+4]*[iy+2]+{ix+5]*[iy+4]+[ix+12]=y
; [ix+6]*[iy]+[ix+7]*[iy+2]+[ix+8]*[iy+4]+[ix+15]=z
; From 1566+x? TStates to 1654 TStates, 333 bytes
; X coordinate
; you know, I am really madd ! *coder stare at you*
	ld	bc, (iy+0)
	ld	de, (ix+9)
	ld	a, (ix+0)
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+1)
	ld	bc, (iy+3)
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+2)
	ld	bc, (iy+6)
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
; watch the carry flag !
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	(vxPosition), hl
; Y coordinate
	ld	de, (ix+12)
	ld	a, (ix+5)
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+4)
	ld	bc, (iy+3)
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+3)
	ld	bc, (iy+0)
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
; watch the carry flag !
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	(vxPosition+3), hl
; Z coordinate
	ld	de, (ix+15)
	ld	a, (ix+6)
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+7)
	ld	bc, (iy+3)
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+8)
	ld	bc, (iy+6)
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
; watch the carry flag !
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	ld	(vxPosition+6), hl
	ret

; vxMatrixLookAt:
; ; zaxis = normal(At - Eye)
; ; xaxis = normal(cross(Up, zaxis))
; ; yaxis = cross(zaxis, xaxis)
; ; xaxis.x           xaxis.y           xaxis.z          0
; ; yaxis.x           yaxis.y           yaxis.z          0
; ; zaxis.x           zaxis.y           zaxis.z          0
; ;-dot(xaxis, eye)  -dot(yaxis, eye)  -dot(zaxis, eye)  l
; ; ix is eye, iy is At, bc is Up
; 	ld	de, (ix+VX_VECTOR_WX)
; 	ld	hl, (iy+VX_VECTOR_WX)
; 	or	a, a
; 	sbc	hl, de
; 	ld	(vxTmpVector+VX_VECTOR_WX), hl
; 
; 	ld	de, (ix+VX_VECTOR_WY)
; 	ld	hl, (iy+VX_VECTOR_WY)
; 	or	a, a
; 	sbc	hl, de
; 	ld	(vxTmpVector+VX_VECTOR_WY), hl
; 
; 	ld	de, (ix+VX_VECTOR_WZ)
; 	ld	hl, (iy+VX_VECTOR_WZ)
; 	or	a, a
; 	sbc	hl, de
; 	ld	(vxTmpVector+VX_VECTOR_WZ), hl
; 
; 	ld	iy, vxTmpVector
; 	ld	hl, vxLookAtMatrix+VX_MATRIX_C6
; 	call	vxNormalize
; 
; 	push	ix
; 	push	bc
; 	pop	ix
; 	ld	iy, vxLookAtMatrix+VX_MATRIX_C6
; 	ld	hl, vxLookAtMatrix+VX_MATRIX_C0
; 	call	vxCrossProduct
; 
; 	ld	ix, vxLookAtMatrix+VX_MATRIX_C6
; 	ld	iy, vxLookAtMatrix+VX_MATRIX_C0
; 	ld	hl, vxLookAtMatrix+VX_MATRIX_C3
; 	call	vxCrossProduct
; 	pop	iy
; 	ld	ix, vxLookAtMatrix
; 	call	vxfTransform
; ; here we copy negated value to translation part of the matrix
; 	ld	de, (vxPosition+VX_VECTOR_LX)
; 	or	a, a
; 	sbc hl,hl
; 	sbc hl, de
; 	ld	(ix+VX_MATRIX_TX), hl
; 	ld	de, (vxPosition+VX_VECTOR_LY)
; 	or	a, a
; 	sbc hl,hl
; 	sbc hl, de
; 	ld	(ix+VX_MATRIX_TY), hl
; 	ld	de, (vxPosition+VX_VECTOR_LZ)
; 	or	a, a
; 	sbc hl,hl
; 	sbc hl, de
; 	ld	(ix+VX_MATRIX_TZ), hl
; 	ret
; vxProjectionVector:
;  db	192, 0, 0
;  
; vxMatrixProjection:
; ; scale the matrix iy by the projection vector
; ; 0 = 256
; 	ld	hl, vxProjectionVector
; 	ld	c, 3
; .outer:
; 	ld	b, 3
; 	xor	a, a
; .outer0:
; 	or	a, (hl)
; 	jr	nz, .inner
; 	lea	iy, iy+3
; 	inc	hl
; 	dec	c
; 	jr	nz, .outer0
; 	jr	.translate
; .inner:
; 	ld	d, (iy+0)
; 	ld	e, (hl)
; 	xor	a, a
; 	bit	7, d
; 	jr	z, $+3
; 	sub	a, e
; 	mlt	de
; 	rl	e
; 	adc	a, d
; 	ld	(iy+0), a
; 	inc	iy
; 	djnz	.inner
; 	inc	hl
; 	dec	c
; 	jr	nz, .outer
; ; now the translation
; .translate:
; 	ret
; 
; ; (iy)*(de) (signed 24 bits * unsigned 8 bits / 256)
; ; hlu * a *256 + h*a + l*a / 256
; ; if hl < 0
; 	ld	b, 3
; 	ld	de, vxProjectionVector
; .vector:
; 	ld	a, (de)
; 	or	a, a
; 	jr	z, .skip
; 	push	de
; 	ld	h, (iy+2)
; 	ld	l, a
; 	bit	7, h
; 	mlt	hl	; condition bits NOT affected
; 	jr	z, $+6
; 	neg
; 	add	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	ld	a, (de)
; 	ld	e, (iy+1)
; 	ld	d, a
; 	mlt	de
; 	add	hl, de
; 	ld	d, a
; 	ld	e, (iy+0)
; 	mlt	de
; 	rl	e
; 	ld	e, d
; 	ld	d, 0
; 	adc	hl, de
; 	ld	(iy+0), hl
; 	pop	de
; .skip:
; 	lea	iy, iy+3
; 	inc	de
; 	djnz	.vector
; 	ret
