; Virtual-3D library, version 1.0
;
; Copyright (c) 2020 TheMachine02

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

include	"vsl.inc"

define	OS__FLAGS	$D00080
; standard defines ;
define	VX_VERSION	$10
define	VX_TRUE		$01
define	VX_FALSE	$00

define	NULL_RAM	$E40000

; geometry ;

; mesh ;

; maths ;

; RAM and VRAM ;

; color LCD ;

; batch ;

; depth test ;

; texture ;

; limits ;

; static variables ;

macro align bound
 rb bound-($ mod bound)
end macro

macro relocate addr
	oorg = $
	norg = addr
	org	addr
end macro

macro endrelocate
	org	$ - norg + oorg
end macro

define	nan	0

; functions

vxEngine:
	jp	vxEngineEnd

vxEngineInit:
; get indic off
	call	ti.RunIndicOff
; disable interrupts
	di
	ld	a, $D0
	ld	MB, a
	ld	hl, $E00005
	ld	(hl), 2	; Set flash wait states to 5 + 2 = 7 (total access time = 8)
	call	ti.boot.ClearVRAM
; LCD init
	call	vxFramebufferSetup
; memory initialisation
	call	vxMemoryCreateDevice
;	call	vxMemoryUnlockPrivilege
; data initialisation
	ld	hl, VX_LUT_CONVOLVE_DATA
	ld	de, VX_LUT_CONVOLVE
	ld	bc, VX_LUT_CONVOLVE_SIZE
	ldir
	ld	hl, VX_LUT_SIN_DATA
	ld	de, VX_LUT_SIN
	ld	bc, VX_LUT_SIN_SIZE
	ldir
	ld	hl, NULL_RAM
	ld	de, VX_DEPTH_BUCKET_L
	ld	b, 6	; 6*256 (3*512)
	ldir
	ld	hl, NULL_RAM
	ld	de, VX_VERTEX_BUFFER
	ld	bc, VX_MAX_VERTEX * VX_VERTEX_SIZE
	ldir
; various other data
	ld	hl, VX_FRAMEBUFFER_AUX1
	ld	(vxSubmissionQueue), hl
	ld	(vxGeometrySize), bc
	ld	hl, $D30000
	ld	(vxTexturePage), hl
; load shader
	ld	ix, vxPixelShader
	call	vxShaderLoad
; init timer
	call	vxTimer.init
; insert stack position
	ld	hl, vxEngineQuit
	ex	(sp), hl
	jp	(hl)
vxEngineQuit:
;	call	vxMemoryLockPrivilege
	ld	hl, $F50000
	ld	(hl), h	; Mode 0
	inc	l		; 0F50001h
	ld	(hl), 15	; Wait 15*256 APB cycles before scanning each row
	inc	l		; 0F50002h
	ld	(hl), h
	inc	l		; 0F50003h
	ld	(hl), 15	; Wait 15 APB cycles before each scan
	inc	l		; 0F50004h
	ld	(hl), 8	; Number of rows to scan
	inc	l		; 0F50005h
	ld	(hl), 8	; Number of columns to scan
	ld	iy, OS__FLAGS
	call	vxFramebufferRestore
	call	vxMemoryDestroyDevice
	ld	hl, $E00005
	ld	(hl), 4	; Set flash wait states to 5 + 4 = 9 (total access time = 10)
	call	ti.HomeUp
	call	ti.ClrScrn
	call	ti.DrawStatusBar
	call	ti.RunIndicOn
	ei
	jp	ti.DrawBatteryIndicator

; memory backing function
	
vxMemoryCreateDevice:
	call	vxMemoryUnlock
	ld	a, $3F
	call	vxMemorySafeErase
	ld	a, $3E
	call	vxMemorySafeErase
	ld	a, $3D
	call	vxMemorySafeErase
	ld	a, $3C
	call	vxMemorySafeErase
	ld	hl, $D00000
	ld	(hl), $5A
	inc	hl
	ld	(hl), $A5
	dec	hl
	ld	de, $3C0000
	ld	bc, $40000
	jp	ti.WriteFlash
; 	jp	vxMemoryLock
vxMemorySafeErase:
	ld	bc,$0000F8
	push	bc
	jp	ti.EraseFlashSector

vxMemoryDestroyDevice:
; restore RAM state
	ld	hl, $3C0000
	ld	de, $D00000
	ld	bc, $01887C
	ldir
; sps, spl stack aren't copied obviously
	ld	hl, $3DA881
	ld	de, $D1A881
	ld	bc, $02577F
	ldir
	ret

vxMemoryUnlock:
	ld	bc, $24
	ld	a, $8c
	call	_inner_write
	ld	bc, $06
	call	_inner_read
	or	a, 4
	call	_inner_write
	ld	bc, $28
	ld	a, $4
	jr	_inner_write
vxMemoryLock:
	ld	bc, $28
	xor	a, a
	call	_inner_write
	ld	bc, $06
	call	_inner_read
	res	2, a
	call	_inner_write
	ld	bc, $24
	ld	a, $88
	jr	_inner_write	
vxMemoryUnlockPrivilege:
	ld	bc, $28
	ld	a, $4
	jr	_inner_write
vxMemoryLockPrivilege:
	ld	bc, $28
	xor	a, a
_inner_write:
	ld	de, $C979ED
	ld	hl, $D1887C - 3
	ld	(hl), de
	jp	(hl)
_inner_read:
	ld	de, $C978ED
	ld	hl, $0D1887C - 3
	ld	(hl), de
	jp	(hl)
	
; include texture, clipping, color
include	"primitive.asm"
include	"pipeline.asm"
include	"image.asm"
include	"shader.asm"
include	"timer.asm"
include	"matrix.asm"
include	"quaternion.asm"
include	"vector.asm"
include	"framebuffer.asm"
include	"material.asm"
include	"assembly.asm"
include	"math.asm"
include	"mipmap.asm"
; various LUT
include	"data.inc"

vxEngineEnd:
