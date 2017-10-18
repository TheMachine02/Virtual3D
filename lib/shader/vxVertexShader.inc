; cache data register (de) ;

#define	VX_VERTEX_CODE		0
#define	VX_VERTEX_SY		1
#define	VX_VERTEX_SX		2
#define	VX_VERTEX_GPR0		4
#define	VX_VERTEX_GPR1		5
#define	VX_VERTEX_UNIFORM	6
#define	VX_VERTEX_RX		7
#define	VX_VERTEX_RY		10
#define	VX_VERTEX_RZ		13

; vertex input register (iy) ;

#define	VX_VERTEX_POSITION	0
#define	VX_VERTEX_VX		0
#define	VX_VERTEX_VY		2
#define	VX_VERTEX_VZ		4
#define	VX_VERTEX_NORMAL		6
#define	VX_VERTEX_NX		6
#define	VX_VERTEX_NY		7
#define	VX_VERTEX_NZ		8

; global data input register (ix) ;

#define	VX_MATRIX0			0
#define	VX_MATRIX0_C0		0
#define	VX_MATRIX0_C1		1
#define	VX_MATRIX0_C2		2
#define	VX_MATRIX0_C3		3
#define	VX_MATRIX0_C4		4
#define	VX_MATRIX0_C5		5
#define	VX_MATRIX0_C6		6
#define	VX_MATRIX0_C7		7
#define	VX_MATRIX0_C8		8
#define	VX_MATRIX0_TX		9
#define	VX_MATRIX0_TY		12
#define	VX_MATRIX0_TZ		15

#define	VX_LIGHT0_VECTOR	18
#define	VX_LIGHT0_AMBIANT	21
#define	VX_LIGHT0_POW		22
#define	VX_LIGHT0_POSITION	23

; constant ;

#define	VX_MATRIX_SIZE		18
#define	VX_MATRIX_C0		0
#define	VX_MATRIX_C1		1
#define	VX_MATRIX_C2		2
#define	VX_MATRIX_C3		3
#define	VX_MATRIX_C4		4
#define	VX_MATRIX_C5		5
#define	VX_MATRIX_C6		6
#define	VX_MATRIX_C7		7
#define	VX_MATRIX_C8		8
#define	VX_MATRIX_TX		9
#define	VX_MATRIX_TY		12
#define	VX_MATRIX_TZ		15

#define	VX_LIGHT_SIZE		11
#define	VX_LIGHT_VECTOR		0
#define	VX_LIGHT_AMBIANT	3
#define	VX_LIGHT_POW		4
#define	VX_LIGHT_POSITION	5

#define	VX_VERTEX_SIZE		16	; per vertex data in pipeline
#define	VX_VERTEX_DATA_SIZE	9	; this should be changed if you suppress vertex normal data

#define	VX_VERTEX_SHADER_SIZE		1024	; allowed shader size
#define	VX_VERTEX_SHADER_DATA		$E30800
#define	VX_VERTEX_SHADER_CODE		$E30800

; return shader ;

; shader will copy 1024 bytes from global_data to VX_VRAM. This load occurs at begin of stream instruction, to ensure maximum vertex throughput. About 2200 cycles per vertex are needed.

VX_VERTEX_SHADER_COPY:

; relocate the shader to fast VRAM ($E30800)

.relocate VX_VERTEX_SHADER_CODE

vxModelView:
	.db	0,0,0
	.db	0,0,0
	.db	0,0,0
	.dl	0,0,0
vxLight:
	.db	0,0,0
	.db	0,0
	.dw	0,0,0

; global shader call

vxVertexShader:
; ix = global data register [MC[0-8],MTX,MTY,MTZ,LV[0-2],LA,LE]
; iy = vertex data register [VX,VY,VZ,VN[0-2]]
; de = output data register [RC,SY,SX,RI[0-1],RX,RY,RZ]
; bc = x vertex coordinate [16bits]
; OUT register
; de = de + VX_VERTEX_SIZE
; iy = iy + VX_VERTEX_DATA_SIZE
; data copied to memory
	pea	iy+VX_VERTEX_DATA_SIZE
	push	de
; X coordinate
;	ld	bc, (iy+0)
	ld	de, (ix+VX_MATRIX0_TX)
	ld	a, (ix+VX_MATRIX0_C0)
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+VX_MATRIX0_C1)
	or	a, a
	jr	z, vxVertexSkip0
	ld	bc, (iy+VX_VERTEX_VY)
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
vxVertexSkip0:
	ld	a, (ix+VX_MATRIX0_C2)
	ld	bc, (iy+VX_VERTEX_VZ)
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	push	hl
; Z coordinate
	ld	de, (ix+VX_MATRIX0_TZ)
	ld	a, (ix+VX_MATRIX0_C8)
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+VX_MATRIX0_C7)
	ld	bc, (iy+VX_VERTEX_VY)
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+VX_MATRIX0_C6)
	ld	bc, (iy+VX_VERTEX_VX)
	ld	d, c
	ld	e, a
	mlt	de
	add	hl, de
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, de
	push	hl
; Y coordinate
	ld	de, (ix+VX_MATRIX0_TY)
	ld	a, (ix+VX_MATRIX0_C3)
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+VX_MATRIX0_C4)
	ld	bc, (iy+VX_VERTEX_VY)
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de
	ld	a, (ix+VX_MATRIX0_C5)
	ld	bc, (iy+VX_VERTEX_VZ)
	ex	de, hl
	ld	h, b
	ld	l, a
	mlt	hl
	cp	$80
	jr	c, $+4
	sbc	hl, bc
	bit	7, b
	ld	b, a
	jr	z, $+5
	cpl
	adc	a, h
	ld	h, a
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	mlt	bc
	add	hl, bc
	add	hl, de

; lightning model is here, infinite directionnal light, no pow
	xor	a, a
	ld	c, (iy+VX_VERTEX_NX)
	ld	b, (ix+VX_LIGHT0_VECTOR+0)
	bit	7, c \ jr z, $+3 \ sub a,b
	bit	7, b \ jr z, $+3 \ sub a,c
	mlt	bc
	add	a, b
	ld	c, (iy+VX_VERTEX_NY)
	ld	b, (ix+VX_LIGHT0_VECTOR+1)
	bit	7, c \ jr z, $+3 \ sub a,b
	bit	7, b \ jr z, $+3 \ sub a,c
	mlt	bc
	add	a, b
	ld	c, (iy+VX_VERTEX_NZ)
	ld	b, (ix+VX_LIGHT0_VECTOR+2)
	bit	7, c \ jr z, $+3 \ sub a,b
	bit	7, b \ jr z, $+3 \ sub a,c
	mlt	bc
	add	a, b
; max(a,0)
	jp	p, $+5
	xor	a, a
	ld	c, a
	ld	b, (ix+VX_LIGHT0_POW)
	mlt	bc
	ld	a, b
	rl	c
; ambiant lightning=12
	adc	a, (ix+VX_LIGHT0_AMBIANT)
; min(a,31)
	cp	32
	jr	c, $+4
	ld	a, 31
	pop	bc
	pop	de
	pop	iy
	ld	(iy+VX_VERTEX_UNIFORM), a
	ld	(iy+VX_VERTEX_RX), de
	ld	(iy+VX_VERTEX_RY), hl
	ld	(iy+VX_VERTEX_RZ), bc

vxPerspectiveDivide:
	ld	a, (iy+VX_VERTEX_RZ+2)
	rla
	jp	c, vxPerspectiveClipZ
	xor	a, a
	add	hl, hl
	jr	nc, vxPerspectiveAbs0
	rla
	push	de
	ex   de, hl
	sbc   hl, hl
	sbc   hl, de
	pop	de
	or	a, a
vxPerspectiveAbs0:
	sbc	hl, bc
	jr	c, vxPerspectiveNext0
	sbc	hl, bc
	jp	nc, vxPerspectiveClip0
	or	a, a
vxPerspectiveNext0:
	adc	a,a \ add hl,bc
	add	hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add	hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add	hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add	hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add	hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
  	add	hl,hl \ sbc hl,bc \ adc a,a
   	cpl
   	add	a, a
   	ld   l, VX_SCREEN_HEIGHT/2+1 ;precision stuffs
   	ld   h, a
   	mlt	hl
   	ld   a, h
   	jr   nc, $+3
   	cpl
   	adc	a, VX_SCREEN_HCENTER
	ld	(iy+VX_VERTEX_SY), a
	ex	de, hl
	xor	a, a
	add	hl, hl
	jr	nc, vxPerspectiveAbs1
	rla
	ex   de, hl
	sbc   hl, hl
	sbc   hl, de
	or	a, a
vxPerspectiveAbs1:
	sbc	hl, bc
	jr	c, vxPerspectiveNext1
; potential clipping issue
	sbc	hl, bc
	jr	nc, vxPerspectiveClip2
	or	a, a
vxPerspectiveNext1:
   	adc a,a \ add hl,bc
   	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add hl,hl \ sbc hl,bc \ jr nc,$+3 \ add hl,bc \ adc a,a
   	add hl,hl \ sbc hl,bc \ adc a,a
   	cpl
   	ld	l, a
   	ld	h, VX_SCREEN_WIDTH/2+1
   	mlt	hl
   	ld	a, h
   	sbc	hl, hl
   	jr	nc, $+3
   	cpl
   	ld   l, a
	ld   de, VX_SCREEN_WCENTER
	adc   hl, de
	ld	(iy+VX_VERTEX_SX), hl
	xor	a, a
	ld	(iy+VX_VERTEX_CODE), a
	lea	de, iy+VX_VERTEX_SIZE
	pop	iy
	ret
vxPerspectiveCode:
	xor	a, a
	bit	7,(iy+VX_VERTEX_RZ+2)
	jr	z, $+4
vxPerspectiveClipZ:
	ld	a, %00001000
vxPerspectiveClip0:
	ld	hl, (iy+VX_VERTEX_RY)
	or	a, a
	sbc	hl, bc
	jp	m, vxPerspectiveClip1
	or	%00100000
vxPerspectiveClip1:
	add	hl, bc
	or	a, a
	adc	hl, bc
	jp	p, vxPerspectiveClip2
	or	%00010000
vxPerspectiveClip2:
; y cliping was handled
	ld	hl, (iy+VX_VERTEX_RX)
	or	a, a
	sbc	hl, bc
	jp	m, vxPerspectiveClip3
	or	a, %10000000
vxPerspectiveClip3:
	add	hl, bc
	or	a, a
	adc	hl, bc
	jp	p, vxPerspectiveClip4
	or	a, %01000000
vxPerspectiveClip4:
; x clipping handled
	and	%11111000
	ld	(iy+VX_VERTEX_CODE), a
	lea	de, iy+VX_VERTEX_SIZE
	pop	iy
	ret
.endrelocate