include	"include/fasmg/ez80.inc"
include	"include/fasmg/tiformat.inc"
include	"include/ti84pceg.inc"

define	VX_DEBUG_CC_INSTRUCTION

define	DELTA_PER_MS	4096*256/64
define	ANGLE_PER_MS	8*256/64
define	DELTA		4096

format	ti executable archived 'V3DFLAT'

Main:
.init:
	ld	hl, VertexName
	call	.ressource
	ret	c
	ld	(Vertex), hl
	ld	hl, TriangleName
	call	.ressource
	ret	c
	ld	(Triangle), hl
; init the virtual 3d library
	call	vxEngineInit
	ret	c
; setup global variable for rendering, euler angle and the translation of WorldMatrix
	ld	hl, 0
	ld	(EulerAngle), hl
	ld	(EulerAngle+3), hl
	ld	hl, 512
	ld	(LightAngle), hl
	ld	ix, WorldMatrix
	lea	hl, ix+0
	call	vxMatrixLoadIdentity
	ld	hl, 65536
	ld	(ix+15), hl		; Z translation of the matrix
; define a little light \o/
	ld	a, 0
	ld	(vxLightUniform+3), a
	ld	a, 96
	ld	(vxLightUniform+4), a
	ld	hl, Material
	ld	a, VX_MATERIAL0
	call	vxMaterialLoad
	
	ld	ix, gouraudShader
	call	vxShaderLoad
	
.loop:
	call	vxTimer.reset
	ld	hl, (LightAngle)
	call	vxMath.sin
	ld	a, h
	ld	(vxLightUniform), a
	ld	hl, (LightAngle)
	call	vxMath.cos
	ld	a, h
	ld	(vxLightUniform+2), a
	ld	hl, (EulerAngle)
	ld	iy, Quaternion
	ld	ix, UnitVector
	call	vxQuaternionRotationAxis
	ld	hl, (EulerAngle+3)
	ld	iy, Quaternion_y
	ld	ix, UnitVector_y
	call	vxQuaternionRotationAxis
	ld	ix, Quaternion_y
	ld	iy, Quaternion
	call	vxQuaternionMlt
	ld	iy, Quaternion_y
	ld	ix, WorldMatrix
	call	vxQuaternionGetMatrix
	lea	iy, ix+0
	ld	ix, vxProjectionMatrix
	ld	hl, WorldMatrix
	call	vxMatrixMlt
	ld	ix, WorldMatrix
	ld	iy, ModelMatrix
	ld	hl, (Vertex)
	ld	de, (Triangle)
	ld	a, VX_MATERIAL0
	call	vxPrimitiveStream
; debug for triangle count
	ld	hl, (vxGeometrySize)
	ld	(debug.visible_count), hl
	ld	hl, (Triangle)
	inc	hl
	ld	hl, (hl)
	ld	(debug.triangle_count), hl
	call	vxPrimitiveDepthSort
; clear should happen after sort since sort use the target framebuffer as a temporary buffer
	call	vxFramebufferClear
	call	vxPrimitiveSubmit
	call	debug.display_panel
	call	vxFramebufferSwap
.keyboard:
	ld	hl, $F50000
	ld	(hl), 2
	xor	a, a
.wait:
	cp	a, (hl)
	jr	nz, .wait
.independant_offset:
; compute offset independant to frame timing
	ld	de, (VX_TIMER_COUNTER_FR+1)
; divide de by 187
	ex	de, hl
	ld	bc, 187
	call	ti._idivu
; multiply it by the ANGLE_PER_MS and divide by 256
	ld	bc, ANGLE_PER_MS
; hl * bc / 256
	push	hl
	call	ti._imulu
	ex	de, hl
	sbc	hl, hl
	dec	sp
	push	de
	inc	sp
	pop	de
	ld	h, d
	ld	l, e
	ex	(sp), hl
	ld	bc, DELTA_PER_MS
	call	ti._imulu
	ex	de, hl
	sbc	hl, hl
	dec	sp
	push	de
	inc	sp
	pop	de
	ld	h, d
	ld	l, e
	pop	de
	push	hl
	ld	a, ($F5001E)
	bit	1, a
	jr	z, .skip0
	ld	hl, (EulerAngle)
	add	hl, de
	ld	(EulerAngle), hl
.skip0:
	ld	a, ($F5001E)
	bit	0, a
	jr	z, .skip2
	ld	hl, (EulerAngle+3)
	add	hl, de
	ld	(EulerAngle+3), hl
.skip2:
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	ld	a, ($F5001E)
	bit	2, a
	jr	z, .skip1
	ld	hl, (EulerAngle)
	add	hl, de
	ld	(EulerAngle), hl
.skip1:
	ld	a, ($F5001E)
	bit	3, a
	jr	z, .skip3
	ld	hl, (EulerAngle+3)
	add	hl, de
	ld	(EulerAngle+3), hl
.skip3:
; zoom factor : Z offset of WorldMatrix
	pop	de
	ld	a, ($F50012)
	bit	0,a
	jr	z, .skip4
	ld	hl, (WorldMatrix+15)
	add	hl, de
	ld	(WorldMatrix+15), hl
.skip4:
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	bit	4,a
	jr	z, .skip5
	ld	hl, (WorldMatrix+15)
	add	hl, de
	ld	(WorldMatrix+15), hl
.skip5:
	
	bit	1,a
	jr	z, .skip6
	ld	hl, (WorldMatrix+12)
	add	hl, de
	ld	(WorldMatrix+12), hl
.skip6:
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	bit	3,a
	jr	z, .skip7
	ld	hl, (WorldMatrix+12)
	add	hl, de
	ld	(WorldMatrix+12), hl
.skip7:	
	ld	a, ($F5001C)
	bit	0, a
	jr	z, .skip8
	ld	hl, (LightAngle)
	ld	de, 16
	add	hl, de
	ld	(LightAngle), hl
.skip8:
	ld	a, ($F5001C)
	bit	6, a
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
	ex	de,hl
	jr	z, .unarchived
; 9 bytes - name size (1b), name string, appv size (2b)
	ld	de, 9
	add	hl, de
	ld	e, (hl)
	add	hl, de
	inc	hl
	inc	hl
	inc	hl
	ret
.unarchived:
	scf
	ret
	
include	"lib/virtual.asm"
include	"font/font.asm"
include	"debug.asm"

VertexName:
	db	ti.AppVarObj, "SUZANV",0
Vertex:
	dl	0
TriangleName:
	db	ti.AppVarObj, "SUZANF", 0
Triangle:
	dl	0

UnitVector:
	dl	0,16384,0
UnitVector_y:
	dl	16384,0,0
Quaternion:
	dl	0,0,0,0
Quaternion_y:
	dl	0,0,0,0
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

Material:
	db	VX_FORMAT_GOURAUD
	dl	VX_VERTEX_BUFFER
	dl	vxVertexShader.ftransform
	dl	vxVertexShader.uniform
	dl	0
