include	"include/fasmg/ez80.inc"
include	"include/fasmg/tiformat.inc"
include	"include/ti84pceg.inc"

format	ti executable 'ANIMATE'
define	DELTA	4096
define	VX_DEBUG_CC_INSTRUCTION

Main:

	ld	hl, VertexName
	call	.ressource
	ret	c
	ld	(Vertex), hl

	ld	hl, TriangleName
	call	.ressource
	ret	c
	ld	(Triangle), hl

	ld	hl, TextureName
	call	.ressource
	ret	c
	ld	(Texture), hl
	
; init the virtual 3d library
	call	vxEngineInit
	ret	c		; quit if error at init

	ld	hl, (Texture)
	ld	a, VX_IMAGE_ZX7_COMPRESSED
	ld	de, $D30000
	call	vxImage.copy

; setup global variable for rendering, euler angle and the translation of WorldMatrix

	ld	hl, 0
	ld	(EulerAngle), hl
	ld	(LightAngle), hl

	ld	ix, WorldMatrix
	lea	hl, ix+0
	call	vxMatrixLoadIdentity
	ld	hl, 65536
	ld	(ix+15), hl		; Z translation of the matrix

	ld	hl, Light
	ld	de, vxLightUniform
	ld	bc, VX_LIGHT_SIZE
	ldir

	ld	hl, Material
	ld	a, VX_MATERIAL0
	call	vxMaterialLoad	
	
; ;	ld	ix, lightShader
; 	ld	ix, alphaShader
; ;	ld	ix, gouraudShader
; 	call	vxShaderLoad

	ld	a, 0
	ld	(vxAnimationKey), a

.loop:
	ld	a, (vxAnimationKey)
	inc	a
	and	a, 63
	ld	(vxAnimationKey), a
	call	vxTimer.reset

	ld	hl, (EulerAngle)
	ld	iy, Quaternion
	ld	ix, UnitVector
	call	vxQuaternionRotationAxis
	ld	ix, WorldMatrix
	call	vxQuaternionGetMatrix
; 	lea	iy, ix+0
; 	ld	ix, vxProjectionMatrix
; 	ld	hl, WorldMatrix
; 	call	vxMatrixMlt

	ld	a, VX_MATERIAL0
	ld	ix, WorldMatrix
	ld	iy, ModelMatrix
	ld	hl, (Vertex)
	ld	bc, (Triangle)
	call	vxPrimitiveStream

	ld	hl, (vxGeometrySize)
	ld	(debug.visible_count), hl
	ld	hl, (Triangle)
	inc	hl
	ld	hl, (hl)
	ld	(debug.triangle_count), hl

	call	vxPrimitiveDepthSort
	
	call	vxFramebufferClear
	call	vxPrimitiveSubmit

	call	debug.display_panel

	call	vxFramebufferSwap

.keyboard:
	ld hl,$F50000
	ld (hl),2
	xor a,a
.wait:
	cp a,(hl)
	jr nz, .wait

	ld	de, 8
	ld	a, ($F5001E)
	bit	1, a
	jr	z, .kskip
	ld	hl, (EulerAngle)
	add	hl, de
	ld	(EulerAngle), hl
.kskip:
	ld	de, -8
	ld	a, ($F5001E)
	bit	2, a
	jr	z, .kskip2
	ld	hl, (EulerAngle)
	add	hl, de
	ld	(EulerAngle), hl
.kskip2:
	ld	a, ($F5001E)
	bit	0, a
	jr	z, .kskip5
	ld	hl, (WorldMatrix+12)
	ld	de, DELTA
	add	hl, de
	ld	(WorldMatrix+12), hl
.kskip5:

	ld	a, ($F5001E)
	bit	3, a
	jr	z, .kskip6
	ld	hl, (WorldMatrix+12)
	ld	de, -DELTA
	add	hl, de
	ld	(WorldMatrix+12), hl
.kskip6:

	ld	hl, (WorldMatrix+15)

	ld	a, ($F50012)
	bit	0,a
	jr	z, .kskip3
	ld	de, DELTA
	add	hl, de
.kskip3:

	bit	4,a
	jr	z, .kskip4
	ld	de, -DELTA
	add	hl, de
.kskip4:

	ld	(WorldMatrix+15), hl

	ld a,($F5001C)
	bit 6,a

	jp	z, .loop
	ret

.ressource:
; load a file from an appv
; hl : file name
; hl = file adress
; if error : c set, a = error code
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	ret	c
	call	ti.ChkInRam
	ex	de, hl
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
 
include	"lib/virtual.asm"
include	"font/font.asm"
include	"debug.asm"

posX:
	dw	0
posY:
	dw	0
posZ:
	dw	0
Temp:
	dl	0,0

; choose mateus or tonberry

VertexName:
	db	ti.AppVarObj, "LARAV",0
Vertex:
	dl	0
TriangleName:
	db	ti.AppVarObj, "LARAF", 0
Triangle:
	dl	0
TextureName:
	db	ti.AppVarObj, "LARAT", 0
Texture:
	dl	0
Light:
	db	0,0,-64
	db	4
	db	255
	dw	0,0,0

ScaleMatrix:
	db	64,0,0		; 44
	db	0,113,0		; 58
	db	0,0,40		; 37
	dl	0,0,0
ScaleMatrix3d4:
	db	48,0,0
	db	0,64,0
	db	0,0,64
	dl	0,0,0
UnitVector:
	dl	0,16384,0
Quaternion:
	dl	0,0,0,0
QuatMatrix:
	dl	0,0,0,0,0,0
WorldMatrix:
	dl	0,0,0,0,0,0
ModelMatrix:
	db	0,0,64
	db	0,64,0
	db	-64,0,0
	dw	0,0,0
EulerAngle:
	dl	0,0,0
LightAngle:
	dl	0,0,0
	
Material:
	db	VX_FORMAT_TEXTURE
	dl	VX_VERTEX_BUFFER
	dl	vxVertexShader.ftransform
	dl	vxVertexShader.uniform
	dl	vxPixelShader.texture
