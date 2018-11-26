; Virtual-3D library, version 1.0
;
; Copyright (c) 2017 TheMachine02

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
.nolist

#ifndef VX_3D_GUARD
#define VX_3D_GUARD


#define OS__FLAGS           $D00080

#include "relocate.inc"
#include	"vxModel.inc"
#include	"vxVSL.inc"
; standard defines ;

#define VX_VERSION        $10
#define VX_TRUE           $01
#define VX_FALSE          $00

; geometry ;

; mesh ;

; maths ;

; RAM and VRAM ;

#define	VX_LUT_CONVOLVE		$D00000
#define	VX_LUT_CONVOLVE_SIZE	8192
#define	VX_LUT_SIN			$D02000
#define	VX_LUT_SIN_SIZE		512

; color LCD ;

; batch ;

; depth test ;

; texture ;

; limits ;

; static variables ;

#define fma                  __imadd_src_()
#define .align               align(
.addinstr  ld a,hlu 3BF133E5 4

; Fused multiply and add macro
; madd [bc,a,hl]
; Do hl = (bc x a) + hl
; bc:16bits, a:8bits, hl:24bits, accumulated on 24 bits
; From 122 to 132 TStates on 4 wait-states RAM [122,125,129,132]
; From 096 to 101 TStates on 3 wait-states RAM [096,97,100,101]
; 31 Bytes
#macro __imadd_src_()
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
#endmacro
#macro	madd2()
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
; ok, that was fast !
#endmacro
#define	fma.f	madd2()

#macro align(bound)
	.fill bound-($%bound)
#endmacro


; global compilation variable ;

#define	VX_PS_1.0
#define	VX_VS_1.0
#define	VX_VS_1.x
#define	VX_GS_1.0

;.echo "vxLib API version 0.9 alpha"
;.echo "vertex shader version   : vs_1.x"
;.echo "geometry shader version : gs_1.0"
;.echo "pixel shader version    : ps_1.0"

#define dbreak   scf \ sbc hl, hl \ ld (hl), 2
#define dstm 	 push hl \ ld hl,$F20030 \ set 0,(hl) \ pop hl
#define drtm	 push hl \ ld hl,$F20030 \ res 0,(hl) \ pop hl

#endif
.list
