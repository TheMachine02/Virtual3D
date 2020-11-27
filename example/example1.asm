include	"include/ez80.inc"
include	"include/ti84pceg.inc"
include	"include/tiformat.inc"

format	ti executable 'TEST1'

#define	DELTA	4096


	ld	hl, VertexName
	call	find
	ret	c
	ld	(Vertex), hl

	ld	hl, TriangleName
	call	find
	ret	c
	ld	(Triangle), hl

; init the virtual 3d library
	call	vxEngineInit
	ret	c		; qui if error at init

; setup global variable for rendering, euler angle and the translation of WorldMatrix

	ld	hl, 0
	ld	(EulerAngle), hl
	ld	(LightAngle), hl

	ld	ix, WorldMatrix
	lea	hl, ix+0
	call	vxMatrixLoadIdentity
	ld	hl, 65536
	ld	(ix+15), hl		; Z translation of the matrix

	ld	a, 6
	ld	(vxLightUniform+3), a
	ld	a, 255
	ld	(vxLightUniform+4), a

MainLoop:

	call	vxTimer.reset

	ld	hl, (LightAngle)
	ld	de, 16
	add	hl, de
	ld	(LightAngle), hl
	call	vxSin
	ld	a, h
	ld	(vxLightUniform+2), a
	ld	hl, (LightAngle)
	call	vxCos
	ld	a, h
	ld	(vxLightUniform), a

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

	ld	a, VX_FORMAT_COLOR
	ld	ix, WorldMatrix
	ld	iy, ModelMatrix
	ld	bc, VX_VERTEX_BUFFER
	ld	hl, (Vertex)
	ld	de, (Triangle)
	call	vxGeometryQueue

; 	ld	hl, (vxGeometrySize)
; 	ld	(triangle_count), hl

	call	vxSortQueue

	ld	c, 00000000b
	call	vxBuffer.clearColor
	call	vxSubmitQueue

; ; timer & counter
; 
; 	ld	bc, 320*8-1
; 	ld	de, (vxFramebuffer)
; 	or	a, a
; 	sbc	hl, hl
; 	add	hl, de
; 	inc	de
; 	ld	(hl), 0
; 	ldir
; 
; 	ld	hl, 0
; 	ld	(TextXPos_SMC), hl
; 	ld	a, 0
; 	ld	(TextYPos_SMC), a
; 
; 	call	vxTimerRead
; ; do (ade/256)/187
; 	ld	(Temp), de
; 	ld	(Temp+3), a
; 	ld	de, (Temp+1)
; ; divide de by 187
; 	ex	de, hl
; 	ld	bc, 187
; 	call	__idivs_ASM
; 	ld	de, 4
; 	push	de
; 	push	hl
; 	call	_PrintUInt
; 	pop	de
; 	pop	hl
; 
; 	ld	hl, (TextXPos_SMC)
; 	ld	de, 8
; 	add	hl, de
; 	ld	(TextXPos_SMC), hl
; 
; triangle_count=$+1
; 	ld	hl, 0
; 	ld	de, 4
; 	push	de
; 	push	hl
; 	call	_PrintUInt
; 	pop	de
; 	pop	hl

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

include	"lib/virtual.asm"
; include	"graphics_lib.asm"

posX:
	dw	0
posY:
	dw	0
posZ:
	dw	0
Temp:
	dl	0,0

VertexName:
	db	ti.AppVarObj, "SUZANV",0
Vertex:
	dl	0
TriangleName:
	db	ti.AppVarObj, "SUZANF", 0
Triangle:
	dl	0

ScaleMatrix:
	db	77,0,0		; 44
	db	0,102,0		; 58
	db	0,0,64		; 37
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
