; functions

vxEngine:
	jp	__end

vxEngineInit:
; get indic off
	call	_RunIndicoff
; disable interrupts
	di
	ld	hl, 0E00005h
	ld	(hl), 2	; Set flash wait states to 5 + 2 = 7 (total access time = 8)
; LCD initialisation
	call	vxResetPalette
; start LCD interrupt
	call	_boot_ClearVRAM
	ld	hl, VX_LCD_IMSC
	set	2, (hl)
; setup 8bpp mode
	ld	a, VX_BPP8
	ld	(VX_LCD_CTRL), a
; load vram buffer
	ld	hl, VX_FRAMEBUFFER_AUX0
	ld	(VX_LCD_BUFFER), hl
	ld	hl, VX_FRAMEBUFFER_AUX1	;used to be 1
	ld	(vxFramebuffer), hl
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
	ld	hl, VX_DEPTH_BUCKET
	ld	de, VX_DEPTH_BUCKET+1
	ld	(hl), c
	inc	b
	dec	c
	ldir
; various other data
	ld	hl, VX_FRAMEBUFFER_AUX1
	ld	(vxSubmissionQueue), hl
	ld	hl, VX_BATCH_DATA-4
	ld	(vxGeometryBatchID), hl
	ld	(vxGeometrySize), bc
	ld	hl, $D30000
	ld	(vxTexturePage), hl
; load shader
	ld	ix, vxPixelShader
	call	vxShaderLoad
; init timer
	call	vxTimerInit
; insert stack position
	ld	hl, vxEngineQuit
	ex	(sp), hl
	jp	(hl)
vxEngineQuit:
;	call	vxMemoryLockPrivilege
	ld	a, $D0
	.db	$ED,$6D	; ld mb,a
	ld hl,$F50000
	ld (hl),h	; Mode 0
	inc l		; 0F50001h
	ld (hl),15	; Wait 15*256 APB cycles before scanning each row
	inc l		; 0F50002h
	ld (hl),h
 	inc l		; 0F50003h
	ld (hl),15	; Wait 15 APB cycles before each scan
	inc l		; 0F50004h
	ld (hl),8	; Number of rows to scan
	inc l		; 0F50005h
	ld (hl),8	; Number of columns to scan
	ld iy, OS__FLAGS
	ld a, VX_BPP16
	ld (VX_LCD_CTRL),a
	ld	hl, VX_FRAMEBUFFER_AUX0
	ld	(VX_LCD_BUFFER), hl
	call	vxMemoryDestroyDevice
	ld	hl, 0E00005h
	ld	(hl), 4	; Set flash wait states to 5 + 4 = 9 (total access time = 10)
	call _HomeUp
	call _Clrscrn
	call _DrawStatusBar
	call _RunIndicon
	ei
	jp _DrawBatteryIndicator

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
	ld	hl, $D00001
	ld	(hl), $A5
	dec	hl
	ld	(hl), $5A
	ld	de, $3C0000
	ld	bc, $40000
	jp	__WriteFlash
; 	jp	vxMemoryLock
vxMemorySafeErase:
	ld	bc,$0000F8
	push	bc
	jp	__EraseFlashPage

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
	jp	_inner_write
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
	jp	_inner_write	
vxMemoryUnlockPrivilege:
	ld	bc, $28
	ld	a, $4
	jp	_inner_write
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
#include	"vxPrimitive.asm"
#include	"vxPipeline.asm"
#include	"vxImage.asm"
#include	"vxShaderCore.asm"
#include	"vxTimer.asm"
#include	"vxMatrix.asm"
#include	"vxQuaternion.asm"
#include	"vxVector.asm"
#include	"vxFramebuffer.asm"
; various LUT
#include	"vxData.inc"

__end:
