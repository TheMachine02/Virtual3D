.nolist
#ifndef	VX_VSL_GUARD
#define	VX_VSL_GUARD

#include "ti84pce.inc"
#include "relocate.inc"

; standard define ;

#define	VX_PIXEL_SHADER			%00000001
#define	VX_PIXEL_SHADER_CODE		$E10010
#define	VX_PIXEL_SHADER_DATA		$D00000
#define	VX_PIXEL_SHADER_SIZE		64
#define	VX_PIXEL_SHADER_MAX_SIZE	38

#define	VX_VERTEX_SHADER			%00000010
#define	VX_VERTEX_SHADER_CODE		$E30800
#define	VX_VERTEX_SHADER_DATA		$E30800
#define	VX_VERTEX_SHADER_SIZE		1024
#define	VX_VERTEX_SHADER_MAX_SIZE	1024

#define	VX_GEOMETRY_SHADER		%00000100
#define	VX_GEOMETRY_SHADER_DATA	$E30800
#define	VX_GEOMETRY_SHADER_CODE	$E30800
#define	VX_GEOMETRY_SHADER_SIZE	1024

#define	VX_SHADER_TYPE			0
#define	VX_SHADER_SIZE			1
#define	VX_SHADER_DATA0			4
#define	VX_SHADER_DATA1			5
#define	VX_SHADER_CODE			6

; pixel shader register ;

#define	VX_REGISTER_SIZE			12
#define	VX_REGISTER0			0
#define	VX_REGISTER1			3
#define	VX_REGISTER2			6
#define	VX_REGISTER3			9

; cache data register (de) ;

#define	VX_VERTEX_SIZE		16
#define	VX_VERTEX_CODE		0
#define	VX_VERTEX_SY		1
#define	VX_VERTEX_SX		2
#define	VX_VERTEX_GPR0		4
#define	VX_VERTEX_GPR1		5
#define	VX_VERTEX_UNIFORM	6
#define	VX_VERTEX_RX		7
#define	VX_VERTEX_RY		10
#define	VX_VERTEX_RZ		13

; vertex input register (iy) ;

#define	VX_VERTEX_DATA_SIZE	9
#define	VX_VERTEX_POSITION	0
#define	VX_VERTEX_VX		0
#define	VX_VERTEX_VY		2
#define	VX_VERTEX_VZ		4
#define	VX_VERTEX_NORMAL		6
#define	VX_VERTEX_NX		6
#define	VX_VERTEX_NY		7
#define	VX_VERTEX_NZ		8

; global data input register (ix) ;

#define	VX_MATRIX0			0
#define	VX_MATRIX0_C0		0
#define	VX_MATRIX0_C1		1
#define	VX_MATRIX0_C2		2
#define	VX_MATRIX0_C3		3
#define	VX_MATRIX0_C4		4
#define	VX_MATRIX0_C5		5
#define	VX_MATRIX0_C6		6
#define	VX_MATRIX0_C7		7
#define	VX_MATRIX0_C8		8
#define	VX_MATRIX0_TX		9
#define	VX_MATRIX0_TY		12
#define	VX_MATRIX0_TZ		15

#define	VX_LIGHT0_VECTOR		18
#define	VX_LIGHT0_AMBIENT	21
#define	VX_LIGHT0_POW		22
#define	VX_LIGHT0_PARAM		23
#define	VX_LIGHT0_POSITION	24

; triangle input register ;

#define	VX_TRIANGLE_SIZE		16
#define	VX_TRIANGLE_INDEX	0
#define	VX_TRIANGLE_I0		0
#define	VX_TRIANGLE_I1		3
#define	VX_TRIANGLE_I2		6
#define	VX_TRIANGLE_COLOR	9
#define	VX_TRIANGLE_TEXTURE	10
#define	VX_TRIANGLE_UV0		10
#define	VX_TRIANGLE_UV1		12
#define	VX_TRIANGLE_UV2		14

; geometry out buffer register ;

#define	VX_GEOMETRY_SIZE		8
#define	VX_GEOMETRY_ID		0
#define	VX_GEOMETRY_INDEX	1
#define	VX_GEOMETRY_DEPTH	4

; geometry in buffer header ;

#define	VX_GEOMETRY_FORMAT	0
#define	VX_GEOMETRY_BUFFER	1

; stream header ;

#define	VX_STREAM_HEADER_SIZE 	3
#define	VX_STREAM_HEADER_OPTION	0
#define	VX_STREAM_HEADER_COUNT	1

#define	VX_STREAM_HEADER_BBOX		8
#define	VX_STREAM_HEADER_FORMAT_MASK	%00011111

; type constant ;

#define	VX_MATRIX_SIZE		18
#define	VX_MATRIX_C0		0
#define	VX_MATRIX_C1		1
#define	VX_MATRIX_C2		2
#define	VX_MATRIX_C3		3
#define	VX_MATRIX_C4		4
#define	VX_MATRIX_C5		5
#define	VX_MATRIX_C6		6
#define	VX_MATRIX_C7		7
#define	VX_MATRIX_C8		8
#define	VX_MATRIX_TX		9
#define	VX_MATRIX_TY		12
#define	VX_MATRIX_TZ		15

#define	VX_LIGHT_SIZE		12
#define	VX_LIGHT_VECTOR		0
#define	VX_LIGHT_AMBIENT		3
#define	VX_LIGHT_POW		4
#define	VX_LIGHT_PARAM		5
#define	VX_LIGHT_POSITION	6
#define	VX_LIGHT_POINT_BIT	0
#define	VX_LIGHT_INFINITE	1

#define	VX_VECTOR_LONG_SIZE	9
#define	VX_VECTOR_WORD_SIZE	6
#define	VX_VECTOR_BYTE_SIZE	3
#define	VX_VECTOR_BX		0
#define	VX_VECTOR_BY		1
#define	VX_VECTOR_BZ		2
#define	VX_VECTOR_WX		0
#define	VX_VECTOR_WY		2
#define	VX_VECTOR_WZ		4
#define	VX_VECTOR_LX		0
#define	VX_VECTOR_LY		3
#define	VX_VECTOR_LZ		6

#define	VX_ANIMATION_BONE			32768
#define	VX_ANIMATION_HEADER_SIZE		3
#define	VX_ANIMATION_HEADER_MAGIC		0
#define	VX_ANIMATION_HEADER_COUNT		2

#define	VX_ANIMATION_MATRIX_SIZE		15
#define	VX_ANIMATION_MATRIX_C0		0
#define	VX_ANIMATION_MATRIX_C1		1
#define	VX_ANIMATION_MATRIX_C2		2
#define	VX_ANIMATION_MATRIX_C3		3
#define	VX_ANIMATION_MATRIX_C4		4
#define	VX_ANIMATION_MATRIX_C5		5
#define	VX_ANIMATION_MATRIX_C6		6
#define	VX_ANIMATION_MATRIX_C7		7
#define	VX_ANIMATION_MATRIX_C8		8
#define	VX_ANIMATION_MATRIX_TX		9
#define	VX_ANIMATION_MATRIX_TY		11
#define	VX_ANIMATION_MATRIX_TZ		13

#endif
.list
