#define	VX_SIGNED_MATRIX_SIZE   21
#define	VX_SIGNED_MATRIX_C0		0
#define	VX_SIGNED_MATRIX_C1		1
#define	VX_SIGNED_MATRIX_C2		2
#define VX_SIGNED_MATRIX_SM0    3
#define	VX_SIGNED_MATRIX_C3		4
#define	VX_SIGNED_MATRIX_C4		5
#define	VX_SIGNED_MATRIX_C5		6
#define VX_SIGNED_MATRIX_SM1    7
#define	VX_SIGNED_MATRIX_C6		8
#define	VX_SIGNED_MATRIX_C7		9
#define	VX_SIGNED_MATRIX_C8		10
#define VX_SIGNED_MATRIX_S2     11
#define	VX_SIGNED_MATRIX_TX		12
#define	VX_SIGNED_MATRIX_TY		15
#define	VX_SIGNED_MATRIX_TZ		18

#define VX_SIGNED_VECTOR_SIZE   7
#define	VX_SIGNED_VECTOR_WX		0
#define	VX_SIGNED_VECTOR_WY		2
#define	VX_SIGNED_VECTOR_WZ		4
#define VX_SIGNED_VECTOR_S      6

vxFMAEngine:

vxFMAinit:
; ix is an 8 bit signed vector, iy is a 16 bit signed vector
; 99 (-4) cycles >> total 291 cycles min (+24 worst 315)+ jump or call (inline // not)
    ld  a, (iy+VX_SIGNED_VECTOR_SM)
    xor a, (ix+VX_SIGNED_MATRIX_SM0)
    sbc hl, hl
    ld  l, a
    add hl, hl
    ld  de, _inner_engine000
    add hl, de
    ld  de, (ix+VX_SIGNED_MATRIX_C0)
    ld  a, (ix+VX_SIGNED_MATRIX_C2)
    jp  (hl)
    
_inner_engine000:
; 192 cycles
    ld  l, e
    ld  h, (iy+VX_SIGNED_VECTOR_WX+1)
    mlt hl
    ld  b, (iy+VX_SIGNED_VECTOR_WY+1)
    ld  c, d
    mlt bc
    add hl, bc
    ld  b, (iy+VX_SIGNED_VECTOR_WZ+1)
    ld  c, a
    mlt bc
    add hl, bc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld  b, (iy+VX_SIGNED_VECTOR_WX)
    ld  c, e
    mlt bc
    add hl, bc
    ld  e, (iy+VX_SIGNED_VECTOR_WY)
    mlt de
    add hl, de
    ld  b, (iy+VX_SIGNED_VECTOR_WZ)
    ld  c, a
    mlt bc
    add hl, bc
    ret
    
    //PADING ++
    
_inner_engine001:    
    ld  l, e
    ld  h, (iy+VX_SIGNED_VECTOR_WX+1)
    mlt hl
    ld  b, (iy+VX_SIGNED_VECTOR_WY+1)
    ld  c, d
    mlt bc
    add hl, bc
    ld  b, (iy+VX_SIGNED_VECTOR_WZ+1)
    ld  c, a
    mlt bc
    sbc hl, bc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld  b, (iy+VX_SIGNED_VECTOR_WX)
    ld  c, e
    mlt bc
    add hl, bc
    ld  e, (iy+VX_SIGNED_VECTOR_WY)
    mlt de
    add hl, de
    ld  b, (iy+VX_SIGNED_VECTOR_WZ)
    ld  c, a
    mlt bc
    or  a, a
    sbc hl, bc
    ret
    
_inner_engine010:    
    ld  l, e
    ld  h, (iy+VX_SIGNED_VECTOR_WX+1)
    mlt hl
    ld  b, (iy+VX_SIGNED_VECTOR_WY+1)
    ld  c, d
    mlt bc
    sbc hl, bc
    ld  b, (iy+VX_SIGNED_VECTOR_WZ+1)
    ld  c, a
    mlt bc
    add hl, bc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld  b, (iy+VX_SIGNED_VECTOR_WX)
    ld  c, e
    mlt bc
    add hl, bc
    ld  e, (iy+VX_SIGNED_VECTOR_WY)
    mlt de
    or  a, a
    sbc hl, de
    ld  b, (iy+VX_SIGNED_VECTOR_WZ)
    ld  c, a
    mlt bc
    add hl, bc
    ret
    
_inner_engine100:    
    ld  h, (iy+VX_SIGNED_VECTOR_WZ+1)
    ld  l, a
    mlt hl
    ld  c, e
    ld  b, (iy+VX_SIGNED_VECTOR_WX+1)
    mlt bc
    sbc hl, bc
    ld  b, (iy+VX_SIGNED_VECTOR_WY+1)
    ld  c, d
    mlt bc
    add hl, bc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld  b, (iy+VX_SIGNED_VECTOR_WX)
    ld  c, e
    mlt bc
    or  a, a
    sbc hl, bc
    ld  e, (iy+VX_SIGNED_VECTOR_WY)
    mlt de
    add hl, de
    ld  b, (iy+VX_SIGNED_VECTOR_WZ)
    ld  c, a
    mlt bc
    add hl, bc    
    ret
    
_inner_engine110:    
    ld  h, (iy+VX_SIGNED_VECTOR_WZ+1)
    ld  l, a
    mlt hl
    ld  c, e
    ld  b, (iy+VX_SIGNED_VECTOR_WX+1)
    mlt bc
    sbc hl, bc
    ld  b, (iy+VX_SIGNED_VECTOR_WY+1)
    ld  c, d
    mlt bc
    or  a, a
    sbc hl, bc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld  b, (iy+VX_SIGNED_VECTOR_WX)
    ld  c, e
    mlt bc
    or  a, a
    sbc hl, bc
    ld  e, (iy+VX_SIGNED_VECTOR_WY)
    mlt de
    or  a, a
    sbc hl, de
    ld  b, (iy+VX_SIGNED_VECTOR_WZ)
    ld  c, a
    mlt bc
    add hl, bc
    ret
    
_inner_engine011:    
    ld  l, e
    ld  h, (iy+VX_SIGNED_VECTOR_WX+1)
    mlt hl
    ld  b, (iy+VX_SIGNED_VECTOR_WY+1)
    ld  c, d
    mlt bc
    sbc hl, bc
    ld  b, (iy+VX_SIGNED_VECTOR_WZ+1)
    ld  c, a
    mlt bc
    or  a, a
    sbc hl, bc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld  b, (iy+VX_SIGNED_VECTOR_WX)
    ld  c, e
    mlt bc
    add hl, bc
    ld  e, (iy+VX_SIGNED_VECTOR_WY)
    mlt de
    or  a, a
    sbc hl, de
    ld  b, (iy+VX_SIGNED_VECTOR_WZ)
    ld  c, a
    mlt bc
    or  a, a
    sbc hl, bc
    ret
    
_inner_engine101:    
    ld  h, (iy+VX_SIGNED_VECTOR_WY+1)
    ld  l, d
    mlt hl
    ld  c, e
    ld  b, (iy+VX_SIGNED_VECTOR_WX+1)
    mlt bc
    sbc hl, bc
    ld  b, (iy+VX_SIGNED_VECTOR_WZ+1)
    ld  c, a
    mlt bc
    or  a, a
    sbc hl, bc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld  b, (iy+VX_SIGNED_VECTOR_WX)
    ld  c, e
    mlt bc
    or  a, a
    sbc hl, bc
    ld  e, (iy+VX_SIGNED_VECTOR_WY)
    mlt de
    add hl, de
    ld  b, (iy+VX_SIGNED_VECTOR_WZ)
    ld  c, a
    mlt bc
    or  a, a
    sbc hl, bc
    ret

_inner_engine111:    
    ld  l, e
    ld  h, (iy+VX_SIGNED_VECTOR_WX+1)
    mlt hl
    ld  b, (iy+VX_SIGNED_VECTOR_WY+1)
    ld  c, d
    mlt bc
    add hl, bc
    ld  b, (iy+VX_SIGNED_VECTOR_WZ+1)
    ld  c, a
    mlt bc
    add hl, bc
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld  b, (iy+VX_SIGNED_VECTOR_WX)
    ld  c, e
    mlt bc
    add hl, bc
    ld  e, (iy+VX_SIGNED_VECTOR_WY)
    mlt de
    add hl, de
    ld  b, (iy+VX_SIGNED_VECTOR_WZ)
    ld  c, a
    mlt bc
    add hl, bc
    ex  de, hl
    sbc hl, hl
    sbc hl, de
    ret 
