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

define	VX_TIMER_CTRL		$F20030
define	VX_TIMER_COUNTER_GP	$F20000
define	VX_TIMER_COUNTER_FR	$F20010

macro	cce	register			; cycle counter enable, destroy 0
if defined VX_DEBUG_CC_INSTRUCTION
	ld	(vxTimer.rrs), hl
	ld	hl, VX_TIMER_COUNTER_GP
	ld	(hl), h
	inc	hl
	ld	(hl), h
	inc	hl
	ld	(hl), h
	ld	l, VX_TIMER_CTRL and $FF
; start timer
	set	0, (hl)
	ld	hl, (vxTimer.rrs)
end if
end macro

macro	ccr	register			; cycle counter read, destroy de and hl
if defined VX_DEBUG_CC_INSTRUCTION
	ld	hl, VX_TIMER_CTRL
; stop timer
	res	0, (hl)
	ld	l, VX_TIMER_COUNTER_GP and $FF
	ld	de, (hl)
	ld	hl, (register)
	add	hl, de
	ld	(register), hl
end if
end macro

ge_vtx_transform:
 dl	0
ge_pri_assembly:
 dl	0
ge_pri_clip:
 dl	0
ge_pxl_raster:
 dl	0
ge_pxl_shading:
 dl	0
ge_z_sort:
 dl	0
fb_ops:
 dl	0
 
vxTimer:

.rrs:
 dl	0
 
.init:
; now intialise timer (1) (2)
	ld	hl, VX_TIMER_CTRL
	ld	a, (hl)
; CPU clock, not enable, count up
	and	a, 11000000b
	ld	(hl), a
	inc	l
	ld	a, (hl)
	or	a, 00000110b
	ld	(hl), a
; reset all values

; reset the HP timer (also set frame time timer)
.reset:
	push	de
	push	bc
	ld	hl, VX_TIMER_CTRL
	res	0, (hl)
	ld	l, VX_TIMER_COUNTER_GP and $FF
	ex	de, hl
	ld	hl, VIRTUAL_NULL_RAM
	ld	bc, 4
	ldir
	ld	e, VX_TIMER_COUNTER_FR and $FF
	ld	c, 4
	ldir
	ld	de, ge_vtx_transform
	ld	c, 6*3
	ldir
	ld	hl, VX_TIMER_CTRL
	set	3, (hl)
	pop	bc
	pop	de
	ret

; read the HP timer for frame time (FR). We also have correct values within the register file
.read:
	ld	hl, VX_TIMER_CTRL
; stop the timer
	res	3, (hl)
; read 24 bits value in the counter register
	ld	l, VX_TIMER_COUNTER_FR and $FF
	ld	de, (hl)
	ld	l, VX_TIMER_COUNTER_FR and $FF + 3
	ld	a, (hl)
; full 32bits value is now ade
	ret
