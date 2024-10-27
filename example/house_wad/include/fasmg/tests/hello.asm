include 'ez80.inc'
include 'ti84pceg.inc'
include 'tiformat.inc'
format ti executable 'HELLO'

	or	a, a
	sbc	hl, hl
	ld	(curRow), hl
	ld	hl, hello
	call	_PutS
	jp	_NewLine

hello db "Hello", 0
