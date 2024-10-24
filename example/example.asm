include	"include/fasmg/ez80.inc"
include	"include/fasmg/tiformat.inc"
include	"include/ti84pceg.inc"

define	VX_DEBUG_CC_INSTRUCTION

format	ti executable archived 'V3DALPHA'

Main:

.init:
	ld	hl, VertexName0
	call	find
	ret	c
	ld	(Vertex0), hl

	ld	hl, TriangleName0
	call	find
	ret	c
	ld	(Triangle0), hl

; 	ld	hl, VertexName1
; 	call	find
; 	ret	c
; 	ld	(Vertex1), hl
; 
; 	ld	hl, TriangleName1
; 	call	find
; 	ret	c
; 	ld	(Triangle1), hl
		
; 	ld	hl, Skybox.name
; 	call	find
; 	ret	c
; 	ld	(Skybox.cache), hl
	
	ld	hl, TextName
	call	find
	ret	c
	ld	(Texture), hl
	
	ld	hl, MipName
	call	find
	ret	c
	ld	(Mipmap), hl
	
; init the virtual 3d library (please init after OS issue)
	call	vxMemory.layout
	ret	c		; quit if error at init

	ld	hl, (Texture)
	ld	a, VX_IMAGE_ZX7_COMPRESSED
	ld	de, VX_TEXTURE
	call	vxImage.copy
	
	ld	hl, (Mipmap)
	ld	a, VX_IMAGE_ZX7_COMPRESSED
	ld	de, VX_TEXTURE_MIPMAP
	call	vxImage.copy

; about vertex coordinate :
; the format inputed in glib is pure integer 16 bits coordinates, ]-32768,32768[
; A 1.0 coordinate in blender is equivalent to 256 in glib

; setup global variable for rendering, euler angle and the translation of WorldMatrix

; about translation :
; translation are added post transformation. So they carry the multiplication with the matrice, which aren't divided by the fixed point value of 1.0 (the matrix equivalent or 64). To have a translation of 1.0 in worldview matrix, the translation need to be 256*64 = 16384.
; However, there is two type of matrix in glib : the model matrix, which is in MODELSPACE and the world type matrix in WORLDSPACE. Modelspace matrix have only a 16 bits translation and doesn't have the 64 factor described previously.

	ld	hl, 0
	ld	(EulerAngle), hl
	ld	hl, WorldMatrix
	call	vxMatrix.load_identity

	ld	a, 15
	ld	(vxLightUniform+3), a
	ld	a, 0
	ld	(vxLightUniform+4), a

; 	ld	ix, vxPixelShader.alpha
; 	call	vxShader.compile
; 	ret	c
; 	ld	(material1+VX_MATERIAL_PIXEL_SHADER), hl

; 	ld	ix, vxPixelShader.lightning
; 	call	vxShader.compile
; 	ret	c
; 	ld	(material0+VX_MATERIAL_PIXEL_SHADER), hl
	
	ld	hl, material0
	ld	a, VX_MATERIAL0
	call	vxMaterial.load
	
	ld	hl, material1
	ld	a, VX_MATERIAL1
	call	vxMaterial.load

MainLoop:
	call	vxTimer.reset

	call	Camera
	ret	nz
	
; 	ld	hl, 0*256+128
; 	ld	de, 0*256+160
; 	ld	bc, 32*256+32
; 	call	vxImageSub.swap
; 	ld	hl, 128*256+128
; 	ld	de, 128*256+160
; 	ld	bc, 32*256+32
; 	call	vxImageSub.swap
; 
; 	ld	hl, 64*256+192
; 	ld	de, 64*256+224
; 	ld	bc, 32*256+32
; 	call	vxImageSub.swap
; 	ld	hl, 192*256+192
; 	ld	de, 192*256+224
; 	ld	bc, 32*256+32
; 	call	vxImageSub.swap	
 
	ld	ix, WorldMatrix
	ld	iy, ModelMatrix
	ld	hl, (Vertex0)
	ld	de, (Triangle0)
	ld	a, VX_MATERIAL0
	call	vxPrimitiveStream
	
; 	ld	ix, WorldMatrix
; 	ld	iy, ModelMatrix
; 	ld	hl, (Vertex1)
; 	ld	de, (Triangle1)
; 	ld	a, VX_MATERIAL1
; 	call	vxPrimitiveStream

;	ld	a, VX_GEOMETRY_TI9
;	ld	ix, WorldMatrix
;	ld	iy, BossMatrix
;	ld	bc, VX_VERTEX_BUFFER+(1024*16)
;	ld	hl, VERTEXDATA
;	ld	de, TRIDATA
;	call	vxGeometryQueue

;	ld	a, VX_GEOMETRY_TI9
;	ld	ix, WorldMatrix
;	ld	iy, LaraMatrix
;	ld	bc, VX_VERTEX_BUFFER+(1536*16)
;	ld	hl, VERTEXDATA1
;	ld	de, TRIDATA1
;	call	vxGeometryQueue

	ld	hl, (vxPrimitiveQueueSize)
	ld	(debug.visible_count), hl
	ld	iy, (Triangle0)
	ld	hl, (iy+VX_STREAM_HEADER_COUNT)
; 	ld	iy, (Triangle1)
; 	ld	de, (iy+VX_STREAM_HEADER_COUNT)
; 	add	hl, de
	ld	(debug.triangle_count), hl

	call	vxPrimitiveDepthSort
	
;	ld	c, 11100000b
;	call	vxClearBuffer
	call	vxFramebufferClear
;	ld	bc, (EulerAngle)
;	inc	b
;	call	Skybox.render
	
	call	vxPrimitiveSubmit

	call	debug.display_panel

; ; apply filter
; 	ld	a, (posY+1)
; 	rla
; 	sbc	hl, hl
; 	ld	a, (posY+1)
; 	ld	h, a
; 	ld	a, (posY)
; 	ld	l, a
; ; if posY >= $180, apply water palette
; 	ld	de, $17F
; 	or	a, a
; 	sbc	hl, de
; 	jp	p, .water
; 	call	Filter.apply_air
; 	jr	.end
; .water:
; 	call	Filter.apply_water_caustic
; .end:

	call	vxFramebufferSwap

	jp	 MainLoop
	ret

Filter:

.generate:
	call	vxFramebufferResetPalette
	ld	hl, VX_LCD_PALETTE
	ld	de, .PALETTE_AIR
	ld	bc, 512
	ldir
; now generate the water palette, apply a 	
; 144 blue, 128 green, 0 red at 50% alpha
; 1555 format
	ld	hl, .PALETTE_AIR
	ld	ix, .PALETTE_CAUSTIC_WATER
	ld	b, 0
.lloop:
	push	bc
	ld	de, (hl)
	ld	a, e
	and	a, 00011111b
	add	a, 168/8		; blue
	rra
	and	a, 00011111b
	ld	c, a
	rr	d
	rr	e
	rr	d
	rr	e
	ld	a, e
	and	a, 11111000b
	add	a, (132/8)*8			; green
	rra
	and	a, 11111000b
	ld	b, a
	
	ld	a, d
	and	a, 00011111b
	add	a, 0			; red
	rra
	and	a, 00011111b
	rlca
	rlca
	ld	d, a
	ld	a, b
	rlca
	rlca
	and	a, 00000011b
	or	a, d
	ld	d, a
	ld	a, b
	rlca
	rlca
	and	a, 11100000b
	or	a, c
	ld	e, a
	set	7, d
	ld	(ix+0), de
	lea	ix, ix+2
	inc	hl
	inc	hl	
	pop	bc
	djnz	.lloop
	ret

.SWITCH:
 db	0
;8001
.apply_water_caustic:
; adapt the palette for water filter
; palette already set
	ld	hl, .SWITCH
	ld	a, (hl)
	rla
	ret	c
	set	7, (hl)
	ld	hl, .PALETTE_CAUSTIC_WATER
	jp	vxFramebufferSetPalette

.apply_air:
	ld	hl, .SWITCH
	ld	a, (hl)
	rla
	ret	nc
	res	7, (hl)
; restore the correct palette color
	ld	hl, .PALETTE_AIR
	jp	vxFramebufferSetPalette
	
.PALETTE_CAUSTIC_WATER:
 rb	512
 db	0
 db	0
.PALETTE_AIR:
 rb	512

Skybox:
.render:
; get angle, between 0 - 511 : bc
; hl *320 / 512 + modulo
	ld	h, 160
	ld	a, b
	and	a, 1
	ld	l, a
	mlt	hl
	ld	b, 160
	mlt	bc
	ld	c, b
	ld	b, 0
	add	hl, bc
; hl = the offset into the skybox (pseudo rotation)
	push	hl
	pop	ix
	ld	de, (vxFramebuffer)	
	ld	hl, (.cache)
	ld	a, 160
.loop:
	push	af
; copy hl to de + ix for bc = 320 - ix then the following to de for ix
	push	hl
	lea	bc, ix+0
	ld	hl, 320
	or	a, a
	sbc	hl, bc
	ld	b, h
	ld	c, l
	pop	hl
	jr	z, .loop_en0
	push	de
	ex	de, hl
	push	bc
	lea	bc, ix+0
	add	hl, bc
	pop	bc
	ex	de, hl
	ldir
; copy hl > de for bc size
	pop	de
.loop_en0:
	lea	bc, ix+0
	ld	a, b
	or	a, c
	jr	z, .loop_en1
	push	de
	ldir
	pop	de
.loop_en1:
	ex	de, hl
	ld	bc, 320
	add	hl, bc
	ex	de, hl
	pop	af
	dec	a
	jr	nz, .loop
	ld	hl, $E40000
	ld	bc, 320*80
	ldir
	ret

.name:
	db	ti.AppVarObj, "SKYBOX0",0
.cache:
	dl	0

include	"lib/virtual.asm"
include	"font/font.asm"
include	"debug.asm"

material0:
	db	VX_FORMAT_TEXTURE
	dl	VX_VERTEX_BUFFER
	dl	vxVertexShader.ftransform
	dl	vxVertexShader.uniform
	dl	vxPixelShader.texture
	dl	vxPixelShader.uniform

material1:
	db	VX_FORMAT_TEXTURE
	dl	VX_VERTEX_BUFFER+16384
	dl	vxVertexShader.ftransform
	dl	vxVertexShader.uniform
	dl	vxPixelShader.texture
	dl	vxPixelShader.uniform
	
posX:
	dl	(0*256-128)*64
posY:
	dl	(-1*256)*64
posZ:
	dl	(0*256-128)*64

Temp:
	dl	0,0

VertexName0:
	db	ti.AppVarObj, "KALIYAV",0
Vertex0:
	dl	0
TriangleName0:
	db	ti.AppVarObj, "KALIYAF", 0
Triangle0:
	dl	0
	
; VertexName1:
; 	db	ti.AppVarObj, "POOL1V",0
; Vertex1:
; 	dl	0
; TriangleName1:
; 	db	ti.AppVarObj, "POOL1F", 0
; Triangle1:
; 	dl	0	
	
TextName:
	db	ti.AppVarObj, "KALIYAT",0
Texture:
	dl	0
MipName:
	db	ti.AppVarObj, "KALIYAM",0
Mipmap:
	dl	0
UnitVector:
	dl	0,16384,0
Quaternion:
	dl	0,0,0,0
QuatMatrix:
	dl	0,0,0,0,0,0
WorldMatrix:
	dl	0,0,0,0,0,0
ModelMatrix:
	db	64,0,0
	db	0,64,0
	db	0,0,64
	dl	0,0,0
BossMatrix:
	db	64,0,0
	db	0,64,0
	db	0,0,64
	dl	128,64,128
LaraMatrix:
	db	-64,0,0
	db	0,64,0
	db	0,0,-64
	dl	-1024,64,128
EulerAngle:
	dl	0,0,0
texture_frame:
	dl	0

Camera:
	ld hl,$F50000 
	ld (hl),2
	xor a,a
kwait:
	cp a,(hl)
	jr nz,kwait

	ld	de, 8
	ld	a, ($F5001E)
	bit	1, a
	jr	z, _kskip
	ld	hl, (EulerAngle)
	add	hl, de
	ld	(EulerAngle), hl
_kskip:
	ld	de, -8
	ld	a, ($F5001E)
	bit	2, a
	jr	z, _kskip2
	ld	hl, (EulerAngle)
	add	hl, de
	ld	(EulerAngle), hl
_kskip2:

	ld	hl, WorldMatrix
	call	vxMatrix.load_identity

	ld	hl, (EulerAngle)
	ld	iy, Quaternion
	ld	ix, UnitVector
	call	vxQuaternion.rotation_axis
	ld	ix, WorldMatrix
	call	vxQuaternion.get_matrix

	ld	a, ($F5001E)
	bit	0, a
	jr	z, _kskip3

	ld	de, (posX)
	ld	a, (WorldMatrix+6)
	rla
	sbc	hl, hl
	rra
	ld	h, a
	or	a, a
	add	hl, de
	ld	de, (posY)
	ld	(posX), hl
	ld	a, (WorldMatrix+7)
	rla
	sbc	hl, hl
	rra
	ld	h, a
	or	a, a
	add	hl, de
	ld	de, (posZ)
;	ld	(posYt), hl
	ld	(posY), hl
	ld	a, (WorldMatrix+8)
	rla
	sbc	hl, hl
	rra
	ld	h, a
	or	a, a
	add	hl, de
;	ld	(posZt), hl
	ld	(posZ), hl
_kskip3:

	ld	a, ($F5001E)
	bit	3, a
	jr	z, _kskip4

	ld	de, (posX)
	ld	a, (WorldMatrix+6)
	neg
	rla
	sbc	hl, hl
	rra
	ld	h, a
	or	a, a
	add	hl, de
	ld	(posX), hl
	ld	de, (posY)
	ld	a, (WorldMatrix+7)
	neg
	rla
	sbc	hl, hl
	rra
	ld	h, a
	or	a, a
	add	hl, de
	ld	(posY), hl
	ld	de, (posZ)
	ld	a, (WorldMatrix+8)
	neg
	rla
	sbc	hl, hl
	rra
	ld	h, a
	or	a, a
	add	hl, de
	ld	(posZ), hl
_kskip4:

	ld	hl, (posY)
	ld	de, 32*64
	ld	a, ($F50012)
	bit	0, a
	jr	z, _kskip6
	add	hl, de
_kskip6:	

	bit	4, a
	jr	z, _kskip7
	or	a, a
	sbc	hl, de
_kskip7:
	
	ld	(posY), hl

; #comment
; 	call	GetHeightMap
; 
; 	ld	(smc_write), hl
; 	ld	de, (posY)
; 	or	a, a
; 	sbc.s	hl, de
; 	jp	p, _change
; 	ld.s	bc, 129
; 	or	a, a
; 	adc.s	hl, bc
; 	jp	m, _nochange
; _change:
; 	ld	hl, posXt
; 	ld	de, posX
; 	ld	bc, 6
; 	ldir
; smc_write=$+1
; 	ld	hl, 0
; 	ld	a, l
; 	ld	(posY), a
; 	ld	a, h
; 	ld	(posY+1), a
; _nochange:
; #endcomment
	ld	ix, WorldMatrix
	ld	iy, posX
	call	vxMatrix.ftransform
	ld	hl, vxPosition
	ld	de, WorldMatrix+9
	ld	bc, 9
	ldir

	ld a,($F5001C)
	bit 6,a
	ret

; GetHeightMap:
; ; posY, pos, posZ
; 	ld	a, (posZt+1)
; 	cpl
; 	ld	l, a
; 	ld	h, 24
; 	mlt	hl
; 	ld	de, RoomMap
; 	add	hl, de
; 	ld	a, (posXt+1)
; 	cpl
; 	ld	de, 0
; 	ld	e, a
; 	add	hl, de
; 	add	hl, de
; 	ld	bc, (hl)
; 	ld	hl, -256
; 	sbc.s	hl, bc
; 	ret
; RoomMap:
; 	dw	4096,4096,4096,4096,4096,4096,4096,4096,4096,4096,4096,4096
; 	dw	4096,4096,4096,4096,4096,64,4096,4096,4096,4096,4096,4096
; 	dw	4096,4096,0,0,0,0,0,0,0,0,64,4096
; 	dw	4096,192,0,128,64,0,256,192,64,0,64,4096
; 	dw	4096,192,0,192,0,0,0,0,0,0,4096,4096
; 	dw	4096,4096,0,256,0,0,0,0,4096,64,4096,4096
; 	dw	4096,4096,0,0,0,0,0,0,0,32,4096,4096
; 	dw	4096,192,0,0,0,0,0,0,0,0,4096,4096
; 	dw	4096,192,0,256,0,256,256,0,0,0,4096,4096
; 	dw	4096,4096,0,256,0,192,0,0,0,128,4096,4096
; 	dw	4096,4096,0,0,0,64,0,0,4096,0,4096,4096
; 	dw	4096,4096,0,0,0,0,0,0,0,0,4096,4096
; 	dw	4096,4096,0,256,0,0,256,0,0,0,4096,4096
; 	dw	4096,4096,0,0,0,0,0,0,0,128,4096,4096
; 	dw	4096,4096,4096,4096,4096,4096,4096,4096,4096,4096,4096,4096


;#include "XML.ez80"
;#include "XML-1.ez80"

find:
; load a file from an appv
; hl : file name
; hl = file adress
; if error : c set, a = error code
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	ret	c
	call	ti.ChkInRam
	ex	de,hl
	jr	z, unarchived
; 9 bytes - name size (1b), name string, appv size (2b)
	ld	de, 9
	add	hl, de
	ld	e, (hl)
	add	hl, de
	inc	hl
unarchived:
	inc	hl
	inc	hl
	ret
