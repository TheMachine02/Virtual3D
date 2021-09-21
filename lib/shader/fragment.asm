define	VX_REGISTER_VRAM	-4
define	VX_REGISTER_LENGTH	-1
define	VX_REGISTER_JP		0

define	VX_REGISTER_VSIZE	8

vxPixelShader:

.uniform:
; from direction vector, adapt
	ret

.fragment:
relocate VX_VRAM_CACHE
.fragment_inner:
; fixed v = v + dv, with on upper byte fixed u = u + du
; then copy integer v into a for passing it through the shadow swap
	add	hl, de
	ld	a, h
	exx
; integer u = u + du + carry
	adc	hl, sp
	ld	h, a
; fetch texture at $DXVVUU and blit it to screen, then advance
	ld	a, (hl)
	ld	(de), a
.IC0:=$+1
	inc	de
	exx
	add	hl, de
	ld	a, h
	exx
	adc	hl, sp
	ld	h, a
	ld	a, (hl)
	ld	(de), a
.IC1:=$+1
	inc	de
	exx
	djnz	.fragment_inner
; per-span fragment setup
; exactly 30 bytes, 99 cycles (counting out bound jp $ and fetch within normal RAM)
; advance in register file
; register format :
; iy+0, jp $000000 (also end marker)
; iy+4, length/2 for djnz
; iy+5, screen VRAM adress
; total : 8 bytes
	lea	iy, iy+VX_REGISTER_VSIZE
.fragment_setup:
	exa
; fixed v = v + dv, with u on upper byte
; .DVDY:=$+1
; 	ld	bc, $CC
; we only need to reload b (bc load DVDY)
.DVDY_H:=$+1
	ld	b, $CC
	add	ix, bc
	lea	hl, ix+0
	exx
; a is the u integer part, copy it to hl'
.DUDY:=$+1
	adc	a, $CC
; NOTE : we need to reset the v integer part to zero, else if previous v was < 255
; we might overflow into $dx and completely destroy our poor texture sampler
; reset both the upper byte which is the texture with mbase and h with zero
	ld	hl, i
	ld	l, a
	exa
; case vrs=1 : we need the first texel value in span to be loaded in register a (since we will exx / ld (de),a / inc de / exx and possibly on the first pixel (also; LENGHT : jp : $00 $00 $00 if size = 1, directly write ?)
; 	ld	a, ixh
; 	ld	h, a
; 	ld	a, (hl)
; screen adress
	ld	de, (iy+VX_REGISTER_VRAM)
; offseting to account interpolating from left or right (later inside setup code)
.SOF:=$+1
	nop
	exx
; iy point to an in LUT jp to the correct area
	ld	b, (iy+VX_REGISTER_LENGTH)
	jp	(iy)
.fragment_size:= $-VX_VRAM_CACHE
assert	.fragment_size <= VX_VRAM_CACHE_SIZE
end	relocate

.edge:
relocate VX_VRAM_CACHE
.edge_inner:
	exx
	exa
	add	a, c
	adc	hl, de
	ld	(iy+VX_REGISTER_VRAM), hl
	add	a, c
	adc	hl, de
	ld	(iy+VX_REGISTER_VRAM), hl
	exa
	exx
	add	a, c
	jr	nc, $+3
	add	hl, sp
	add	hl, de
	ld	bc, (hl)
	ld	(iy+VX_REGISTER_LENGTH), bc
	add	a, c
	jr	nc, $+3
	add	hl, sp
	add	hl, de
	ld	bc, (hl)
	ld	(iy+VX_REGISTER_LENGTH), bc
	lea	iy, iy+VX_REGISTER_SIZE*2
	djnz	.edge_inner
	jp	$CCCCCC
.edge_size:= $-VX_VRAM_CACHE
assert	.edge_size <= VX_VRAM_CACHE_SIZE
end	relocate
; around 66 cycles per span + the 99 cycles in the inner fragment setup

; setup
.edge_setup:
; we need to compute the delta's
; (x2-x0)/(y2-y0) : x2-x0 is between -320 and + 320, check the two bit low bit of d to switch the value accordingly
; we get a 16.8 delta's hopefully (16.0 * 0.16 > 16.8)
