#define dbgbreak   scf \ sbc hl, hl \ ld (hl), 2
#define dbgstart0 	push hl \ ld hl,$F20030 \ set 0,(hl) \ pop hl
#define dbgstop0	push hl \ ld hl,$F20030 \ res 0,(hl) \ pop hl

 ; Virtual-3D library, version 1.0
 ;
 ; Copyright (c) 2016-2017, 'TheMachine02'
 ; All rights reserved.
 ;
 ; Redistribution and use in source and binary forms, with or without
 ; modification, are permitted provided that the following conditions are met:
 ;
 ; ; Redistributions of source code must retain the above copyright notice, this
 ; list of conditions and the following disclaimer.
 ;
 ; ; Redistributions in binary form must reproduce the above copyright notice,
 ; this list of conditions and the following disclaimer in the documentation
 ; and/or other materials provided with the distribution.
 ;
 ; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 ; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 ; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 ; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 ; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 ; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 ; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 ; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 ; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 ; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ; ;

#ifndef VX_3D_GUARD
#define VX_3D_GUARD

.nolist
#define OS__FLAGS           $D00080
#ifndef TI84PCE
#include "ti84pce.inc"
#include "relocate.inc"
.nolist
#endif
#include	"vxModel.inc"

; standard defines ;

#define VX_VERSION        $10
#define VX_TRUE           $01
#define VX_FALSE          $00

; geometry ;

#define IPOINT              %00000001
#define ILINE               %00000010
#define ITRIANGLE           %00000011
#define IQUADRI             %00000100
#define ILINE_FAN           %10000010
#define ITRIANGLE_FAN       %10000011
#define IBACK_CULL          %00000001

;;#define IVERTEX_BUFFER      $D09466
#define IVERTEX_BUFFER $D08000 ;32K

; mesh ;

; maths ;

; RAM and VRAM ;

; color LCD ;

; batch ;

; depth test ;

#define VX_DEPTH_TEST         $01
#define VX_DEPTH_OFFSET       8388608
#define VX_DEPTH_BITS         24
#define VX_DEPTH_MIN          0
#define VX_DEPTH_MAX          16777215

; texture ;

; limits ;

; static variables ;

; functions ;

#define madd                  __imadd_src_()
#define slhl                 __islhl_src_()
#define .align               align(
.addinstr  ld a,hlu 3BF133E5 4
.addinstr  ld a,deu 3BF133D5 4

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
#define	madd.f	madd2()

#macro  __islhl_src_()
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
#endmacro

#macro align(bound)
	.fill bound-($%bound)
#endmacro

.addinstr  ld a,(hl+) 000000 3 NOP 1
.addinstr  ld (hl+),a 000000 3 NOP 1

.list

; global compilation variable ;

#define	VX_PS_1.0
#define	VX_VS_1.x
.echo "vxLib API version 1.0"
.echo "pixel shader version  : ps_1.0"
; ps_1.0
.echo "vertex shader version : vs_1.x"

.addinstr  ldi	(de),a 1312 2 NOP 0
.addinstr  xori a,(de) 13EBAEEB 4 NOP 0
.addinstr  andi a,(de) 13EBA6EB 4 NOP 0
.addinstr  ori	a,(de) 13EBB6EB 4 NOP 0

#endif
