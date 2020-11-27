include	"include/ez80.inc"
include	"include/ti84pceg.inc"
include	"include/tiformat.inc"

format	ti executable 'TEST2'
define	DELTA	4096
define	VX_DEBUG_CC_INSTRUCTION

	ld	hl, VertexName
	call	find
	ret	c
	ld	(Vertex), hl

	ld	hl, TriangleName
	call	find
	ret	c
	ld	(Triangle), hl

	ld	hl, TextureName
	call	find
	ret	c
	ld	(Texture), hl

; init the virtual 3d library
	call	vxEngineInit
	ret	c		; quit if error at init

	ld	hl, (Texture)
	ld	a, VX_IMAGE_ZX7_COMPRESSED
	ld	de, $D30000
	call	vxImageCopy

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

	ld	ix, lightShader
;	ld	ix, alphaShader
;	ld	ix, gouraudShader
	call	vxShaderLoad

	ld	a, 0
	ld	(vxAnimationKey), a

MainLoop:
	call	vxTimer.reset

; 	call	Random
; 	ld	a, l
; 	and	a, 31
; 	add	a, 224
; 	ld	(vxLightUniform+4), a

	ld	hl, (EulerAngle)
	ld	iy, Quaternion
	ld	ix, UnitVector
	call	vxQuaternionRotationAxis
	ld	ix, WorldMatrix
	call	vxQuaternionGetMatrix
	lea	iy, ix+0
	ld	ix, vxProjectionMatrix
	ld	hl, WorldMatrix
	call	vxMatrixMlt

	ld	a, VX_FORMAT_TEXTURE
	ld	ix, WorldMatrix
	ld	iy, ModelMatrix
;	ld	bc, VX_VERTEX_BUFFER
	ld	bc, VX_VERTEX_BUFFER
	ld	hl, (Vertex)
	ld	de, (Triangle)
;	ld	hl, VERTEXDATA
;	ld	de, TRIDATA
	call	vxGeometryQueue

	ld	hl, (vxGeometrySize)
	ld	(debug.visible_count), hl
	ld	hl, (Triangle)
	inc	hl
	ld	hl, (hl)
	ld	(debug.triangle_count), hl

	call	vxSortQueue

	ld	c, $00
	call	vxBuffer.clearColor
	call	vxSubmitQueue

	call	debug.display_panel

	call	vxBuffer.swap

KeyboardTest:
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
	ld	a, ($F5001E)
	bit	0, a
	jr	z, _kskip5
	ld	hl, (WorldMatrix+12)
	ld	de, DELTA
	add	hl, de
	ld	(WorldMatrix+12), hl
_kskip5:

	ld	a, ($F5001E)
	bit	3, a
	jr	z, _kskip6
	ld	hl, (WorldMatrix+12)
	ld	de, -DELTA
	add	hl, de
	ld	(WorldMatrix+12), hl
_kskip6:

	ld	hl, (WorldMatrix+15)

	ld	a, ($F50012)
	bit	0,a
	jr	z, _kskip3
	ld	de, DELTA
	add	hl, de
_kskip3:

	bit	4,a
	jr	z, _kskip4
	ld	de, -DELTA
	add	hl, de
_kskip4:

	ld	(WorldMatrix+15), hl

	ld a,($F5001C)
	bit 6,a

	jp	z, MainLoop
	ret

Random:
    ld ix, rand1
    ld hl, (ix)
    ld de, (ix+3)
    ld b, h
    ld c, l
    add hl, hl
    rl e
    rl d
    add hl, hl
    rl e
    rl d
    inc l
    add hl, bc
    ld (ix), hl
    adc hl, de
    ld (ix+3), hl
    ex de, hl
    ld hl, (ix+6)
    ld bc, (ix+9)
    add hl, hl
    rl c
    rl b
    ld (ix+9), bc
    sbc a, a
    and	a, 11000101b
    xor l
    ld l, a
    ld (ix+6), hl
    ex de, hl
    add hl, bc
    ret
rand1:
 rb	12
 
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
	db	ti.AppVarObj, "ULTIMV",0
Vertex:
	dl	0
TriangleName:
	db	ti.AppVarObj, "ULTIMF", 0
Triangle:
	dl	0
TextureName:
	db	ti.AppVarObj, "ULTIMT", 0
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
	db	64,0,0
	db	0,64,0
	db	0,0,64
	dw	0,0,0
EulerAngle:
	dl	0,0,0
LightAngle:
	dl	0,0,0

find:
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
