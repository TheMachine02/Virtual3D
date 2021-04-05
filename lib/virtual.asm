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

include	"vsl.inc"

; NOTE : memory map of the LUT and various data is here
virtual at VIRTUAL_BASE_RAM
	include 'bss.asm'
end virtual

; functions

vxEngine:
	jp	vxEngineEnd

vxEngineInit:
; get indic off
	call	ti.RunIndicOff
; disable interrupts
	di
	ld	a, $D0
	ld	MB, a
	ld	hl, $E00005
	ld	(hl), 2	; Set flash wait states to 5 + 2 = 7 (total access time = 8)
	call	ti.boot.ClearVRAM
; LCD init
	call	vxFramebufferSetup
; memory initialisation
	call	vxMemoryCreateDevice
; data initialisation
; 	ld	hl, VX_LUT_CONVOLVE_DATA
; 	ld	de, VX_LUT_CONVOLVE
; 	ld	bc, VX_LUT_CONVOLVE_SIZE
; 	ldir
; 	ld	hl, VX_LUT_SIN_DATA
; 	ld	de, VX_LUT_SIN
; 	ld	b, 2	; bc=VX_LUT_SIN_SIZE
; 	ldir
	call	vxMemoryImage
	ld	hl, VIRTUAL_NULL_RAM
	ld	de, VX_DEPTH_BUCKET_L
	ld	bc, 512*3
	ldir
	ld	de, VX_VERTEX_BUFFER
	ld	bc, VX_MAX_VERTEX * VX_VERTEX_SIZE
	ldir
; various other data
	ld	hl, VX_FRAMEBUFFER_AUX1
	ld	(vxPrimitiveQueue), hl
	ld	(vxGeometrySize), bc
	ld	hl, $D30000
	ld	(vxTexturePage), hl
; load shader
	ld	ix, vxPixelShader
	call	vxShaderLoad
; init timer
	call	vxTimer.init
; insert stack position
	ld	hl, vxEngineQuit
	ex	(sp), hl
	jp	(hl)
vxEngineQuit:
	ld	hl, $F50000
	ld	(hl), h	; Mode 0
	inc	l		; 0F50001h
	ld	(hl), 15	; Wait 15*256 APB cycles before scanning each row
	inc	l		; 0F50002h
	ld	(hl), h
	inc	l		; 0F50003h
	ld	(hl), 15	; Wait 15 APB cycles before each scan
	inc	l		; 0F50004h
	ld	(hl), 8	; Number of rows to scan
	inc	l		; 0F50005h
	ld	(hl), 8	; Number of columns to scan
	ld	iy, _OS_FLAGS
	call	vxFramebufferRestore
	call	vxMemoryDestroyDevice
	ld	hl, $E00005
	ld	(hl), 4	; Set flash wait states to 5 + 4 = 9 (total access time = 10)
	call	ti.HomeUp
	call	ti.ClrScrn
	call	ti.DrawStatusBar
	call	ti.RunIndicOn
	ei
	jp	ti.DrawBatteryIndicator

; memory backing function
	
vxMemoryCreateDevice:
	ld	hl, $D00000
	ld	(hl), $5A
	inc	hl
	ld	(hl), $A5
	dec	hl
	call	port_setup
	call	port_unlock
	ld	a, $3F
	call	vxMemorySafeErase
	ld	a, $3E
	call	vxMemorySafeErase
	ld	a, $3D
	call	vxMemorySafeErase
	ld	a, $3C
	call	vxMemorySafeErase
	ld	hl, VIRTUAL_BASE_RAM
	ld	de, $3C0000
	ld	bc, $40000
	call	ti.WriteFlash
; we leave the memory protection off BUT flash lock ON (for SHA256 acess)
	jp	port_privilege_lock
	
vxMemorySafeErase:
	ld	bc,$0000F8
	push	bc
	jp	ti.EraseFlashSector

vxMemoryDestroyDevice:
; restore RAM state
	ld	hl, $3C0000
	ld	de, $D00000
	ld	bc, $01887C
	ldir
; sps, spl stack aren't copied obviously
	ld	hl, $3DA881
	ld	de, $D1A881
	ld	bc, $02577F
	ldir
; unlock and re-lock the port
	call	port_setup
	call	port_unlock
	jp	port_lock

vxMemoryImage:
	ld	de, VIRTUAL_BASE_RAM
	ld	hl, .arch_image
	jp	lz4.decompress

.arch_image:
file	'image'
	
include	"ports.asm"
include	"lz4.asm"
include	"primitive.asm"
include	"pipeline.asm"
include	"image.asm"
include	"shader.asm"
include	"timer.asm"
include	"matrix.asm"
include	"quaternion.asm"
include	"vector.asm"
include	"framebuffer.asm"
include	"material.asm"
include	"assembly.asm"
include	"math.asm"
include	"mipmap.asm"
; TODO : remove data.inc
;include	"data.inc"

align 512
VX_LUT_INVERSE:
 dw 65534
 dw 65534
 dw 32767
 dw 21844
 dw 16383
 dw 13106
 dw 10922
 dw 9361
 dw 8191
 dw 7281
 dw 6553
 dw 5957
 dw 5460
 dw 5040
 dw 4680
 dw 4368
 dw 4095
 dw 3854
 dw 3640
 dw 3448
 dw 3276
 dw 3120
 dw 2978
 dw 2848
 dw 2730
 dw 2620
 dw 2520
 dw 2426
 dw 2340
 dw 2259
 dw 2184
 dw 2113
 dw 2047
 dw 1985
 dw 1927
 dw 1871
 dw 1819
 dw 1770
 dw 1724
 dw 1679
 dw 1637
 dw 1597
 dw 1559
 dw 1523
 dw 1488
 dw 1455
 dw 1424
 dw 1393
 dw 1364
 dw 1336
 dw 1310
 dw 1284
 dw 1259
 dw 1236
 dw 1213
 dw 1191
 dw 1169
 dw 1149
 dw 1129
 dw 1110
 dw 1091
 dw 1073
 dw 1056
 dw 1039
 dw 1023
 dw 1007
 dw 992
 dw 977
 dw 963
 dw 949
 dw 935
 dw 922
 dw 909
 dw 897
 dw 885
 dw 873
 dw 861
 dw 850
 dw 839
 dw 829
 dw 818
 dw 808
 dw 798
 dw 789
 dw 779
 dw 770
 dw 761
 dw 752
 dw 744
 dw 735
 dw 727
 dw 719
 dw 711
 dw 704
 dw 696
 dw 689
 dw 682
 dw 675
 dw 668
 dw 661
 dw 654
 dw 648
 dw 642
 dw 635
 dw 629
 dw 623
 dw 617
 dw 611
 dw 606
 dw 600
 dw 595
 dw 589
 dw 584
 dw 579
 dw 574
 dw 569
 dw 564
 dw 559
 dw 554
 dw 550
 dw 545
 dw 541
 dw 536
 dw 532
 dw 528
 dw 523
 dw 519
 dw 515
 dw 511
 dw 507
 dw 503
 dw 499
 dw 495
 dw 492
 dw 488
 dw 484
 dw 481
 dw 477
 dw 474
 dw 470
 dw 467
 dw 464
 dw 461
 dw 457
 dw 454
 dw 451
 dw 448
 dw 445
 dw 442
 dw 439
 dw 436
 dw 433
 dw 430
 dw 427
 dw 425
 dw 422
 dw 419
 dw 416
 dw 414
 dw 411
 dw 409
 dw 406
 dw 404
 dw 401
 dw 399
 dw 396
 dw 394
 dw 391
 dw 389
 dw 387
 dw 385
 dw 382
 dw 380
 dw 378
 dw 376
 dw 373
 dw 371
 dw 369
 dw 367
 dw 365
 dw 363
 dw 361
 dw 359
 dw 357
 dw 355
 dw 353
 dw 351
 dw 349
 dw 348
 dw 346
 dw 344
 dw 342
 dw 340
 dw 339
 dw 337
 dw 335
 dw 333
 dw 332
 dw 330
 dw 328
 dw 327
 dw 325
 dw 323
 dw 322
 dw 320
 dw 319
 dw 317
 dw 316
 dw 314
 dw 313
 dw 311
 dw 310
 dw 308
 dw 307
 dw 305
 dw 304
 dw 302
 dw 301
 dw 300
 dw 298
 dw 297
 dw 296
 dw 294
 dw 293
 dw 292
 dw 290
 dw 289
 dw 288
 dw 286
 dw 285
 dw 284
 dw 283
 dw 281
 dw 280
 dw 279
 dw 278
 dw 277
 dw 276
 dw 274
 dw 273
 dw 272
 dw 271
 dw 270
 dw 269
 dw 268
 dw 266
 dw 265
 dw 264
 dw 263
 dw 262
 dw 261
 dw 260
 dw 259
 dw 258
 dw 257
 dw 256
 dw 255
 dw 254
 dw 253
 dw 252
 dw 251
 dw 250
 dw 249
 dw 248
 dw 247
 dw 246
 dw 245
 dw 244
 dw 244
 dw 243
 dw 242
 dw 241
 dw 240
 dw 239
 dw 238
 dw 237
 dw 236
 dw 236
 dw 235
 dw 234
 dw 233
 dw 232
 dw 231
 dw 231
 dw 230
 dw 229
 dw 228
 dw 227
 dw 227
 dw 226
 dw 225
 dw 224
 dw 223
 dw 223
 dw 222
 dw 221
 dw 220
 dw 220
 dw 219
 dw 218
 dw 217
 dw 217
 dw 216
 dw 215
 dw 215
 dw 214
 dw 213
 dw 212
 dw 212
 dw 211
 dw 210
 dw 210
 dw 209
 dw 208
 dw 208
 dw 207
 dw 206
 dw 206
 dw 205
 dw 204
 dw 204
 dw 203

vxEngineEnd:
