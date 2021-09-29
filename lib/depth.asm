; Virtual-3D library, version 1.0
;
; MIT License
; 
; Copyright (c) 2017 - 2021 TheMachine02
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; depth sorting routine
; use a n optimized bucket sort algorithm with bucket filling happening at assembly time
; the key is (16 bits depth - 8 bits material) with a back to front sorting

; set the depth offset of the current primitive stream
vxPrimitiveDepthOffset:
	ld	de, VX_DEPTH_OFFSET
	add	hl, de
	ld	(vxPrimitiveDepth), hl
	ret

vxPrimitiveDepthSort:
; 311 cycles per triangle with an added constant ~34000 cycles
; sorting a full queue take less than 27 ms
	cce	ge_z_sort
	ld	hl, VX_PRIMITIVE_SORT_COPY
	ld	de, VX_PRIMITIVE_SORT_CODE
	ld	bc, VX_PRIMITIVE_SORT_SIZE
	ldir
	ld	bc, .restore_rel_size
	ld	hl, .restore_rel
	ld	de, VX_VRAM_CACHE
	ldir
	ld	bc, (vxPrimitiveQueueSize)
	ld	a, b
	or	a, c
	call	nz, .helper
	ccr	ge_z_sort
	ret

; sort table, target temporary buffer based on current framebuffer
; we need two 6*4096 bytes buffer aligned within 64K. Both buffer need to be aligned and not cross boundary
; framebuffer : $D40000
;	- tmp 0 : $D40000
;	- tmp 1 : $D46000
; framebuffer : $D52C00
; 	- tmp 0 : $D52C00
;	- tmp 1 : $D58C00
	
VX_PRIMITIVE_SORT_COPY:=$
; relocate to fast RAM
relocate VX_PRIMITIVE_SORT_CODE

.helper:
; sort the current submission queue
	ld	(.SP_RET), sp
.setup:
; fetch the high byte of the current framebuffer and build up the VRAM temporary area
	ld	ix, .sort
	ld	hl, (vxFramebuffer)
	ld	(ix+.WBL -.sort), hl
	ld	(ix+.WBLH-.sort), h
	ld	(ix+.WBLL-.sort), l
	ld	de, VX_MAX_TRIANGLE*VX_GEOMETRY_SIZE
	add	hl, de
	ld	(ix+.WBH -.sort), hl
	ld	(ix+.WBHH-.sort), h
	ld	(ix+.WBHL-.sort), l
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	add	hl, bc
	ld	(ix+.RBH -.sort), hl
	sbc	hl, de
	ld	(ix+.RBL -.sort), hl
; size computation
	ld	a, c
	dec	bc
	inc	b
	ld	c, b
	ld	b, a
	ld	(ix+.SZ0 -.sort), bc
	ld	(ix+.SZ1 -.sort), bc
	ld	(ix+.SZ2 -.sort), bc
; actual sorting start here
; restore index position in array for all three bucket
.restore_bucket_l:
	ld	hl, VX_DEPTH_BUCKET_L + 511
	ld	a, (hl)
.WBHH:=$+1
	add	a, $CC
	ld	d, a
	ld	(hl), a
	dec	h
	ld	a, (hl)
.WBHL:=$+1
	add	a, $CC
	ld	e, a
	ld	(hl), a
	call	.restore_bucket
; high bucket
.restore_bucket_h:
	ld	hl, VX_DEPTH_BUCKET_H + 511
	ld	a, (hl)
.WBLH:=$+1
	add	a, $CC
	ld	d, a
	ld	(hl), a
	dec	h
	ld	a, (hl)
.WBLL:=$+1
	add	a, $CC
	ld	e, a
	ld	(hl), a
	call	.restore_bucket
; upper bucket
.restore_bucket_u:
	ld	hl, VX_DEPTH_BUCKET_U + 511
	ld	d, (hl)
	dec	h
	ld	e, (hl)
	call	.restore_bucket
.sort:
; sorting now, backward
; set sp as stride, we'll use hl' as return adress within the jump
	ld	sp, -3
.sort_bucket_l:
.SZ0:=$+1
	ld	bc, $CCCCCC
.WBH:=$+1
	ld	de, $CCCCCC
	ld	ix, (vxPrimitiveQueue)
	ld	hl, VX_DEPTH_BUCKET_L
	exx
	ld	hl, .sort_bucket_h
	exx
	jp	.sort_bucket
.sort_bucket_h:
	ld	hl, .sort_bucket_u
	exx
.SZ1:=$+1
	ld	bc, $CCCCCC
; we have sort on the low key, now sort on the high key
;	ld	a, VX_GEOMETRY_DEPTH + 1
; load iyh instead of iyl
	ld	a, $7C
	ld	(.DOF), a
.WBL:=$+1
	ld	de, $CCCCCC
.RBH:=$+2
	ld	ix, $CCCCCC
; load up VX_DEPTH_BUCKET_H
	inc	h
	inc	h
	jp	.sort_bucket
.sort_bucket_u:
; copying take ~250 cycles, so we need to sort >10 triangles to be better than not copying. In practise, this is always true.
	ld	hl, .sort_bucket_rw_overwrite
	ld	de, .sort_bucket_overwrite
	ld	bc, VX_VRAM_CACHE_SIZE shr 1
	ldir
	exx
; finish by the sorting the upper key, and storing partial result within the geometry queue
.SZ2:=$+1
	ld	bc, $CCCCCC
	ld	de, VX_GEOMETRY_QUEUE
.RBL:=$+2
	ld	ix, $CCCCCC
; load up VX_DEPTH_BUCKET_U
	inc	h
	inc	h
	jp	.sort_bucket
.sort_bucket_rw:
	lea	ix, ix-VX_GEOMETRY_SIZE
.sort_bucket_rw_overwrite:
	ld	l, (ix+VX_GEOMETRY_DEPTH+2)
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	dec	de
	ex	de, hl
; copy 4 (VX_GEOMETRY_KEY_SIZE) bytes
	ld	a, (ix+VX_GEOMETRY_ID)
	ld	(hl), a
	add	hl, sp
	ld	iy, (ix+VX_GEOMETRY_INDEX)
	ld	(hl), iy
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	djnz	.sort_bucket_rw
	dec	c
	jr	nz, .sort_bucket_rw
.SP_RET:=$+1
	ld	sp, $CCCCCC
	ret

VX_PRIMITIVE_SORT_SIZE:= $ - VX_PRIMITIVE_SORT_CODE
end relocate

.restore_rel:
relocate VX_VRAM_CACHE
.restore_bucket:
	dec	l
.restore_add:
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	dec	l
	jr	nz, .restore_add
	ld	c, (hl)
	inc	h
	ld	b, (hl)
	ex	de, hl
	add	hl, bc
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	ret
.sort_bucket:
	lea	ix, ix-VX_GEOMETRY_SIZE
.sort_bucket_overwrite:
	ld	iy, (ix+VX_GEOMETRY_DEPTH)
.DOF:=$+1
	ld	a, iyl
	ld	l, a
	ld	e, (hl)
	inc	h
	ld	d, (hl)
	ex	de, hl
	add	hl, sp
	ld	(hl), iy
	add	hl, sp
	ld	iy, (ix+VX_GEOMETRY_INDEX)
	ld	(hl), iy
	ex	de, hl
	ld	(hl), d
	dec	h
	ld	(hl), e
	djnz	.sort_bucket
	dec	c
	jr	nz, .sort_bucket
	exx
	jp	(hl)
.restore_rel_size:= $ - VX_VRAM_CACHE
assert .restore_rel_size <= VX_VRAM_CACHE_SIZE
end relocate 
