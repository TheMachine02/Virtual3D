 ; ;
 ; Virtual Insanity graphic library, version 1.0
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
 
#ifndef __vxgl_h_
#define __vxgl_h_

.nolist
#define OS__FLAGS           $D00080	
#ifndef TI84PCE
#include "ti84pce.inc"
.nolist
#endif

; standard defines ;

#define VX_VERSION			$10
#define VX_TRUE               	$01
#define VX_FALSE              	$00

; pipeline ;

#define	VX_GEOMETRY_N3TI9	%00010011	; 19
#define	VX_GEOMETRY_TI9		%00010000	; 16
#define	VX_GEOMETRY_N3CI9	%00001101	; 13
#define	VX_GEOMETRY_CI9		%00001010	; 10

#define	VX_ANIMATION_MATRIX_SIZE	15
#define	VX_ANIMATION_BONE	32768

#define	VX_MATRIX_SIZE		18
#define	VX_QUATERNION_SIZE    $0C

#define	VX_GEOMETRY_QUEUE	$D10000	; 4*4096 (16K)
#define	VX_VERTEX_BUFFER		$D08000	; 16*2048 (32K)

; limits ;

#define	VX_MAX_VRAM		1024
#define	VX_MAX_TEXTURE_SIZE	256
#define	VX_MAX_TRIANGLE		4096
#define	VX_MAX_VERTEX		2048
#define	VX_MAX_BATCH		64

; maths ;

#define VX_MPI_FP8            804
#define VX_MPI_FP16           205887

#define VX_QW                 $0
#define VX_QX                 $3
#define VX_QY                 $6
#define VX_QZ                 $9

; depth test ;

#define VX_DEPTH_TEST         $01
#define VX_DEPTH_BITS         24
#define VX_DEPTH_BUCKET       $D03200 ; 512 bytes of buckets
#define VX_DEPTH_MIN          0
#define VX_DEPTH_MAX          16777215

; texture ;

#define	VX_RLE_COMPRESSED	%01000000
#define	VX_TEXTURE
#define	VX_ERROR_NOT_FOUND	$FF
#define	VX_ERROR_RAM_FULL	$FE

#define	VX_CACHE_MEMORY       $E10010

; stuff ;

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

#define  vxPlaneBit0             %10000000
#define  vxPlaneBit1             %01000000
#define  vxPlaneBit2             %00100000
#define  vxPlaneBit3             %00010000
#define  vxPlaneBit4             %00001000
#define  vxVertexDirty           %11111111
#define  VX_CLIP_EPSILON         64
#define  VX_MAX_TMP_VERTEX       8
#define  VX_MAX_PATCH_SIZE       16
#define  VX_SCREEN_WIDTH         320
#define  VX_SCREEN_HEIGHT        240
#define  VX_SCREEN_WCENTER       160
#define  VX_SCREEN_HCENTER       120

; static variables ;

; macro ;

#define madd.f		       madd2()
#define madd                 __imadd_src_()
#define slhl                 __islhl_src_()
#define .align               align(

.addinstr  ld a,hlu 3BF133E5 4
.addinstr  ld a,deu 3BF133D5 4
.addinstr  ld a,(hl+) 000000 3 NOP 1
.addinstr  ld (hl+),a 000000 3 NOP 1

; Fused multiply and add macro
; madd [bc,a,hl]
; Do hl = (bc x a) + hl
; bc:16bits, a:8bits, hl:24bits, accumulated on 24 bits
; From 114 to 124 TStates on 4 wait-states RAM [114,117,121,124]
; From 090 to 95 TStates on 3 wait-states RAM [090,91,94,95]
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
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ex	de, hl
	add	hl, de
	add	hl, de
	mlt	bc
	add	hl, bc
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
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ex	de, hl
	add	hl, de
	add	hl, de
; ok, that was fast !
#endmacro

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

#ifdef	VX_DEBUG
	#define break scf\sbc hl, hl\ld (hl), 2
#else
	#define break
#endif

.list

; global compilation variable ;

#endif