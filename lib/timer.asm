#define	VX_TIMER_CTRL	$F20030
#define	VX_TIMER_COUNT	$F20000

vxTimerInit:
; now intialise and start the timer (1)
	ld	hl, VX_TIMER_CTRL
	ld	a, (hl)
; CPU clock, not enable, count up
	and	a, 11111000b
	ld	(hl), a
	inc	l
	set	1, (hl)
; reset the value
vxTimerReset:
	push	hl
	ld	hl, VX_TIMER_COUNT
	ld	(hl), h
	inc	l
	ld	(hl), h
	inc	l
	ld	(hl), h
	inc	l
	ld	(hl), h
	ld	l, $30
	pop	hl
	ret
vxTimerStart:
	ld	hl, VX_TIMER_CTRL
; start timer
	set	0, (hl)
	ret
vxTimerRead:
	ld	hl, VX_TIMER_CTRL
; stop the timer
	res	0, (hl)
; read 24 bits value in the counter register
	ld	hl, VX_TIMER_COUNT
	ld	de, (hl)
	ld	l, 3
	ld	a, (hl)
; full 32bits value is now ade
	ret
