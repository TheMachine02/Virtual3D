include	"include/fasmg/ez80.inc"
include	"include/fasmg/tiformat.inc"
include	"include/ti84pceg.inc"

define	VX_DEBUG_CC_INSTRUCTION

format	ti executable 'LVL'

; init the virtual 3d library

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

; 	ld	hl, laraIndexName
; 	call	find
; 	ret	c
; 	ld	(dataLaraTriangle), hl
; 
; 	ld	hl, laraVertexName
; 	call	find
; 	ret	c
; 	ld	(dataLaraVertex), hl

; 	ld	hl, SkyName
; 	call	find
; 	ret	c
; 	ld	(Skybox), hl
	
	ld	hl, textureName
	call	find
	ret	c
	ld	(cacheTexture), hl

	call	vxMemory.layout
	ret	c		; quit if error at init	
	
	ld	hl, (cacheTexture)
	ld	a, VX_IMAGE_ZX7_COMPRESSED
	ld	de, $D30000
	call	vxImage.copy

	ld	hl, 0
	ld	(CameraAngle), hl
	ld	(LaraAngle), hl
	ld	hl, WorldMatrix
	call	vxMatrix.load_identity

	ld	hl, Light
	ld	de, vxLightUniform
	ld	bc, VX_LIGHT_SIZE
	ldir

; 	ld	ix, lightShader
; 	call	vxShaderLoad
; broken somehow

MainLoop:
; reset the cycle counter
	call	vxTimer.reset
; enable cc counter
;	call	vxTimer.enable
	
	call	Camera
	ret	nz

	call	advanceFrame

; 	di
; 	halt
; ;-102,4
; 	ld	hl, -270
; 	ld	de, 65536/25 ; 2621
; 	scf
; 	ld	a, h
; 	ld	h, d
; 	ld	c, l
; 	mlt	hl
; 	jr	nc, $+6
; 	or	a, a
; 	sbc	hl, de
; 	ld	b, e
; 	mlt	bc
; 	rl	c
; 	ld	c, b
; 	ld	b, 0
; 	adc	hl, bc
; ; + - de based on sign of the difference and the bit

renderLevel:
; get bounding box and the room
; get the psv
; render the psv

	ld	hl, 0
	ld	(debug.triangle_count), hl

	ld	hl, $D22000
	ld	(cacheAdress), hl

; 	ld	hl, (dataLevel)
; 	ld	b, (hl)
	ld	b, 3
	ld	c, 2

	call	Render.room_list

; 	ld	a, VX_FORMAT_TEXTURE
; 	ld	ix, WorldMatrix
; 	ld	iy, LaraMatrix
; 	ld	bc, (cacheAdress)
; 	ld	hl, (dataLaraVertex)
; 	ld	de, (dataLaraTriangle)
; 	
; 	push	hl
; 	push	de
; 	push	bc
; 	ex	de, hl
; 	inc	hl
; 	ld	bc, (hl)
; 	ld	hl, (debug.triangle_count)
; 	add.s	hl, bc
; 	ld	(debug.triangle_count), hl
; 	pop	bc
; 	pop	de
; 	pop	hl
; 
; 	call	vxPrimitiveStream
; 
; 	ld	hl, (vxGeometrySize)
; 	ld	(debug.visible_count), hl
; 
	call	vxPrimitiveDepthSort
	call	vxFramebufferClear
; 	ld	hl, (Skybox)
; 	ld	de, (vxFramebuffer)
; 	ld	bc, 320*160
; 	ldir
; 	ld	hl, $E40000
; 	ld	bc, 320*80
; 	ldir
	
	call	vxPrimitiveSubmit
	
; timer & counter
; 	
	call	debug.display_panel
;	call	vxFramebufferScale2x
	
	call	vxFramebufferSwap
	jp	 MainLoop

include	"lib/virtual.asm"
include	"font/font.asm"
include	"debug.asm"

posX:
 dw	0*256
posY:
 dw	-704 ; 2*256 // offset 192
posZ:
 dw	0*256

dataRoomVertexName:
	db	ti.AppVarObj, "GYM0",0
dataRoomIndexName:
	db	ti.AppVarObj, "GYM1",0
dataLevelName:
	db	ti.AppVarObj, "GYMHEAD",0
textureName:
	db	ti.AppVarObj, "ROOMT",0
laraVertexName:
	db	ti.AppVarObj, "LARAV", 0
laraIndexName:
	db	ti.AppVarObj, "LARAF", 0
SkyName:
	db	ti.AppVarObj, "SKYBOX", 0
	
Skybox:
	dl	0
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
UnitVector_2:
	dl	16384, 0, 0
Quaternion_x:
	dl	0,0,0,0
Quaternion_y:
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
LaraMatrix1:
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

Light:
	db	0,0,64
	db	18
	db	64
	dw	0,0,0
	
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
	ld	iy, Quaternion_x
	ld	ix, UnitVector
	call	vxQuaternionRotationAxis
	ld	ix, LaraMatrix0
	call	vxQuaternionGetMatrix
	ld	iy, LaraStaticMatrix
	ld	ix, LaraMatrix0
	ld	hl, LaraMatrix
	call	vxMatrix.mlt3

	ld	hl, WorldMatrix
	call	vxMatrix.load_identity

	ld	de, (CameraAngle)

	or	a, a
	sbc	hl, hl
	sbc	hl, de

	ld	iy, Quaternion_x
	ld	ix, UnitVector
	call	vxQuaternionRotationAxis
	ld	ix, WorldMatrix
	call	vxQuaternionGetMatrix
	ld	iy, WorldMatrix
	ld	ix, vxProjectionMatrix
	ld	hl, WorldMatrix
	call	vxMatrix.mlt3

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
	call	vxMatrix.ftransform

	ld	hl, (vxPosition+6)
;	ld	de, 29184
	ld	de, 20480+1024
	add	hl, de
	ld	(vxPosition+6), hl
	
	ld	hl, (vxPosition+3)
	ld	de, 192
	add	hl, de
	ld	(vxPosition+3), hl

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

Render:

.room_list:
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

	ld	a, VX_FORMAT_TEXTURE
	ld	ix, WorldMatrix
	ld	iy, ModelMatrix
	
	push	hl
	push	de
	push	bc
	ex	de, hl
	inc	hl
	ld	bc, (hl)
	ld	hl, (debug.triangle_count)
	add.s	hl, bc
	ld	(debug.triangle_count), hl
	pop	bc
	pop	de
	pop	hl
	
	call	vxPrimitiveStream

	pop	bc
	inc	c
	djnz	.room_list
	ret
	
.find_chamber:
; find where the character is
; character position is posX, posY, posY
	ld	hl, (dataRoomVertex)
	
	push	hl
	ld	hl, (hl)
; this is the stream
	
.bounding_box:
