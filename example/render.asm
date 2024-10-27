include	"include/fasmg/ez80.inc"
include	"include/fasmg/tiformat.inc"
include	"include/ti84pceg.inc"

define	VX_DEBUG_CC_INSTRUCTION

format	ti executable archived 'RENDER'

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

	ld	hl, TextName
	call	find
	ret	c
	ld	(Texture), hl
	
	
; init the virtual 3d library (please init after OS issue)
	call	vxMemory.layout
	ret	c		; quit if error at init

	ld	hl, (Texture)
	ld	a, VX_IMAGE_ZX7_COMPRESSED
	ld	de, VX_TEXTURE
	call	vxImage.copy
	

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
	

MainLoop:
	call	vxTimer.reset

	call	Camera
	ret	nz
	 
	call	Render
	 
	ld	hl, (vxPrimitiveQueueSize)
	ld	(debug.visible_count), hl

	call	vxPrimitiveDepthSort
	
;	ld	c, 11100000b
;	call	vxClearBuffer
 	call	vxFramebufferClear
;	ld	bc, (EulerAngle)
;	inc	b
;	call	Skybox.render
	
	call	vxPrimitiveSubmit

	call	debug.display_panel

	call	vxFramebufferSwap

	jp	 MainLoop
	ret

include	"lib/virtual.asm"
include	"font/font.asm"
include	"debug.asm"

material0:
	db	VX_FORMAT_TEXTURE
.cache:
	dl	VX_VERTEX_BUFFER
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
	db	ti.AppVarObj, "HOMEV",0
Vertex0:
	dl	0
TriangleName0:
	db	ti.AppVarObj, "HOMEF", 0
Triangle0:
	dl	0
		
TextName:
	db	ti.AppVarObj, "HOMET",0
Texture:
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
EulerAngle:
	dl	0,0,0

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

Render:
	or	a, a
	sbc	hl, hl
	ld	(debug.triangle_count), hl
	ld	hl, VX_VERTEX_BUFFER
	ld	(material0.cache), hl
	ld	a, VX_MATERIAL0
	ld	(material_current), a
	ld	hl, (Vertex0)
	ld	a, (hl)
	ld	hl, (Triangle0)
	cp	a, (hl)
	ret	nz
	ld	b, a

.room_list:
	push	bc
	
	ld	hl, material0
	ld	a, (material_current)
	call	vxMaterial.load
	
	pop	bc
	push	bc
; get the triangle & vertex data
	ld	hl, 0
	ld	l, c
	add	hl, hl
	add	hl, hl
	inc	hl
	ld	de, (Triangle0)
	add	hl, de
	ld	hl, (hl)
	add	hl, de
	ex	de, hl
; vertex data
	ld	hl, 0
	ld	l, c
	add	hl, hl
	add	hl, hl
	inc	hl
	ld	bc, (Vertex0)
	add	hl, bc
	ld	hl, (hl)
	add	hl, bc
	push	hl

	ld	bc, (material0.cache)
	inc	hl
	ld	hl, (hl)
	inc.s	hl
	dec.s	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	ld	(material0.cache), hl
; 	pop	hl
; 	
; 	push	hl
	push	de
	push	bc
	ex	de, hl
	inc	hl
	ld	bc, (hl)
	ld	hl, (debug.triangle_count)
	add	hl, bc
	ld	(debug.triangle_count), hl
		
	pop	bc
	pop	de
	pop	hl
	
	ld	a, (material_current)
	ld	ix, WorldMatrix
	ld	iy, ModelMatrix
	
	call	vxPrimitiveStream

	ld	a, (material_current)
	add	a, VX_MATERIAL_SIZE
	ld	(material_current), a
	pop	bc
	inc	c
	djnz	.room_list
	ret

dataRoomIndex:
	dl	0
dataRoomVertex:
	dl	0
material_current:
	db	0
