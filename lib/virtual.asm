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

include	"vsl.inc"

define	VIRTUAL_BASE_RAM		$D00000
define	VIRTUAL_VERSION			$10
define	VIRTUAL_NULL_RAM		$E40000

define	VX_VRAM_CACHE			$E10010
define	VX_VRAM_CACHE_SIZE		64
define	VX_VRAM				$E30800
define	VX_VRAM_SIZE			1024

define	VX_MEMORY_HINT_TRIS_TEXTURE	0
define	VX_MEMORY_HINT_TRIS_FLAT	1
define	VX_MEMORY_HINT_QUADS_TEXTURE	2
define	VX_MEMORY_HINT_QUADS_FLAT	4
define	VX_MEMORY_HINT_FLASH		8
define	VX_MEMORY_HINT_VRAM		16
define	VX_MEMORY_HINT_AUTO		32

; NOTE : memory map of the LUT and various data is here
virtual at VIRTUAL_BASE_RAM
	include 'bss.asm'
end virtual

macro	hint?	value
	ld	a, (VIRTUAL_PIPELINE_STATE)
	and	a, value
end	macro

macro	exa
	ex	af, af'
end	macro

; functions
vxMemory:

.layout:
; get indic off
	call	ti.RunIndicOff
	call	ti.boot.ClearVRAM
; disable interrupts
	di
	ld	a, $D0
	ld	MB, a
; memory setup
	ld	hl, $E00005
; Set flash wait states to 5 + 3 = 8 (total access time = 9)
	ld	(hl), 3
	call	.open_port
	di
	ld	hl, $D00000
	ld	(hl), $5A
	inc	hl
	ld	(hl), $A5
	dec	hl
; dangerous, but needed
	call	.unlock_flash
	ld	a, $3F
	call	.safe_erase
	ld	a, $3E
	call	.safe_erase
	ld	a, $3D
	call	.safe_erase
	ld	a, $3C
	call	.safe_erase
	ld	hl, VIRTUAL_BASE_RAM
	ld	de, $3C0000
	ld	bc, $40000
	call	ti.WriteFlash
	call	.lock_flash
; we have locked flash here, so now unlock sha256
; unlock SHA256 (port setup is still valid)
	call	.unlock_sha256
	ld	hl, VIRTUAL_NULL_RAM
	ld	de, VX_VRAM_CACHE
	ld	bc, 64
	ldir
; memory initialisation
	call	vxFramebufferSetup
	ld	de, VIRTUAL_BASE_RAM
	ld	hl, .arch_image
	call	lz4.decompress
	ld	hl, VIRTUAL_NULL_RAM
	ld	de, VX_DEPTH_BUCKET_L
	ld	bc, 1536
	ldir
; reset vertex poison code
	ld	de, VX_VERTEX_BUFFER
	ld	bc, VX_MAX_VERTEX * VX_VERTEX_SIZE
	ldir
; various other data
	ld	hl, VX_FRAMEBUFFER_AUX1
	ld	(vxPrimitiveQueue), hl
	ld	(vxPrimitiveQueueSize), bc
	ld	hl, $D30000
	ld	(vxTexturePage), hl
; init pixel shader
	call	vxShader.init
; init timer
	call	vxTimer.init
; insert stack position; reset vertex poison code

	ld	hl, .restore
	ex	(sp), hl
	jp	(hl)

.safe_erase:
	di
	ld	bc,$0000F8
	push	bc
	jp	ti.EraseFlashSector

.arch_image:
file	'ram'

.restore:
	ld	iy, _OS_FLAGS
	call	vxFramebufferRestore
; restore the OS
	di
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
; relock SHA256, port setup has been restored by destroy device (or should be)
;	call	.open_port
	call	.lock_sha256
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
	ld	hl, $E00005
	ld	(hl), 4	; Set flash wait states to 5 + 4 = 9 (total access time = 10)
	call	ti.HomeUp
	call	ti.ClrScrn
	call	ti.DrawStatusBar
	call	ti.RunIndicOn
	ei
	jp	ti.DrawBatteryIndicator

.hint:
; hint for memory auto-opt
	ld	c, a
	ld	a, (VIRTUAL_PIPELINE_STATE)
	or	a, c
; check auto mod
	ld	(VIRTUAL_PIPELINE_STATE), a
	and	a, VX_MEMORY_HINT_AUTO
	ret	z
; compute auto and write it
	ret
	
.open_port:=port_setup
.lock_flash:=port_lock
.unlock_flash:=port_unlock
.lock_sha256:=port_privilege_lock
.unlock_sha256:=port_privilege_unlock

; core of the library
include	"assembly.asm"
include	"depth.asm"
include	"framebuffer.asm"
include	"quaternion.asm"
include	"material.asm"
include	"matrix.asm"
include	"mipmap.asm"
include	"pipeline.asm"
include	"primitive.asm"
include	"image.asm"
include	"shader.asm"
include	"timer.asm"
include	"vector.asm"
; default optimized shader
include	"shader/vertex.asm"
include	"shader/texture.asm"
include	"shader/gouraud.asm"
include	"shader/alpha.asm"
include	"shader/lightning.asm"
; helper
include	"ports.asm"
include	"lz4.asm"
include	"math.asm"
