define	VX_SIGNED_MATRIX_SIZE		21
define	VX_SIGNED_MATRIX_C0		0
define	VX_SIGNED_MATRIX_C1		1
define	VX_SIGNED_MATRIX_C2		2
define	VX_SIGNED_MATRIX_SM0		3
define	VX_SIGNED_MATRIX_C3		4
define	VX_SIGNED_MATRIX_C4		5
define	VX_SIGNED_MATRIX_C5		6
define	VX_SIGNED_MATRIX_SM1		7
define	VX_SIGNED_MATRIX_C6		8
define	VX_SIGNED_MATRIX_C7		9
define	VX_SIGNED_MATRIX_C8		10
define	VX_SIGNED_MATRIX_SM2		11
define	VX_SIGNED_MATRIX_TX		12
define	VX_SIGNED_MATRIX_TY		15
define	VX_SIGNED_MATRIX_TZ		18
define	VX_SIGNED_VECTOR_SIZE		7
define	VX_SIGNED_VECTOR_WX		0
define	VX_SIGNED_VECTOR_WY		2
define	VX_SIGNED_VECTOR_WZ		4
define	VX_SIGNED_VECTOR_SM		6

vxfma_copy:

relocate VX_VERTEX_SHADER_CODE

vxModelView:
 db    0,0,0,0
 db    0,0,0,0
 db    0,0,0,0
 dl    0,0,0
vxLight:
 db    0,0,0
 db    0,0,0
 dw    0,0,0

vxfma:
	ld	ix, VX_VERTEX_SHADER_DATA
	push	de
	
	ld	ixl, vxfma_trampoline_0
	ld	a, (iy+VX_SIGNED_VECTOR_SM)
	xor	a, (ix+VX_SIGNED_MATRIX_SM0 - vxfma_trampoline_0)
	ld	hl, .engine_000 shr 1
	ld	l, a
	add	hl, hl
	ld	de, (ix+VX_SIGNED_MATRIX_C0 - vxfma_trampoline_0)
	ld	a, (ix+VX_SIGNED_MATRIX_C2 - vxfma_trampoline_0)
	jp	(hl)
vxfma_trampoline_0:= $ and $FF
	ld	de, (ix+VX_SIGNED_MATRIX_TX - vxfma_trampoline_1)
	add	hl, de
	push	hl

	ld	ixl, vxfma_trampoline_1
	ld	a, (iy+VX_SIGNED_VECTOR_SM)
	xor	a, (ix+VX_SIGNED_MATRIX_SM1 - vxfma_trampoline_1)
	ld	hl, .engine_000 shr 1
	ld	l, a
	add	hl, hl
	ld	de, (ix+VX_SIGNED_MATRIX_C3 - vxfma_trampoline_1)
	ld	a, (ix+VX_SIGNED_MATRIX_C5 - vxfma_trampoline_1)
	jp	(hl)
vxfma_trampoline_1:= $ and $FF
	ld	de, (ix+VX_SIGNED_MATRIX_TY - vxfma_trampoline_1)
	add	hl, de
	push	hl

	ld	ixl, vxfma_trampoline_2
	ld	a, (iy+VX_SIGNED_VECTOR_SM)
	xor	a, (ix+VX_SIGNED_MATRIX_SM2 - vxfma_trampoline_2)
	ld	hl, .engine_000 shr 1
	ld	l, a
	add	hl, hl
	ld	de, (ix+VX_SIGNED_MATRIX_C6 - vxfma_trampoline_2)
	ld	a, (ix+VX_SIGNED_MATRIX_C8 - vxfma_trampoline_2)
; carry will be reset when jumping
	jp	(hl)
vxfma_trampoline_2:= $ and $FF
	ld	de, (ix+VX_SIGNED_MATRIX_TZ - vxfma_trampoline_2)
	add	hl, de
	
; 
; 
; ; ix is an 8 bit signed vector, iy is a 16 bit signed vector
; ; 99 (-4) cycles >> total 291 cycles min (+24 worst 315)+ jump or call (inline // not)
; 	ld	a, (iy+VX_SIGNED_VECTOR_SM)
; 	xor	a, (ix+VX_SIGNED_MATRIX_SM0)
; 	ld	hl, .engine_000 shr 1
; 	ld	l, a
; 	add	hl, hl
; 	ld	de, (ix+VX_SIGNED_MATRIX_C0)
; 	ld	a, (ix+VX_SIGNED_MATRIX_C2)
; ; carry will be reset when jumping
; 	jp	(hl)

; 0-0-0
; X-Y-Z
; E-D-A

align 512
.engine_000:
; 192 cycles
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	jp	(ix)

align 64
.engine_001:
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	jp	(ix)
 
align 64
.engine_010:
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	or	a, a
	sbc	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	jp	(ix)
	
align 64
.engine_100:
	ld	h, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	l, a
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	jp	(ix)
	
align 64
.engine_110:
	ld	h, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	l, a
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	or	a, a
	sbc	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	jp	(ix)
 
align 64
.engine_011:
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	or	a, a
	sbc	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	jp	(ix)
 
align 64
.engine_101:
	ld	h, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	l, d
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	c, e
	mlt	bc
	sbc	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	or	a, a
	sbc	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	or	a, a
	sbc	hl, bc
	jp	(ix)

align 64
.engine_111:
	ld	h, (iy+VX_SIGNED_VECTOR_WX+1)
	ld	l, e
	mlt	hl
	ld	b, (iy+VX_SIGNED_VECTOR_WY+1)
	ld	c, d
	mlt	bc
	add	hl, bc
	ld	b, (iy+VX_SIGNED_VECTOR_WZ+1)
	ld	c, a
	mlt	bc
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	b, (iy+VX_SIGNED_VECTOR_WX)
	ld	c, e
	mlt	bc
	add	hl, bc
	ld	e, (iy+VX_SIGNED_VECTOR_WY)
	mlt	de
	add	hl, de
	ld	b, (iy+VX_SIGNED_VECTOR_WZ)
	ld	c, a
	mlt	bc
	add	hl, bc
	ex	de, hl
	sbc	hl, hl
	sbc	hl, de
	jp	(ix) 

endrelocate
