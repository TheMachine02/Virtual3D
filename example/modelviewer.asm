include	"include/fasmg/ez80.inc"
include	"include/fasmg/tiformat.inc"
include	"include/ti84pceg.inc"

define	DELTA_PER_MS	4096*256/128
define	ANGLE_PER_MS	8*256/128

define	VX_DEBUG_CC_INSTRUCTION

format	ti executable archived 'V3DVIEW'

Main:
.init:
	ld	hl, Model.vertex_appv
	call	Model.load_ressource
	ret	c
	ld	(Model.vertex_source), hl

	ld	hl, Model.triangle_appv
	call	Model.load_ressource
	ret	c
	ld	(Model.triangle_source), hl

	ld	hl, Model.texture_appv
	call	Model.load_ressource
	ret	c
	ld	(Model.texture_source), hl
	
; init the virtual 3d library
	call	vxEngineInit
	ret	c		; quit if error at init

	ld	hl, (Model.texture_source)
	ld	a, VX_IMAGE_ZX7_COMPRESSED
	ld	de, $D30000
	call	vxImage.copy

; setup global variable for rendering, euler angle and the translation of World.matrix
	ld	hl, Model.matrix
	call	vxMatrixLoadIdentity
	ld	hl, World.matrix
	call	vxMatrixLoadIdentity
	ld	ix, Model.matrix
	ld	hl, 1024
	ld	(ix+13), l
	ld	(ix+14), h
; load the lightning
	ld	hl, World.light
	ld	de, vxLightUniform
	ld	bc, VX_LIGHT_SIZE
	ldir

; load the model material as MATERIAL0	
	ld	hl, Model.material
	ld	a, VX_MATERIAL0
	call	vxMaterialLoad

; set animation key
	ld	a, 0
	ld	(vxAnimationKey), a

; setup pixel shader
;	ld	ix, gouraudShader
;	ld	ix, lightShader
	ld	ix, alphaShader
	call	vxShaderLoad

.loop:
	call	vxTimer.reset
; lightning effect
; 	call	.random
; 	ld	a, l
; 	and	a, 7
; 	add	a, 56
; 	ld	(vxLightUniform+4), a
; 	ld	hl, (World.light_angle)
; 	call	vxMath.sin
; 	ld	a, h
; 	ld	(vxLightUniform), a
; 	ld	hl, (World.light_angle)
; 	call	vxMath.cos
; 	ld	a, h
; 	ld	(vxLightUniform+2), a	
; compute model rotation
	ld	hl, (Model.angle_y)
	ld	iy, Model.quaternion_y
	ld	ix, World.unit_vector_y
	call	vxQuaternionRotationAxis
	ld	hl, (Model.angle_x)
	ld	iy, Model.quaternion_x
	ld	ix, World.unit_vector_x
	call	vxQuaternionRotationAxis
	ld	hl, (Model.angle_z)
	ld	iy, Model.quaternion_z
	ld	ix, World.unit_vector_z
	call	vxQuaternionRotationAxis
	ld	ix, Model.quaternion_x
	ld	iy, Model.quaternion_y
	call	vxQuaternionMlt
	ld	iy, Model.quaternion_z
	call	vxQuaternionMlt
	ld	iy, Model.quaternion_x
	ld	ix, Model.matrix
	call	vxQuaternionGetMatrix
; 	lea	iy, ix+0
; 	ld	ix, vxProjectionMatrix
; 	ld	hl, World.matrix
; 	call	vxMatrixMlt
; TODO : remove this quick hack
	ld	hl, vxProjectionMatrix
	ld	de, World.matrix
	ld	bc, 9
	ldir
	
	ld	ix, World.matrix
	ld	iy, Model.matrix
	ld	hl, (Model.vertex_source)
	ld	de, (Model.triangle_source)
	ld	a, VX_MATERIAL0
	call	vxPrimitiveStream

	ld	hl, (vxGeometrySize)
	ld	(debug.visible_count), hl
	ld	hl, (Model.triangle_source)
	inc	hl
	ld	hl, (hl)
	ld	(debug.triangle_count), hl

	call	vxPrimitiveDepthSort
	
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
; min = 1
	inc	hl
	ex	(sp), hl
	ld	bc, DELTA_PER_MS
	call	ti._imulu
	ex	de, hl
	or	a, a
	sbc	hl, hl
	dec	sp
	push	de
	inc	sp
	pop	de
	ld	h, d
	ld	l, e
; min = 1
	inc	hl
	pop	de
	push	hl
	ld	a, ($F5001E)
	bit	1, a
	jr	z, .skip0
	ld	hl, (Model.angle_y)
	add	hl, de
	ld	(Model.angle_y), hl
.skip0:
	ld	a, ($F5001E)
	bit	0, a
	jr	z, .skip2
	ld	hl, (Model.angle_x)
	add	hl, de
	ld	(Model.angle_x), hl
.skip2:
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	ld	a, ($F5001E)
	bit	2, a
	jr	z, .skip1
	ld	hl, (Model.angle_y)
	add	hl, de
	ld	(Model.angle_y), hl
.skip1:
	ld	a, ($F5001E)
	bit	3, a
	jr	z, .skip3
	ld	hl, (Model.angle_x)
	add	hl, de
	ld	(Model.angle_x), hl
.skip3:
; zoom factor : Z offset of World.matrix
	pop	de
	ld	a, ($F50012)
	bit	0,a
	jr	z, .skip4
	ld	hl, (World.matrix+15)
	add	hl, de
	ld	(World.matrix+15), hl
.skip4:
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	bit	4,a
	jr	z, .skip5
	ld	hl, (World.matrix+15)
	add	hl, de
	ld	(World.matrix+15), hl
.skip5:
	
	bit	1,a
	jr	z, .skip6
	ld	hl, (World.matrix+12)
	add	hl, de
	ld	(World.matrix+12), hl
.skip6:
	or	a, a
	sbc	hl, hl
	sbc	hl, de
	ex	de, hl
	bit	3,a
	jr	z, .skip7
	ld	hl, (World.matrix+12)
	add	hl, de
	ld	(World.matrix+12), hl
.skip7:

	ld	a, ($F5001C)
	bit	0, a
	jr	z, .skip8
	ld	hl, (World.light_angle)
	ld	de, 16
	add	hl, de
	ld	(World.light_angle), hl
.skip8:

	ld	a, ($F5001C)
	bit	6, a
	jp	z, .loop
	ret

.random:
	ld	ix, .random_seed
	ld	hl, (ix)
	ld	de, (ix+3)
	ld	b, h
	ld	c, l
	add	hl, hl
	rl	e
	rl	d
	add	hl, hl
	rl	e
	rl	d
	inc	l
	add	hl, bc
	ld	(ix), hl
	adc	hl, de
	ld	(ix+3), hl
	ex	de, hl
	ld	hl, (ix+6)
	ld	bc, (ix+9)
	add	hl, hl
	rl	c
	rl	b
	ld	(ix+9), bc
	sbc	a, a
	and	a, 11000101b
	xor	a, l
	ld	l, a
	ld	(ix+6), hl
	ex	de, hl
	add	hl, bc
	ret
.random_seed:
	rb	12

World:
.unit_vector_y:
	dl	0, 16384, 0
.unit_vector_x:
	dl	16384, 0, 0
.unit_vector_z:
	dl	0, 0, 16384
.matrix:
	db	0, 0, 0
	db	0, 0, 0
	db	0, 0, 0
	dl	0, 0, 0
.posx:
	dw	0
.posy:
	dw	0
.posz:
	dw	0
	rb	1
.light:
	db	64,0,0
	db	4
	db	64
	dw	0,0,0
.light_angle:
	dl	512
	
Model:
.vertex_appv:
	db	ti.AppVarObj, "FRANV",0
;	db	ti.AppVarObj, "SUZANV",0
.vertex_source:
	dl	0
.triangle_appv:
	db	ti.AppVarObj, "FRANF", 0
;	db	ti.AppVarObj, "SUZANF",0
.triangle_source:
	dl	0
.texture_appv:
	db	ti.AppVarObj, "FRANT", 0
.texture_source:
	dl	0	
.matrix:
	db	64,0,0
	db	0,64,0
	db	0,0,64
	dl	0,0,0
.quaternion_y:
	dl	0, 0, 0, 0
.quaternion_x:
	dl	0, 0, 0, 0
.quaternion_z:
	dl	0, 0, 0, 0
.angle_x:
	dl	0
.angle_y:
	dl	0
.angle_z:
	dl	0	
.material:
	db	VX_FORMAT_TEXTURE   ;VX_FORMAT_GOURAUD
	dl	VX_VERTEX_BUFFER
	dl	vxVertexShader.ftransform
	dl	vxVertexShader.uniform
	dl	vxPixelShader.texture
	dl	0
; simple appv detect
; archivate the appv if not already archivated (TODO)
.load_ressource:
; load a file from an appv
; hl : file name
; hl = file adress
; if error : c set, a = error code
	call	ti.Mov9ToOP1
	call	ti.ChkFindSym
	ret	c
	call	ti.ChkInRam
	ex	de, hl
	jr	z, .unarchived
; 9 bytes - name size (1b), name string, appv size (2b)
	ld	de, 9
	add	hl, de
	ld	e, (hl)
	add	hl, de
	inc	hl
.unarchived:
	inc	hl
	inc	hl
	ret

include	"lib/virtual.asm"
include	"font/font.asm"
include	"debug.asm"
