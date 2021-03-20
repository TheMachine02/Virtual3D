define	VX_MATERIAL_DATA		$D03500
define	VX_MATERIAL_FORMAT		0	; 1 byte, format of the material (stride / polygon format)
define	VX_MATERIAL_CACHE		1	; 3 bytes, vertex buffer cache
define	VX_MATERIAL_VERTEX_SHADER	4	; 3 bytes, vertex shader pointer
define	VX_MATERIAL_PIXEL_SHADER	7	; 3 bytes, pixel shader pointer
define	VX_MATERIAL_SIZE		16	; 16 bytes per material data, the buffer is 256
define	VX_MAX_MATERIAL			16	; 16 material can be defined
; define the material 0-15
iterate count, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
	define	VX_MATERIAL#count	(count*VX_MATERIAL_SIZE)
end iterate

; material should be load once at the start of the rendering

vxMaterialLoad:
; a  = material index
; hl = material data
	ld	de, VX_MATERIAL_DATA
	ld	e, a
	ld	bc, VX_MATERIAL_SIZE
	ldir
	ret

vxMaterialPixelState:
; modify the pixel state to actually load a new pixel shader
; need to modify lenght LUT table, the actual SHA256 area and various SMC data
; costly
; a = material
	ld	hl, VX_MATERIAL_DATA
	add	a, VX_MATERIAL_PIXEL_SHADER
	ld	l, a
; 	ld	hl, (vxShaderJump)
; 	ld	(vxShaderJumpWrite), hl
; 	ld	hl, (vxShaderAdress0)
; 	ld	(vxShaderAdress0Write), hl
; 	ld	hl, (vxShaderAdress1)
; 	ld	(vxShaderAdress1Write), hl
; 	ld	hl, (vxShaderAdress2)
; 	ld	(vxShaderAdress2Write), hl
	ret
vxMaterialVertexState:
; nop
	ret
