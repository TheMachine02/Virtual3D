include "include/fasmg/ez80.inc"
include "include/fasmg/tiformat.inc"

format ti archived appvar 'HOMEF'

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
; dl	.data6
 
.data0:
include "file/dataRoom01.inc"
.data1:
include "file/dataRoom11.inc"
.data2:
include "file/dataRoom21.inc"
.data3:
include "file/dataRoom31.inc"
.data4:
include "file/dataRoom41.inc"
;.data5:
;include "file/dataRoom51.inc"
;.data6:
;include "file/dataRoom61.inc"
