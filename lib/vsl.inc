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

; standard define ;

define	VX_PIXEL_SHADER			1 shl 0
define	VX_PIXEL_SHADER_CODE		$E10010
define	VX_PIXEL_SHADER_DATA		$D00000
define	VX_PIXEL_SHADER_SIZE		64
define	VX_PIXEL_SHADER_MAX_SIZE	38

define	VX_VERTEX_SHADER		1 shl 1
define	VX_VERTEX_SHADER_CODE		$E30800
define	VX_VERTEX_SHADER_DATA		$E30800
define	VX_VERTEX_SHADER_SIZE		1024
define	VX_VERTEX_SHADER_MAX_SIZE	1024

define	VX_PRIMITIVE_ASM_SHADER		1 shl 2
define	VX_PRIMITIVE_ASM_CODE		$E30800
define	VX_PRIMITIVE_ASM_DATA		$E30800
define	VX_PRIMITIVE_ASM_MAX_SIZE	1024

define	VX_SHADER_TYPE			0
define	VX_SHADER_SIZE			1
define	VX_SHADER_DATA0			4
define	VX_SHADER_DATA1			5
define	VX_SHADER_CODE			6

; cache data register (de) ;

define	VX_VERTEX_SIZE			16
define	VX_VERTEX_CODE			0
define	VX_VERTEX_SY			1
define	VX_VERTEX_SX			2
define	VX_VERTEX_GPR0			4
define	VX_VERTEX_GPR1			5
define	VX_VERTEX_GPR2			6
define	VX_VERTEX_RX			7
define	VX_VERTEX_RY			10
define	VX_VERTEX_RZ			13

; vertex input register (iy) ;

define	VX_VERTEX_DATA_SIZE		10
define	VX_VERTEX_SIGN			0
define	VX_VERTEX_POSITION		1
define	VX_VERTEX_VX			1
define	VX_VERTEX_VY			3
define	VX_VERTEX_VZ			5
define	VX_VERTEX_NORMAL		7
define	VX_VERTEX_NX			7
define	VX_VERTEX_NY			8
define	VX_VERTEX_NZ			9

; global data input register (ix) ;

; special matrix 0
define	VX_MATRIX0			0
define	VX_MATRIX0_C0			0
define	VX_MATRIX0_C1			1
define	VX_MATRIX0_C2			2
define	VX_MATRIX0_C3			3
define	VX_MATRIX0_C4			4
define	VX_MATRIX0_C5			5
define	VX_MATRIX0_C6			6
define	VX_MATRIX0_C7			7
define	VX_MATRIX0_C8			8
define	VX_MATRIX0_TX			9
define	VX_MATRIX0_TY			12
define	VX_MATRIX0_TZ			15

; special light 0

define	VX_LIGHT0_VECTOR		18
define	VX_LIGHT0_AMBIENT		21
define	VX_LIGHT0_POW			22
define	VX_LIGHT0_PARAM			23
define	VX_LIGHT0_POSITION		24

; triangle input register ;

define	VX_TRIANGLE_INDEX		0
define	VX_TRIANGLE_I0			0
define	VX_TRIANGLE_I1			3
define	VX_TRIANGLE_I2			6

define	VX_POLYGON_I0			0
define	VX_POLYGON_I1			3
define	VX_POLYGON_I2			6
define	VX_POLYGON_I3			9

define	VX_TRIANGLE_NORMAL		9
define	VX_TRIANGLE_N0			9
define	VX_TRIANGLE_N1			10
define	VX_TRIANGLE_N2			11
define	VX_TRIANGLE_N3			12	; 3 bytes

define	VX_TRIANGLE_COLOR		15
define	VX_TRIANGLE_TEXTURE		15
define	VX_TRIANGLE_UV0			15
define	VX_TRIANGLE_UV1			17
define	VX_TRIANGLE_UV2			19

; geometry out buffer register ;

define	VX_GEOMETRY_SIZE		6
define	VX_GEOMETRY_KEY_SIZE		4
define	VX_GEOMETRY_INDEX		0
define	VX_GEOMETRY_ID			3
define	VX_GEOMETRY_DEPTH		3

; geometry in buffer header ;

define	VX_GEOMETRY_FORMAT		0
define	VX_GEOMETRY_BUFFER		1

; format mask
define	VX_FORMAT_STRIDE		31	; the triangle stride value
define	VX_FORMAT_UNIFORM_MIX		32	; mix the uniform value (GPR2)
define	VX_FORMAT_UNPACK_UV		64	; unpack UV from the triangle data, if reset this phase will be skipped
define	VX_FORMAT_INTERPOLATION		128	; use the interpolation routine

; bits
define	VX_FORMAT_INTERPOLATION_BIT	7
define	VX_FORMAT_UNPACK_UV_BIT		6
define	VX_FORMAT_UNIFORM_MIX_BIT	5

; default
define	VX_FORMAT_TEXTURE		21 or VX_FORMAT_INTERPOLATION or VX_FORMAT_UNPACK_UV
define	VX_FORMAT_TEXTURE_VERTEX	21 or VX_FORMAT_INTERPOLATION	; use UV from vertex shader
define	VX_FORMAT_GOURAUD		16 or VX_FORMAT_INTERPOLATION
define	VX_FORMAT_COLOR			16

; stream header ;

define	VX_STREAM_HEADER_SIZE 		4
define	VX_STREAM_HEADER_COUNT		1
define	VX_STREAM_HEADER_OPTION		0	; stream options

define	VX_STREAM_OPTION_AABB		8
define	VX_STREAM_OPTION_MATRIX		64
;define	VX_STREAM_HEADER_FORMAT_MASK	00011111b

define	VX_STREAM_END			1

; image format ;

define	VX_IMAGE_ZX7_COMPRESSED		10000000b
define	VX_IMAGE_RLE_COMPRESSED		01000000b
define	VX_IMAGE_UNCOMPRESSED		00100000b
define	VX_IMAGE_PAGE			$D30000

; animation ;

define	VX_ANIMATION_MATRIX_COUNT	0
define	VX_ANIMATION_MATRIX_DATA	1

; type constant ;

define	VX_MATRIX_SIZE			18
define	VX_MATRIX_C0			0
define	VX_MATRIX_C1			1
define	VX_MATRIX_C2			2
define	VX_MATRIX_C3			3
define	VX_MATRIX_C4			4
define	VX_MATRIX_C5			5
define	VX_MATRIX_C6			6
define	VX_MATRIX_C7			7
define	VX_MATRIX_C8			8
define	VX_MATRIX_TX			9
define	VX_MATRIX_TY			12
define	VX_MATRIX_TZ			15

define	VX_LIGHT_SIZE			15
define	VX_LIGHT_VECTOR			0
define	VX_LIGHT_AMBIENT		3
define	VX_LIGHT_POW			4
define	VX_LIGHT_PARAM			5
define	VX_LIGHT_POSITION		6
define	VX_LIGHT_POINT			1
define	VX_LIGHT_INFINITE		2
define	VX_LIGHT_POINT_BIT		0
define	VX_LIGHT_INFINITE_BIT		1


define	VX_VECTOR_LONG_SIZE		9
define	VX_VECTOR_WORD_SIZE		6
define	VX_VECTOR_BYTE_SIZE		3
define	VX_VECTOR_BX			0
define	VX_VECTOR_BY			1
define	VX_VECTOR_BZ			2
define	VX_VECTOR_WX			0
define	VX_VECTOR_WY			2
define	VX_VECTOR_WZ			4
define	VX_VECTOR_LX			0
define	VX_VECTOR_LY			3
define	VX_VECTOR_LZ			6

define	VX_ANIMATION_MATRIX_SIZE	18
define	VX_ANIMATION_MATRIX_C0		0
define	VX_ANIMATION_MATRIX_C1		1
define	VX_ANIMATION_MATRIX_C2		2
define	VX_ANIMATION_MATRIX_C3		3
define	VX_ANIMATION_MATRIX_C4		4
define	VX_ANIMATION_MATRIX_C5		5
define	VX_ANIMATION_MATRIX_C6		6
define	VX_ANIMATION_MATRIX_C7		7
define	VX_ANIMATION_MATRIX_C8		8
define	VX_ANIMATION_MATRIX_TX		9
define	VX_ANIMATION_MATRIX_TY		12
define	VX_ANIMATION_MATRIX_TZ		15

define	VX_BYTE_STRIDE			1
define	VX_WORD_STRIDE			2
define	VX_LONG_STRIDE			3

define	_OS_FLAGS			$D00080
; standard defines ;

; location of the mipmap level
define	VX_TEXTURE			$D30000
define	VX_TEXTURE_MIPMAP		$D28000

; the align macro from fasmg

define align? align

align?.count = 0

calminstruction align?.assume? address*, alignment*
	local index, symbol
	compute address, address
	compute alignment, alignment
	check address relativeto 0
	jyes absolute
	compute index, 0
    find:
	check index = align.count
	jyes update
	arrange symbol, align.=address#index
	check address relativeto symbol
	jyes update
	compute index, index + 1
	jump find
    update:
	arrange symbol, align.=address#index
	publish symbol, address
	arrange symbol, align.=alignment#index
	publish symbol, alignment
	compute align.count, align.count + 1
	exit
    absolute:
	check address mod alignment = 0
	jyes ok
	arrange symbol, =err 'false assumption about absolute address'
	assemble symbol
    ok:
end calminstruction

calminstruction align? alignment*, filler:rb
	local index, address, offset
	compute offset, 0
	match alignment | offset, alignment
	compute alignment, alignment
	check alignment >= 0
	jyes alignment_ok
	arrange symbol, =err 'invalid alignment value'
	assemble symbol
	exit
    alignment_ok:
	compute address, $
	check address relativeto 0
	jyes align
	compute index, 0
    find:
	check index = align.count
	jyes fail
	arrange symbol, align.=address#index
	check address relativeto symbol
	jyes found
	compute index, index + 1
	jump find
    found:
	compute address, address - symbol
	arrange symbol, align.=alignment#index
	check symbol > 0 & symbol mod alignment = 0
	jyes align
    fail:
	arrange symbol, =err 'variable portion of the address is not aligned enough'
	assemble symbol
	exit
    align:
	compute alignment, (alignment-1) - (address-offset+alignment-1) mod alignment
	arrange alignment, filler alignment
	assemble alignment
end calminstruction

macro relocate? address*
	rel.source? = $
	rel.destination? = address
	org rel.destination?
	macro end?.relocate?
		rel.length? = $ - rel.destination?
		org rel.source? + rel.length?
		purge end?.relocate?
	end macro
end macro
define	nan	0
define	inf	0
