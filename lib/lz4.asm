;
; LZ4 decompression algorithm - Copyright (c) 2011-2015, Yann Collet
; All rights reserved. 
; LZ4 implementation for z80 and compatible processors - Copyright (c) 2013-2015 Piotr Drapich
; All rights reserved.
; LZ4 implementation port and major overhaule for ez80 processor - by TheMachine02
;
; Redistribution and use in source and binary forms, with or without modification, 
; are permitted provided that the following conditions are met: 
; 
; * Redistributions of source code must retain the above copyright notice, this 
;   list of conditions and the following disclaimer. 
; 
; * Redistributions in binary form must reproduce the above copyright notice, this 
;   list of conditions and the following disclaimer in the documentation and/or 
;   other materials provided with the distribution. 
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
; DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
; ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
; ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
; SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 


define	LZ4_VERSION4		4
define	LZ4_VERSION3		3
define	LZ4_VERSION2		2

lz4:

.decompress:
; hl : src, de : dest
; check the magic number
	ld	bc, 1
	ld	a, (hl)
	inc	hl
	sub	a, 2
	jr	z, .version_2_legacy
	dec	a
	jr	z, .version_3_legacy
	dec	a
	jr	z, .version_4
.version_not_supported:
	ld	a,2
	ret
.version_4:
; check version 1.41 magic 
	ld	a, (hl)
	cp	a, $22
	jr	nz, .version_not_supported
	inc	hl
	ld	a, (hl)
	cp	a, $4D
	jr	nz, .version_not_supported
	inc	hl
	ld	a, (hl)
	cp	a, $18
	jr	nz, .version_not_supported
	inc	hl
; parse version 1.41 spec header
	ld	a, (hl)
; check version bits for version 01
	add	a, a
	jr	c, .version_not_supported
	jp	p, .version_not_supported
	inc	hl
; is content size set?
	bit	4, a
	jr	z, .no_content_size
; skip content size
	ld	c, 9
.no_content_size:
	bit	1, a
	jr	z, .no_preset_dictionary
; skip dictionary id
	inc	c
	inc	c
	inc	c
	inc	c
.no_preset_dictionary:
	ld	a, (hl)
; strip reserved bits (and $70)
	and	$40
	jr	z, .version_not_supported
	inc	hl
; skip header checksum
	jr	.start_decompression
.version_3_legacy:
	ld	c, 9
.version_2_legacy:
	ld	a, (hl)
	cp	$21
	jr	nz, .version_not_supported
	inc	hl
	ld	a, (hl)
	cp	$4c
	jr	nz, .version_not_supported
	inc	hl
	ld	a, (hl)
	cp	$18
	jr	nz, .version_not_supported
.start_decompression:
	add	hl, bc
; load low 24 bit of compressed block size to bc
	ld	bc, (hl)
	inc	hl
	inc	hl
	inc	hl
	inc	hl

.decompress_raw:
	push	hl
	add	hl, bc
	ex	(sp), hl
	ld	bc, 0
	jr	.get_token

.matches:
	push	bc
	inc.s	bc
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	inc	hl
	ld	a, iyl
	and	a, $0F
	add	a, 4
	
	push	de
	ex	de, hl
	sbc	hl, bc
	ex	de, hl
	
	ld	b, 0
	cp	a, $13
	jr	nz, .matches_copy
.matches_lisc:
	ld	c, (hl)
	inc	hl
	add	a, c
	jr	nc, $+3
	inc	b
	inc	c
	jr	z, .matches_lisc
.matches_copy:
	ld	c, a
	ex	(sp), hl
	ex	de, hl
	ldir
	pop	hl
.get_token:
	ld	a, (hl)
	inc	hl
	ld	iyl, a
.literals:
; unpack 4 high bits to get the length of literal
	and	a, $F0
	jr	z, .literals_null
	rlca
	rlca
	rlca
	rlca
; copy literals
	cp	a, $0F
	jr	nz, .literals_copy
.literals_lisc:
	ld	c, (hl)
	inc	hl
	add	a, c
	jr	nc, $+3
	inc	b
	inc	c
	jr	z, .literals_lisc
.literals_copy:
	ld	c, a
	ldir
.literals_null:
; check for end of compressed data
	pop	bc
	or	a, a
	sbc	hl, bc
	add	hl, bc
	jr	nz, .matches
.decompress_success:
	ret
