; mipmapping :

vxMipmap:
.generate:
; generate LUT table for mipmapping ?
; 256x256 : lvl 0
; 128x128 : lvl 1, 16K,  start adress = $D2C000
; 64x64   : lvl 2, 4K,   start adress = $D2B000
; 32x32   : lvl 3, 1K,   start adress = $D2AC00
; 16x16   : lvl 4, 256,  start adress = $D2AB00
; 8x8     : lvl 5, 16b,  start adress = $D2AA00
; each texel is the average of the four texel of the precedent level
; we also need to offset the v coordinate by the necessary value
; LUT table does : U >> lvl + U offset and V >> lvl + V offset




.gradient:
; apply LUT table
; scale delta's (y & x)

; float
; mip_map_level(in vec2 texture_coordinate)
; {
;     // The OpenGL Graphics System: A Specification 4.2
;     //  - chapter 3.9.11, equation 3.21
;  
;     vec2  dx_vtc        = dFdx(texture_coordinate);
;     vec2  dy_vtc        = dFdy(texture_coordinate);
;     float delta_max_sqr = max(dot(dx_vtc, dx_vtc), dot(dy_vtc, dy_vtc));
;  
;     //return max(0.0, 0.5 * log2(delta_max_sqr) - 1.0);
;     return 0.5 * log2(delta_max_sqr);
; }
; we'll do this, only take 8 bits of the derivative
; 0,5*log2(max( (dFdxU*dFdxU) + (dFdxV*dFdxV) , (dFdyU*dFdyU)+(dFdyV*dFdyV)))	
	
	
	
	
vxMipmapLevel:
; about 400 cycles more
; get mipmap level from delta's
; log2(min(max(abs(dFdxU),abs(dFdyU)),max(abs(dFdxV),abs(dFdyV)))
	ld	de, (iy+VX_FDUDX)
	bit	7, d
	jr	z, .abs_s0
	xor	a, a
	sub	a, e
	ld	e, a
	sbc	a, a
	sub	a, d
	ld	d, a
.abs_s0:
	ld	hl, (iy+VX_FDUDY)
	bit	7, h
	jr	z, .abs_s1
	xor	a, a
	sub	a, l
	ld	l, a
	sbc	a, a
	sub	a, h
	ld	h, a
.abs_s1:
	ex.s	de, hl
; both abs() are de and hl, compare them
	or	a, a
	sbc	hl, de
	add	hl, de
; if hl > de : p, else m
	jp	p, .cc0
	ex	de, hl
.cc0:
; hl is the lowest of both
; save it for later
	push	hl
	ld	de, (iy+VX_FDVDY)
	bit	7, d
	jr	z, .abs_s2
	xor	a, a
	sub	a, e
	ld	e, a
	sbc	a, a
	sub	a, d
	ld	d, a
.abs_s2:
	ld	hl, (iy+VX_FDVDX)
	bit	7, h
	jr	z, .abs_s3
	xor	a, a
	sub	a, l
	ld	l, a
	sbc	a, a
	sub	a, h
	ld	h, a
.abs_s3:
	ex.s	de, hl
; both abs() are de and hl, compare them
	or	a, a
	sbc	hl, de
	add	hl, de
; if hl > de : nc, else c
	jp	p, .cc1
	ex	de, hl
.cc1:
	pop	de
; compare now de and hl
; keep the lowest
	or	a, a
	sbc	hl, de
	add	hl, de
	jp	p, .cc2
	ex	de, hl
.cc2:
; hl is the lowest
; take log2 of hl (8.8)
	ld	a, h
	ld	hl, VX_LOG_LUT
	ld	l, a
; we got the mipmap level
	ld	a, (hl)
	add	a, 2
; based on mipmap level : we need to scale the delta's to be closer to 1 and scale the starting u & v > LUT table
	ld	(vxShaderUniform0+1), a
.adjust:
	bit	7, (iy+VX_FDVDY+1)
	jr	z, .adj0
	ld	hl, (iy+VX_FDUDY)
	dec.s	hl
	ld	(iy+VX_FDUDY), hl
.adj0:
	bit	7, (iy+VX_FDVDX+1)
	jr	z, .adj1
	ld	hl, (iy+VX_FDUDX)
	dec.s	hl
	ld	(iy+VX_FDUDX), hl
.adj1:
	ret


align 256
VX_LOG_LUT:
 db 0
 db 0
 db 1
 db 1
 db 2
 db 2
 db 2
 db 2
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 3
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 4
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 db 5
 
 rb	64
 TMP:
 rb	64
 