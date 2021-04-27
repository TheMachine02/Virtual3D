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

; Quaternions utility functions

define VX_QUATERNION_SIZE		$0C
define VX_QUATERNION_QW             	$0
define VX_QUATERNION_QX          	$3
define VX_QUATERNION_QY       		$6
define VX_QUATERNION_QZ             	$9

vxIdentityQuaternion:
 dl	$004000
 dl	$000000
 dl	$000000
 dl	$000000

vxQuaternionLoadIdentity:
	ex	de, hl
	ld	hl, vxIdentityQuaternion
	ld	bc, VX_QUATERNION_SIZE
	ldir
	ex	de, hl
	dec	bc
	ld	c, -VX_QUATERNION_SIZE
	add	hl, bc
	ret
vxQuaternionLoadRotation:
	ret
vxQuaternionMlt:
; ix = ix * iy
	ld	hl, (ix+VX_QUATERNION_QZ)
	ld	de, (iy+VX_QUATERNION_QZ)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QX)
	ld	de, (iy+VX_QUATERNION_QX)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QY)
	ld	de, (iy+VX_QUATERNION_QY)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QW)
	ld	de, (iy+VX_QUATERNION_QW)
	call	vxQuatMlt
	pop	de
	or	a, a
	sbc	hl, de
	pop	de
	or	a, a
	sbc	hl, de
	pop	de
	or	a, a
	sbc	hl, de
; got VX_QUATERNION_QW
	push	hl
	ld	hl, (ix+VX_QUATERNION_QW)
	ld	de, (iy+VX_QUATERNION_QX)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QX)
	ld	de, (iy+VX_QUATERNION_QW)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QZ)
	ld	de, (iy+VX_QUATERNION_QY)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QY)
	ld	de, (iy+VX_QUATERNION_QZ)
	call	vxQuatMlt
	pop	de
	or	a, a
	sbc	hl, de
	pop	de
	add	hl, de
	pop	de
	add	hl, de
; got VX_QUATERNION_QX
	push	hl
	ld	hl, (ix+VX_QUATERNION_QW)
	ld	de, (iy+VX_QUATERNION_QY)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QX)
	ld	de, (iy+VX_QUATERNION_QZ)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QY)
	ld	de, (iy+VX_QUATERNION_QW)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QZ)
	ld	de, (iy+VX_QUATERNION_QX)
	call	vxQuatMlt
	pop	de
	add	hl, de
	pop	de
	or	a, a
	sbc	hl, de
	pop	de
	add	hl, de
; got VX_QUATERNION_QY
	push	hl
	ld	hl, (ix+VX_QUATERNION_QW)
	ld	de, (iy+VX_QUATERNION_QZ)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QX)
	ld	de, (iy+VX_QUATERNION_QY)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QY)
	ld	de, (iy+VX_QUATERNION_QX)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QZ)
	ld	de, (iy+VX_QUATERNION_QW)
	call	vxQuatMlt
	pop	bc
	pop	de
	add	hl, de
	pop	de
	add	hl, de
	sbc	hl, bc
; got VX_QUATERNION_QZ
	ld	(ix+VX_QUATERNION_QZ), hl
	pop	hl
	ld	(ix+VX_QUATERNION_QY), hl
	pop	hl
	ld	(ix+VX_QUATERNION_QX), hl
	pop	hl
	ld	(ix+VX_QUATERNION_QW), hl
	ret

vxQuaternionMagnitude:
	ld	hl, (ix+VX_QUATERNION_QW)
	call	vxQuatSquare
	push	de
	ld	hl, (ix+VX_QUATERNION_QX)
	call	vxQuatSquare
	push	de
	ld	hl, (ix+VX_QUATERNION_QY)
	call	vxQuatSquare
	push	de
	ld	hl, (ix+VX_QUATERNION_QZ)
	call	vxQuatSquare
	pop	hl
	add	hl, de
	pop	de
	add	hl, de
	pop	de
	add	hl, de
	ret
vxQuaternionConjugate:
	ld	de, (ix+3)
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ld	(ix+3), hl
	add	hl, de
	ld	de, (ix+6)
	or	a, a
	sbc	hl, de
	ld	(ix+6), hl
	add	hl, de
	ld	de, (ix+9)
	or	a, a
	sbc	hl, de
	ld	(ix+9), hl
	ret
vxQuaternionNormalize:
	ret
vxQuatDivide:
; do HL*16384/DE
	ret
vxQuaternionGetMatrix:
; iy quaternion, ix matrix
; (qw, qx, qy, qz)
; 1 - 2*qy² - 2*qz² 	2*qx*qy - 2*qz*qw 	2*qx*qz + 2*qy*qw
; 2*qx*qy + 2*qz*qw 	1 - 2*qx² - 2*qz² 	2*qy*qz - 2*qx*qw
; 2*qx*qz - 2*qy*qw 	2*qy*qz + 2*qx*qw 	1 - 2*qx² - 2*qy²
	ld	hl, (iy+VX_QUATERNION_QZ)
	ld	de, (iy+VX_QUATERNION_QW)
	call	vxQuatMlt
	add	hl, hl
; 2*qz*qw
	push	hl
	ld	hl, (iy+VX_QUATERNION_QX)
	ld	de, (iy+VX_QUATERNION_QY)
	call	vxQuatMlt
	add	hl, hl
; 2*qx*qy
	pop	de
	or	a, a
	sbc	hl, de
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ld	(ix+1), a
	add	hl, de
	add	hl, de
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ld	(ix+3), a
; next
	ld	hl, (iy+VX_QUATERNION_QY)
	ld	de, (iy+VX_QUATERNION_QW)
	call	vxQuatMlt
	add	hl, hl
; 2*qw*qy
	push	hl
	ld	hl, (iy+VX_QUATERNION_QX)
	ld	de, (iy+VX_QUATERNION_QZ)
	call	vxQuatMlt
	add	hl, hl
; 2*qx*qz
	pop	de
	or	a, a
	sbc	hl, de
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ld	(ix+6), a
	add	hl, de
	add	hl, de
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ld	(ix+2), a
; next
	ld	hl, (iy+VX_QUATERNION_QX)
	ld	de, (iy+VX_QUATERNION_QW)
	call	vxQuatMlt
	add	hl, hl
; 2*qx*qw
	push	hl
	ld	hl, (iy+VX_QUATERNION_QY)
	ld	de, (iy+VX_QUATERNION_QZ)
	call	vxQuatMlt
	add	hl, hl
; 2*qy*qz
	pop	de
	or	a, a
	sbc	hl, de
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ld	(ix+5), a
	add	hl, de
	add	hl, de
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ld	(ix+7), a
; 1-2*qy²-2qz²
	ld	hl, (iy+VX_QUATERNION_QY)
	call	vxQuatSquare
	push	de
	push	de
	ld	hl, (iy+VX_QUATERNION_QZ)
	call	vxQuatSquare
	pop	bc
	ld	hl, $004000
	or	a, a
	sbc	hl, bc
	or	a, a
	sbc	hl, de
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ld	(ix+0), a
; 1-2*qz²-2qx²	
	push	de
	ld	hl, (iy+VX_QUATERNION_QX)
	call	vxQuatSquare
	pop	bc
	ld	hl, $004000
	or	a, a
	sbc	hl, bc
	or	a, a
	sbc	hl, de
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ld	(ix+4), a
; 1-2qx²-2qy²
	pop	bc
	ld	hl, $004000
	or	a, a
	sbc	hl, bc
	or	a, a
	sbc	hl, de
	ld	a, l
	rla
	ld	a, h
	adc	a, 0
	ld	(ix+8), a
	ret

vxQuaternionRotationAxis:
; iy adress of quaternion to write
; ix unit vector
; a angle
; qw = cos(angle/2)
; qx = axis.x*sin(angle/2)
; qy = axis.y*sin(angle/2)
; qz = axis.z*sin(angle/2)
	push	hl
	call	vxMath.sin
; hl = sin
	ex	de, hl
; DE is never destroyed by the macro's
	ld	hl, (ix+0)
	call	vxQuatMlt
	ld	(iy+VX_QUATERNION_QX), hl
	ld	hl, (ix+3)
	call	vxQuatMlt
	ld	(iy+VX_QUATERNION_QY), hl
	ld	hl, (ix+6)
	call	vxQuatMlt
	ld	(iy+VX_QUATERNION_QZ), hl
	pop	hl
	call	vxMath.cos
	ld	(iy+VX_QUATERNION_QW), hl
	ret

vxQuaternionDot:
	ld	hl, (ix+VX_QUATERNION_QW)
	ld	de, (iy+VX_QUATERNION_QW)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QX)
	ld	de, (iy+VX_QUATERNION_QX)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QY)
	ld	de, (iy+VX_QUATERNION_QY)
	call	vxQuatMlt
	push	hl
	ld	hl, (ix+VX_QUATERNION_QZ)
	ld	de, (iy+VX_QUATERNION_QZ)
	call	vxQuatMlt
	pop	de
	add	hl, de
	pop	de
	add	hl, de
	pop	de
	add	hl, de
	ret

vxQuaternionSlerp:
	ret

; always included functions to works with quaternions, called by the majority of the routines.

vxQuatMlt:
; hl *de, de is not destroyed
; start with hl*de/16384
; does NOT round
; HLxDE/256 [16bits]
; (HxD*256+LxD+ExH+LxE/256)
	ld	b, h
	ld	c, l
	ld	l, d
	mlt	hl
	bit	7, b
	jr	z, $+5
	or	a, a
	sbc	hl, de
	bit	7, d
	jr	z, $+5
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
; now need to do (CxD+BxE+ExC/256)
	ld	a, c
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	c, a
	ld	b, d
	mlt	bc
	add	hl, bc
	ld	c, a
	ld	b, e
	mlt	bc
	ld	c, b
	ld	b, 0
	add	hl, bc
; and now divide by 64
	add	hl, hl
	add	hl, hl
	dec	sp
	ld	a, l
	push	hl
	inc	sp
	pop	bc
	sbc	hl, hl
	ld	h, b
	ld	l, c
	rla
	ret	nc
	inc	hl
	ret
vxQuatSquare:
; bc is kept intact
; HL²/256
; Destroy DE,A [16bits]
; (HxH*256+LxH*2+LxL/256)
	bit	7, h
	jr	z, vxSqAbsSkp
	ex	de, hl
	or	a, a
	sbc	hl, hl
	sbc	hl, de
vxSqAbsSkp:
	ld	d, h
	ld	e, l
	ld	l, h
	mlt	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a, e
	mlt	de
	add	hl, de
	add	hl, de
	ld	e, a
	ld	d, a
	mlt	de
	ld	e, d
	ld	d, 0
	add	hl, de
; divide by 32
	add	hl, hl
	add	hl, hl
	add	hl, hl
	dec	sp
	push	hl
	inc	sp
	pop	af
	ld	e, h
	ld	d, a
	rl	l
	ret	nc
	inc	de
	ret

