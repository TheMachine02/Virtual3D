; Virtual-3D library, version 1.0
;
; Copyright (c) 2017 TheMachine02

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

define	OS__FLAGS           $D00080

include	"vxModel.inc"
include	"vxVSL.inc"

; standard defines ;
define VX_VERSION	$10
define VX_TRUE		$01
define VX_FALSE		$00

; geometry ;

; mesh ;

; maths ;

; RAM and VRAM ;

; color LCD ;

; batch ;

; depth test ;

; texture ;

; limits ;

; static variables ;

;.addinstr  ld a,hlu 3BF133E5 4

macro align bound
 rb bound-($ mod bound)
end macro

macro relocate addr
	oorg = $
	norg = addr
	org	addr
end macro

macro endrelocate
	org	$ - norg + oorg
end macro

; global compilation variable ;

define	VX_PS_1.0
define	VX_VS_1.0
define	VX_VS_1.x
define	VX_GS_1.0
