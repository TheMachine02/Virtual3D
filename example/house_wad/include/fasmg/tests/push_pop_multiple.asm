include 'ez80.inc'
	push     af
	push.sis bc, de
	push.lis hl, ix, iy
	push.s   ix - $80, iy + $7f, ix + $7F, iy - $80
	pop.sil  iy, ix, hl
	pop.lil  de, bc
	pop      af
