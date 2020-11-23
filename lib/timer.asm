define	VX_TIMER_CTRL	$F20030
define	VX_TIMER_COUNTER_GP	$F20000
define	VX_TIMER_COUNTER_FR	$F20010
define	RAM_NULL	$E40000

macro	cce	register			; cycle counter enable
if defined VX_DEBUG_CC_INSTRUCTION
	ld	(vxTimer.register_save), hl
	ld	hl, VX_TIMER_COUNTER_GP
	ld	(hl), h
	inc	hl
	ld	(hl), h
	inc	hl
	ld	(hl), h
	inc	hl
	ld	(hl), h
	ld	l, VX_TIMER_CTRL and $FF
; start timer
	set	0, (hl)
	ld	hl, (vxTimer.register_save)
end if
end macro

macro	ccr	register			; cycle counter read
if defined VX_DEBUG_CC_INSTRUCTION
	ld	(vxTimer.register_save), hl
	ld	hl, VX_TIMER_CTRL
; stop timer
	res	0, (hl)
	ld	l, VX_TIMER_COUNTER_GP and $FF
	ld	de, (hl)
	ld	hl, (register)
	add	hl, de
	ld	(register), hl
	ld	hl, (vxTimer.register_save)
end if
end macro

ge_vtx_transform:
 dl	0
ge_pri_transform:
 dl	0
ge_pri_clip:
 dl	0
ge_pxl_raster:
 dl	0
ge_pxl_shading:
 dl	0
ge_z_sort:
 dl	0
fb_clear:
 dl	0
 
vxTimer:

.register_save:
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
	ld	hl, RAM_NULL
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
