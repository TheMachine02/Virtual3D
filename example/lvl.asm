include	"include/ez80.inc"
include	"include/ti84pceg.inc"
include	"include/tiformat.inc"
include	"lib/vx3D.inc"

format	ti executable 'LVL'

; init the virtual 3d library
	call	vxEngineInit
	ret	c		; quit if error at init

	ld	hl, dataRoomIndexName
	call	find
	ret	c
	ld	(dataRoomIndex), hl

	ld	hl, dataRoomVertexName
	call	find
	ret	c
	ld	(dataRoomVertex), hl

	ld	hl, dataLevelName
	call	find
	ret	c
	ld	(dataLevel), hl

	ld	hl, laraIndexName
	call	find
	ret	c
	ld	(dataLaraTriangle), hl

	ld	hl, laraVertexName
	call	find
	ret	c
	ld	(dataLaraVertex), hl

	ld	hl, textureName
	call	find
	ret	c
	ld	(cacheTexture), hl


	ld	a, VX_IMAGE_ZX7_COMPRESSED
	ld	de, $D30000
	call	vxImageCopy

	ld	hl, 0
	ld	(CameraAngle), hl
	ld	(LaraAngle), hl
	ld	hl, WorldMatrix
	call	vxMatrixLoadIdentity

	ld	hl, Light
	ld	de, vxLightUniform
	ld	bc, VX_LIGHT_SIZE
	ldir

;	ld	ix, lightShader
;	call	vxShaderLoad
; broken somehow

MainLoop:

	call	vxTimerReset
	call	vxTimerStart

	call	Camera
	ret	nz

	call	advanceFrame

renderLevel:
; get bounding box and the room
; get the psv
; render the psv

	ld	hl, VX_VERTEX_BUFFER
	ld	(cacheAdress), hl

	ld	hl, (dataLevel)
	ld	b, (hl)


;	ld	b, 3
;	ld	c, 2

	ld	b, 2
	ld	c, 0

allrender:
	push	bc
; get the triangle & vertex data
	ld	hl, 0
	ld	l, c
	add	hl, hl
	add	hl, hl
	ld	de, (dataRoomIndex)
	add	hl, de
	ld	hl, (hl)
	add	hl, de
	ex	de, hl
; vertex data
	ld	hl, 0
	ld	l, c
	add	hl, hl
	add	hl, hl
	ld	bc, (dataRoomVertex)
	add	hl, bc
	ld	hl, (hl)
	add	hl, bc

	ld	bc, (cacheAdress)
	push	hl
	inc	hl
	ld	hl, (hl)
	inc.s	hl
	dec.s	hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, bc
	ld	(cacheAdress), hl
	pop	hl

	ld	a, VX_GEOMETRY_TEXTURE
	ld	ix, WorldMatrix
	ld	iy, ModelMatrix
	call	vxGeometryQueue

	pop	bc
	inc	c
	djnz	allrender

	ld	a, VX_GEOMETRY_TEXTURE
	ld	ix, WorldMatrix
	ld	iy, LaraMatrix
	ld	bc, (cacheAdress)
	ld	hl, (dataLaraVertex)
	ld	de, (dataLaraTriangle)
	call	vxGeometryQueue

; 	ld	hl, (vxGeometrySize)
; 	ld	(triangle_count), hl

	call	vxSortQueue

	ld	c, 00000000b
	call	vxClearBuffer
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
; 	ld	hl, (TextXPos_SMC)
; 	ld	de, 8
; 	add	hl, de
; 	ld	(TextXPos_SMC), hl
; 
; 	ld	hl, 0
; 	ld	a, (posX+1)
; 	neg
; 	ld	l, a
; 	ld	de, 4
; 	push	de
; 	push	hl
; 	call	_PrintUInt
; 	pop	de
; 	pop	hl
; 	ld	hl, (TextXPos_SMC)
; 	ld	de, 8
; 	add	hl, de
; 	ld	(TextXPos_SMC), hl
; 
; 	ld	a, (posZ+1)
; 	neg
; 	ld	l, a
; 	ld	de, 4
; 	push	de
; 	push	hl
; 	call	_PrintUInt
; 	pop	de
; 	pop	hl

	call	vxFlushLCD
	jp	 MainLoop

include	"lib/vxMain.asm"
;include	"graphics_lib.asm"

posX:
 dw	0*256
posY:
 dw	-704 ; 2*256 // offset 192
posZ:
 dw	0*256
Temp:
 dl	0,0

dataRoomVertexName:
	db	ti.AppVarObj, "GYM0",0
dataRoomIndexName:
	db	ti.AppVarObj, "GYM1",0
dataLevelName:
	db	ti.AppVarObj, "GYMHEAD",0
textureName:
	db	ti.AppVarObj, "GYM2",0
laraVertexName:
	db	ti.AppVarObj, "LARAV", 0
laraIndexName:
	db	ti.AppVarObj, "LARAF", 0

dataRoomIndex:
	dl	0
dataRoomVertex:
	dl	0
dataLevel:
	dl	0
dataLaraVertex:
	dl	0
dataLaraTriangle:
	dl	0
cacheAdress:
	dl	0
cacheTexture:
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
	dw	0,0,0
LaraMatrix:
	db	64,0,0
	db	0,64,0
	db	0,0,64
	dw	0,0,0
LaraMatrix0:
	db	64,0,0
	db	0,64,0
	db	0,0,64
	dw	0,0,0

LaraStaticMatrix:
	db	0,0,64
	db	0,64,0
	db	-64,0,0
	dw	0,0,0
LaraAngle:
	dl	0,0,0
CameraAngle:
	dl	0,0,0

Camera:

	ld hl,$F50000
	ld (hl),2
	xor a,a
kwait:
	cp a,(hl)
	jr nz,kwait

	ld	de, -16
	ld	a, ($F5001E)
	bit	1, a
	jr	z, _kskip
	ld	hl, (LaraAngle)
	add	hl, de
	ld	(LaraAngle), hl
_kskip:
	ld	de, 16
	ld	a, ($F5001E)
	bit	2, a
	jr	z, _kskip2
	ld	hl, (LaraAngle)
	add	hl, de
	ld	(LaraAngle), hl
_kskip2:

	ld	hl, (LaraAngle)
	ld	de, (CameraAngle)
	or	a, a
	sbc	hl, de
	jr	z, skipit
	sra	h
	rr	l
	sra	h
	rr	l
	add	hl, de
	ld	(CameraAngle), hl
skipit:

	ld	hl, (LaraAngle)

	ld	iy, Quaternion
	ld	ix, UnitVector
	call	vxQuaternionRotationAxis
	ld	ix, LaraMatrix0
	call	vxQuaternionGetMatrix
	ld	iy, LaraStaticMatrix
	ld	ix, LaraMatrix0
	ld	hl, LaraMatrix
	call	vxMatrixMlt

	ld	hl, WorldMatrix
	call	vxMatrixLoadIdentity

	ld	de, (CameraAngle)

	or	a, a
	sbc	hl, hl
	sbc	hl, de

	ld	iy, Quaternion
	ld	ix, UnitVector
	call	vxQuaternionRotationAxis
	ld	ix, WorldMatrix
	call	vxQuaternionGetMatrix
;	ld	iy, WorldMatrix
;	ld	ix, vxProjectionMatrix
;	ld	hl, WorldMatrix
;	call	vxMatrixMlt

	ld	a, ($F5001E)
	bit	0, a
	jr	z, _kskip3

	ld	a, 1
	ld	(keypressed), a

	ld	de, (posX)
	ld	a, (LaraMatrix0+6)
	neg
	rla
	sbc	hl, hl
	rra
	sra	a
	ld	l, a
	or	a, a
	add	hl, de
	ld	de, (posY)
	ld	(posX), hl
	ld	a, (LaraMatrix0+7)
	rla
	sbc	hl, hl
	rra
	sra	a
	ld	l, a
	or	a, a
	add	hl, de
	ld	de, (posZ)
	ld	(posY), hl
	ld	a, (LaraMatrix0+8)
	rla
	sbc	hl, hl
	rra
	sra	a
	ld	l, a
	or	a, a
	add	hl, de
	ld	(posZ), hl
_kskip3:

	ld	a, ($F5001E)
	bit	3, a
	jr	z, _kskip4

	ld	a, 1
	ld	(keypressed), a

	ld	de, (posX)
	ld	a, (LaraMatrix0+6)
	rla
	sbc	hl, hl
	rra
	sra	a
	ld	l, a
	or	a, a
	add	hl, de
	ld	de, (posY)
	ld	(posX), hl
	ld	a, (LaraMatrix0+7)
	neg
	rla
	sbc	hl, hl
	rra
	sra	a
	ld	l, a
	or	a, a
	add	hl, de
	ld	de, (posZ)
	ld	(posY), hl
	ld	a, (LaraMatrix0+8)
	neg
	rla
	sbc	hl, hl
	rra
	sra	a
	ld	l, a
	or	a, a
	add	hl, de
	ld	(posZ), hl
_kskip4:


	ld	hl, (posY)
	ld	de, 32
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

	ld	a, l
	ld	(posY), a
	ld	a, h
	ld	(posY+1), a

	ld	ix, WorldMatrix
	ld	iy, posX
	call	vxfTransform

	ld	hl, (vxPosition+6)
	ld	de, 29184
	add	hl, de
	ld	(vxPosition+6), hl

	ld	hl, vxPosition
	ld	de, WorldMatrix+9
	ld	bc, 9
	ldir

	ld	ix, posX
	ld	iy, LaraMatrix+9

	ld	de, (ix+0)
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ld	(iy+0), hl
	ld	de, (ix+2)
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ld	de, -192
	add	hl, de
	ld	(iy+2), hl
	ld	de, (ix+4)
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ld	a, l
	ld	(iy+4), a
	ld	a, h
	ld	(iy+5), a

	ld a,($F5001C)
	bit 6,a
	ret

keypressed:
	db	0

; BoundingBoxTest:
; ; hl is stream
; ; test vmax and vmin
; 
; ; if vmax.x>x && vmin.x < x
; 
; #define VX_VMAX_OFFSET   12
; #define VX_VMIN_OFFSET   18
; 	ret

define animationLivingStart  0
define animationLivingSize   12
define animationWalkingStart 12
define animationWalkingSize  19
define animationTurnRStart   31
define animationTurnRSize    16
define animationTurnLStart   47
define animationTurnLSize    16
define animationBackStart    63
define animationBackSize     16

animationLiving:
	db	0,11
animationWalking:
	db	0,18
animationTurnright:
	db	0,15
animationTurnleft:
	db	0,15
animationBack:
	db	0,15


ModelAnimation:
AnimationFrameStart:
	db	0
AnimationFrameEnd:
	db	0
AnimationRuning:
	db	11111111b
init:
	xor	a, a
	ld	(vxAnimationKey), a
	ld	(AnimationFrameEnd), a
	ld	(AnimationFrameStart), a
	ld	a, 11110000b
	ld	(AnimationRuning), a
	ret

advanceFrame:
	ld	hl, AnimationRuning

	ld	a, ($F5001E)
	cpl
	or	(hl)
	bit	3, a
	jp	z, AnimationApply
	ld	a, ($F5001E)
	and	(hl)
	bit	3, a
	jr	z, AnimationWalkingEnd
	ld	a, 11110111b
	ld	(hl), a
	ld	a, animationWalkingStart - 1
	ld	(vxAnimationKey), a
	inc	a
	ld	(AnimationFrameStart), a
	add	a, animationWalkingSize
	ld	(AnimationFrameEnd), a
	jp	AnimationApply
AnimationWalkingEnd:
	ld	a, ($F5001E)
	cpl
	or	(hl)
	bit	0, a
	jp	z, AnimationApply
	ld	a, ($F5001E)
	and	(hl)
	bit	0, a
	jr	z, AnimationBackEnd
	ld	a, 11111110b
	ld	(hl), a
	ld	a, animationBackStart - 1
	ld	(vxAnimationKey), a
	inc	a
	ld	(AnimationFrameStart), a
	add	a, animationBackSize
	ld	(AnimationFrameEnd), a
	jr	AnimationApply
AnimationBackEnd:

	ld	a, ($F5001E)
	cpl
	or	(hl)
	bit	1, a
	jr	z, AnimationApply
	ld	a, ($F5001E)
	and	(hl)
	bit	1, a
	jr	z, AnimateTurnLEnd
	ld	a, 11111101b
	ld	(hl), a
	ld	a, animationTurnLStart - 1
	ld	(vxAnimationKey), a
	inc	a
	ld	(AnimationFrameStart), a
	add	a, animationTurnLSize
	ld	(AnimationFrameEnd), a
	jr	AnimationApply
AnimateTurnLEnd:

	ld	a, ($F5001E)
	cpl
	or	(hl)
	bit	2, a
	jr	z, AnimationApply
	ld	a, ($F5001E)
	and	(hl)
	bit	2, a
	jr	z, AnimateTurnREnd
	ld	a, 11111011b
	ld	(hl), a
	ld	a, animationTurnRStart - 1
	ld	(vxAnimationKey), a
	inc	a
	ld	(AnimationFrameStart), a
	add	a, animationTurnRSize
	ld	(AnimationFrameEnd), a
	jr	AnimationApply
AnimateTurnREnd:

	ld	a, ($F5001E)
	and	00001111b
	jr	nz, AnimationLivingEnd
	ld	a, (hl)
	bit	4, a
	jr	z, AnimationLivingEnd
	ld	a, 11101111b
	ld	(hl), a
	ld	a, animationLivingStart - 1
	ld	(vxAnimationKey), a
	inc	a
	ld	(AnimationFrameStart), a
	add	a, animationLivingSize
	ld	(AnimationFrameEnd), a
AnimationLivingEnd:

AnimationApply:

	ld	a, (AnimationFrameEnd)
	ld	l, a
	dec	l

	ld	a, (vxAnimationKey)
	add	a, 2
	cp	a, l
	jr	c, StoreKey
	ld	a, (AnimationFrameStart)
StoreKey:
	ld	(vxAnimationKey), a
	ret


Light:
	db	64,0,0
	db	8
	db	255
	dw	0,0,0

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
