include 'ez80.inc'

	ldp	a, bc, (ix + 10)
	ldrp	(ix - 10), de, c
	ldp	bc, de, 123456787654321
	ldrp	e, hl, 3.14159265
