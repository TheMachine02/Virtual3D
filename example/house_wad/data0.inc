include "include/fasmg/ez80.inc"
include "include/fasmg/tiformat.inc"

format ti archived appvar 'HOMEV'

LUT:
 db	5
 dl	.data0
 db	0
 dl	.data1
 db	0
 dl	.data2
 db	0
 dl	.data3
 db	0
 dl	.data4
 db	0
; dl	.data5
 db	0
; dl	.data6
 db	0
 
.data0:
include "file/dataRoom00.inc"
.data1:
include "file/dataRoom10.inc"
.data2:
include "file/dataRoom20.inc"
.data3:
include "file/dataRoom30.inc"
.data4:
include "file/dataRoom40.inc"
;.data5:
;include "file/dataRoom50.inc"
;.data6:
;include "file/dataRoom60.inc"
