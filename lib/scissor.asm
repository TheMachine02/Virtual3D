vxScissor:

.BOUNDING_BOX:
	db	0
	dl	0
	db	0
	dl	0
	db	0
	dl	0
	db	0
	dl	0

.box:
; compute a rectangular box based on a list of 4 vertices
	ret

.triangle_test:
; test a triangle (3 vertices) against the current box
	ret

	
.quad_test:
	ret
