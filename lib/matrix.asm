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
; TODO : maybe we can still use 2.6 and 18.6 format instead of full fat 8.8, however, we need some serious multiplication routine for doing signed 2.6 times 18.6 result in 18.6

vxMatrix:

.load_identity:
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

.rotate_x:
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

.rotate_z:
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

.rotate_y:
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

.mlt4:
; (hl) = (iy)*(ix) with translation
; iy is a matrix, ix is a matrix, hl is matrix
	push	hl
; load up the translation of matrix
	lea	iy, iy+VX_MATRIX_TX
	call	vxMatrix.ftransform
	lea	iy, iy-VX_MATRIX_TX
	pop	hl
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

.mlt3:
; (hl) = (iy) * (ix)
; WARNING : hl can't be equal to ix
; 116 bytes, ~3800 TStates
	ex	de, hl
	mtxi
	inc	iy
	mtxi
	inc	iy
	mtxi
	lea	ix, ix+3
	lea	iy, iy-2
	mtxi
	inc	iy
	mtxi
	inc	iy
	mtxi
	lea	ix, ix+3
	lea	iy, iy-2
	mtxi
	inc	iy
	mtxi
	inc	iy
	mtxi
	lea	ix, ix-6
	lea	iy, iy-2
	ld	bc, -9
	ex	de, hl
	add	hl, bc
	ret

.transpose:
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

.scale4:
; scale a matrix by a 3 wide 2.6 vector
; also scale the translation part of the matrix
; (iy) is the matrix, (ix) is the vector
; first line is multiplied by (ix), second by (ix+1) and third by (ix+2)
; for translation, x is scaled by (ix), y is scaled by (ix+1) and z is scaled by (ix+2)
	ld	a, (ix+0)
	fmlt	(iy+9)
	ld	(iy+VX_MATRIX_TX), hl
	ld	a, (ix+1)
	fmlt	(iy+12)
	ld	(iy+VX_MATRIX_TY), hl
	ld	a, (ix+2)
	fmlt	(iy+15)
	ld	(iy+VX_MATRIX_TZ), hl

.scale3:
; scale the matrix by a 3 wide 2.6 vector
; (iy) is the matrix, (ix) is the vector
; first line is multiplied by (ix), second by (ix+1) and third by (ix+2)
	ld	c, 3
	ld	b, c
.scale3_col_loop:
	ld	e, (ix+0)
.scale3_row_loop:
	xor	a, a
	ld	d, (iy+0)
	bit	7, e
	jr	z, $+3
	add	a, d
	bit	7, d
	jr	z, $+3
	add	a, e
	mlt	hl
	add	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	ld	(iy+0), h
	inc	iy
	djnz	.scale3_row_loop
	inc	ix
	dec	c
	jr	nz, .scale3_col_loop
	lea	iy, iy-9
	lea	ix, ix-3
	ret

.extend:
; extend an 18.6 fixed point translation vector of a matrix to a 24.0 translation vector
; extend on x
; input in iy, output in ix
	ld	hl, (iy+VX_VECTOR_LX)
	ld	a, (iy+VX_VECTOR_LX+2)
	add.s	hl, hl
	adc	a, a
	ex	de, hl
	sbc	hl, hl
	ex	de, hl
	add.s	hl, hl
	adc	a, a
	ld	e, h
	ld	d, a
	rl	l
	jr	nc, $+3
	inc	de
	ld	(ix+VX_VECTOR_LX), de
; extend on y
	ld	hl, (iy+VX_VECTOR_LY)
	ld	a, (iy+VX_VECTOR_LY+2)
	add.s	hl, hl
	adc	a, a
	ex	de, hl
	sbc	hl, hl
	ex	de, hl
	add.s	hl, hl
	adc	a, a
	ld	e, h
	ld	d, a
	rl	l
	jr	nc, $+3
	inc	de
	ld	(ix+VX_VECTOR_LY), de
; extend on z
	ld	hl, (iy+VX_VECTOR_LZ)
	ld	a, (iy+VX_VECTOR_LZ+2)
	add.s	hl, hl
	adc	a, a
	ex	de, hl
	sbc	hl, hl
	ex	de, hl
	add.s	hl, hl
	adc	a, a
	ld	e, h
	ld	d, a
	rl	l
	jr	nc, $+3
	inc	de
	ld	(ix+VX_VECTOR_LZ), de
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
; 	call	vxfTransform
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

; vxVector.extend:
; ; simple extend 16.8 -> 24.0
; ; extend on x
; 	ld	a, (iy+2)
; 	rlca
; 	sbc	hl, hl
; 	rrca
; 	ld	h, a
; 	ld	l, (iy+1)
; 	ld	(iy+VX_VECTOR_LX), hl
; ; extend on y
; 	ld	a, (iy+5)
; 	rlca
; 	sbc	hl, hl
; 	rrca
; 	ld	h, a
; 	ld	l, (iy+4)
; 	ld	(iy+VX_VECTOR_LY), hl
; ; extend on z
; 	ld	a, (iy+8)
; 	rlca
; 	sbc	hl, hl
; 	rrca
; 	ld	h, a
; 	ld	l, (iy+7)
; 	ld	(iy+VX_VECTOR_LZ), hl
; 	ret

vxMatrix.ftransform:
; input : iy vector, ix matrix
; [ix+0]*[iy]+[ix+1]*[iy+2]+[ix+2]*[iy+4]+[ix+9]=x
; [ix+3]*[iy]+[ix+4]*[iy+2]+{ix+5]*[iy+4]+[ix+12]=y
; [ix+6]*[iy]+[ix+7]*[iy+2]+[ix+8]*[iy+4]+[ix+15]=z
	ld	de, (ix+VX_MATRIX_TX)
	ld	a, (ix+VX_MATRIX_C0)
	fma	(iy+0)
	ld	a, (ix+VX_MATRIX_C1)
	fma	(iy+3)
	ld	a, (ix+VX_MATRIX_C2)
	fma	(iy+6)
	ld	(vxPosition), de
	ld	de, (ix+VX_MATRIX_TY)
	ld	a, (ix+VX_MATRIX_C3)
	fma	(iy+0)
	ld	a, (ix+VX_MATRIX_C4)
	fma	(iy+3)
	ld	a, (ix+VX_MATRIX_C5)
	fma	(iy+6)
	ld	(vxPosition+3), de
	ld	de, (ix+VX_MATRIX_TZ)
	ld	a, (ix+VX_MATRIX_C6)
	fma	(iy+0)
	ld	a, (ix+VX_MATRIX_C7)
	fma	(iy+3)
	ld	a, (ix+VX_MATRIX_C8)
	fma	(iy+6)
	ld	(vxPosition+6), de
	ret

; vxfTransformDouble:
; vxMatrix.ftransform:
; ; 	lea	hl, iy+0
; ; 	ld	de, vxPosition
; ; 	ld	bc, 9
; ; 	ldir
; ; 	lea	de, iy+0
; ; 	call	vxfPositionExtract
; 	push	ix
; 	lea	ix, iy+0
; 	call	vxMatrix.extend
; 	pop	ix
; vxfTransform:
; ; input : iy vector, ix matrix
; ; [ix+0]*[iy]+[ix+1]*[iy+2]+[ix+2]*[iy+4]+[ix+9]=x
; ; [ix+3]*[iy]+[ix+4]*[iy+2]+{ix+5]*[iy+4]+[ix+12]=y
; ; [ix+6]*[iy]+[ix+7]*[iy+2]+[ix+8]*[iy+4]+[ix+15]=z
; ; From 1566+x? TStates to 1654 TStates, 333 bytes
; ; X coordinate
; ; you know, I am really madd ! *coder stare at you*
; 	ld	bc, (iy+0)
; 	ld	de, (ix+9)
; 	ld	a, (ix+0)
; 	ld	h, b
; 	ld	l, a
; 	mlt	hl
; 	cp	$80
; 	jr	c, $+4
; 	sbc	hl, bc
; 	bit	7, b
; 	ld	b, a
; 	jr	z, $+5
; 	cpl
; 	adc	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	mlt	bc
; 	add	hl, bc
; 	add	hl, de
; 	ld	a, (ix+1)
; 	ld	bc, (iy+3)
; 	ex	de, hl
; 	ld	h, b
; 	ld	l, a
; 	mlt	hl
; 	cp	$80
; 	jr	c, $+4
; 	sbc	hl, bc
; 	bit	7, b
; 	ld	b, a
; 	jr	z, $+5
; 	cpl
; 	adc	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	mlt	bc
; 	add	hl, bc
; 	add	hl, de
; 	ld	a, (ix+2)
; 	ld	bc, (iy+6)
; 	ld	d, c
; 	ld	e, a
; 	mlt	de
; 	add	hl, de
; 	ex	de, hl
; 	ld	h, b
; 	ld	l, a
; 	mlt	hl
; ; watch the carry flag !
; 	cp	$80
; 	jr	c, $+4
; 	sbc	hl, bc
; 	bit	7, b
; 	jr	z, $+5
; 	cpl
; 	adc	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, de
; 	ld	(vxPosition), hl
; ; Y coordinate
; 	ld	de, (ix+12)
; 	ld	a, (ix+5)
; 	ld	h, b
; 	ld	l, a
; 	mlt	hl
; 	cp	$80
; 	jr	c, $+4
; 	sbc	hl, bc
; 	bit	7, b
; 	ld	b, a
; 	jr	z, $+5
; 	cpl
; 	adc	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	mlt	bc
; 	add	hl, bc
; 	add	hl, de
; 	ld	a, (ix+4)
; 	ld	bc, (iy+3)
; 	ex	de, hl
; 	ld	h, b
; 	ld	l, a
; 	mlt	hl
; 	cp	$80
; 	jr	c, $+4
; 	sbc	hl, bc
; 	bit	7, b
; 	ld	b, a
; 	jr	z, $+5
; 	cpl
; 	adc	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	mlt	bc
; 	add	hl, bc
; 	add	hl, de
; 	ld	a, (ix+3)
; 	ld	bc, (iy+0)
; 	ld	d, c
; 	ld	e, a
; 	mlt	de
; 	add	hl, de
; 	ex	de, hl
; 	ld	h, b
; 	ld	l, a
; 	mlt	hl
; ; watch the carry flag !
; 	cp	$80
; 	jr	c, $+4
; 	sbc	hl, bc
; 	bit	7, b
; 	jr	z, $+5
; 	cpl
; 	adc	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, de
; 	ld	(vxPosition+3), hl
; ; Z coordinate
; 	ld	de, (ix+15)
; 	ld	a, (ix+6)
; 	ld	h, b
; 	ld	l, a
; 	mlt	hl
; 	cp	$80
; 	jr	c, $+4
; 	sbc	hl, bc
; 	bit	7, b
; 	ld	b, a
; 	jr	z, $+5
; 	cpl
; 	adc	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	mlt	bc
; 	add	hl, bc
; 	add	hl, de
; 	ld	a, (ix+7)
; 	ld	bc, (iy+3)
; 	ex	de, hl
; 	ld	h, b
; 	ld	l, a
; 	mlt	hl
; 	cp	$80
; 	jr	c, $+4
; 	sbc	hl, bc
; 	bit	7, b
; 	ld	b, a
; 	jr	z, $+5
; 	cpl
; 	adc	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	mlt	bc
; 	add	hl, bc
; 	add	hl, de
; 	ld	a, (ix+8)
; 	ld	bc, (iy+6)
; 	ld	d, c
; 	ld	e, a
; 	mlt	de
; 	add	hl, de
; 	ex	de, hl
; 	ld	h, b
; 	ld	l, a
; 	mlt	hl
; ; watch the carry flag !
; 	cp	$80
; 	jr	c, $+4
; 	sbc	hl, bc
; 	bit	7, b
; 	jr	z, $+5
; 	cpl
; 	adc	a, h
; 	ld	h, a
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, hl
; 	add	hl, de
; 	ld	(vxPosition+6), hl
; 	ret

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
