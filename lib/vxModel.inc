VX_VERTEX_BASE=0
define	VX_ANIMATION_BONE		32768

macro  .v x,y,z
 dw x,y,z 
end macro

macro .f i,j,k
 dl i*16+VX_VERTEX_BASE
 dl j*16+VX_VERTEX_BASE
 dl k*16+VX_VERTEX_BASE
end macro

org $0
