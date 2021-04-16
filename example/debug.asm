; generic nice debug functions

debug:
.display_frame:
	call	vxTimer.read
	ld	bc, .frame_ms
	ld	hl, 0
	call	.display_timer
	jr	.display_triangle

.display_panel:
	call	vxTimer.read
	ld	bc, .frame_ms
	ld	hl, 0
	call	.display_timer
	ld	bc, .ge_vtx
	ld	hl, 256
	ld	de, (ge_vtx_transform)
	xor	a, a
	call	.display_timer
	ld	bc, .ge_pri
	ld	hl, 512
	ld	de, (ge_pri_assembly)
	xor	a, a
	call	.display_timer
	ld	bc, .ge_clip
	ld	hl, 768
	ld	de, (ge_pri_clip)
	xor	a, a
	call	.display_timer
	ld	bc, .ge_zsort
	ld	hl, 1024
	ld	de, (ge_z_sort)
	xor	a, a
	call	.display_timer
	ld	bc, .ge_raster
	ld	hl, 1024+256
	ld	de, (ge_pxl_raster)
	xor	a, a
	call	.display_timer
	ld	bc, .ge_pxl
	ld	hl, 1024+512
	ld	de, (ge_pxl_shading)
	xor	a, a
	call	.display_timer
.display_triangle:
; display visible triangle count
.visible_count:=$+1
	ld	bc, 0
	ld	a, 4
	ld	hl, 16
	ld	ix, $00FF00
	call	font.glyph_integer_format
	ld	hl, 20
	ld	bc, .tri_string
	ld	ix, $00FF00
	call	font.glyph_string
; compute the number of triangle per frame
; 1000/ ms * triangle_count
.triangle_count:=$+1
	ld	hl, 0
; *1024
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	hl
	call	.frame_time
	ex	(sp), hl
	pop	bc
	call	__idivs
	push	hl
	pop	bc
; hl = total / s	
	ld	a, 6
	ld	hl, 29
	ld	ix, $00F000
	call	font.glyph_integer_format
	ld	bc, .tri_s
	ld	hl, 35
	ld	ix, $00F000
	call	font.glyph_string
	ret

.frame_time:
	call	vxTimer.read
	ld	(.tmp), de
	ld	(.tmp+3), a
	ld	hl, (.tmp+1)
; divide de by 187
	ld	bc, 187
	jp	ti._idivu

; bc : string, hl : position, de : counter
.display_timer:
	ld	(.tmp), de
	ld	(.tmp+3), a
	push	hl
	ld	ix, $00FF00
	call	font.glyph_string
	pop	hl
	ld	bc, 8
	add	hl, bc
	push	hl
	ld	de, (.tmp+1)
; divide de by 187
	ex	de, hl
	ld	bc, 187
	call	__idivs
	ld	a, 4
	push	hl
	pop	bc
	pop	hl
	push	hl
	ld	ix, $00FF00
	call	font.glyph_integer_format
	pop	hl
	ld	bc, 4
	add	hl, bc
	ld	bc, .ms_string
	ld	ix, $00FF00
	jp	font.glyph_string

.tmp:
 dl	0,0
.ms_string:
 db " ms ",0
.tri_string:
 db " visible ", 0
.tri_s:
 db " tri/s", 0 
.frame_ms:
 db " timing ", 0
; timer name
.ge_vtx:
 db " ge_vtx ", 0
.ge_pri:
 db " ge_asm ", 0
.ge_clip:
 db " ge_clp ", 0
.ge_zsort:
 db " ge_zst ", 0
.ge_raster:
 db " ge_rst ", 0
.ge_pxl: 
 db " ge_pxl ", 0 
