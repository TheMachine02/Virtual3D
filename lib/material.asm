; Virtual-3D library, version 1.0
;
; MIT License
; 
; Copyright (c) 2017 - 2021 TheMachine02
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

define	VX_MATERIAL_FORMAT		0	; 1 byte, format of the material (stride / polygon format)
define	VX_MATERIAL_CACHE		1	; 3 bytes, vertex buffer cache
define	VX_MATERIAL_VERTEX_SHADER	4	; 3 bytes, vertex shader pointer
define	VX_MATERIAL_VERTEX_UNIFORM	7	; 3 bytes, vertex shader setup pointer
define	VX_MATERIAL_PIXEL_SHADER	10	; 3 bytes, pixel shader pointer
define	VX_MATERIAL_LIGHT		13	; 3 bytes, light
define	VX_MATERIAL_SIZE		16	; 16 bytes per material data, the buffer is 256
define	VX_MAX_MATERIAL			16	; 16 material can be defined
; define the material 0-15
iterate count, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
	define	VX_MATERIAL#count	(count*VX_MATERIAL_SIZE)
end iterate

; material should be load once at the start of the rendering

vxMaterial:
.load:
; a  = material index
; hl = material data
	ld	de, VX_MATERIAL_DATA
	ld	e, a
	ld	bc, VX_MATERIAL_SIZE - 3
	ldir
	ret

.pixel_state:
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

.vertex_state:
	ret
