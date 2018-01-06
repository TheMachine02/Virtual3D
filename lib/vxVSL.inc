.nolist
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

; pixel shader register ;

#define	VX_REGISTER_SIZE			12
#define	VX_REGISTER0			0
#define	VX_REGISTER1			3
#define	VX_REGISTER2			6
#define	VX_REGISTER3			9

; cache data register (de) ;

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
#define	VX_LIGHT0_AMBIANT	21
#define	VX_LIGHT0_POW		22
#define	VX_LIGHT0_POSITION	23

; vertex shader constant ;

#define	VX_VERTEX_SIZE		16
#define	VX_VERTEX_DATA_SIZE	9

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

#define	VX_LIGHT_SIZE		11
#define	VX_LIGHT_VECTOR		0
#define	VX_LIGHT_AMBIANT	3
#define	VX_LIGHT_POW		4
#define	VX_LIGHT_POSITION	5

.list
