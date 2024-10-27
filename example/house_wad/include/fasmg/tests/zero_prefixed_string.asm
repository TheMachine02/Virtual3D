include 'ez80.inc'

virtual
	db 42,10 dup ?
 load value: $-$$ from $$
end virtual

	ld	a,value
	ld	hl,value
	ld	(ix+value),value
	out	(value),a
	in	a,(value)
