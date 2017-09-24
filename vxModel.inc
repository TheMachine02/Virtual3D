#ifndef	VX_MODELGUARD
#define	VX_MODELGUARD

VX_VERTEX_BASE=0

#macro  vxVertex(x,y,z)
.dw x,y,z 
#endmacro
#define .v vxVertex(

#macro vxFace(i,j,k)
.dl i*16+VX_VERTEX_BASE
.dl j*16+VX_VERTEX_BASE
.dl k*16+VX_VERTEX_BASE
#endmacro
#define .f vxFace(

.org $0

#endif
