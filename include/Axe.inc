;########################
;#    Axiom Helpers     #
;########################

AXM_HEADER      =$C0DE
AXM_END         =$0000

AXM_NOSTUB      =%00000001
AXM_ION         =%00000010
AXM_MOS         =%00000100
AXM_DCS         =%00001000
AXM_APP         =%00010000
AXM_FUSION      =%00100000
AXM_SHELLS      =%00101110
AXM_NONAPP      =%00101111
AXM_ALL         =%00111111

AXM_INLINE      =%00000000
AXM_SUB         =%00000001
AXM_RMOD        =%00000010
AXM_RRMOD       =%00000100
AXM_STORED      =%00001000
AXM_DATA        =%00010000

AXM_0ARGS       =0
AXM_1ARGS       =1
AXM_2ARGS       =2
AXM_3ARGS       =3
AXM_4ARGS       =4
AXM_5ARGS       =5
AXM_6ARGS       =6

#define REP_NEXT    .db $7F \ .org $-1
#define REP_NEXT(x) .db $40 \ .db x \ .org $-2
#define ABS_NEXT    .db $49 \ .org $-1

;############################
;#     Axe Subroutines      #
;############################

sub_Mul         =$3F01
sub_Div         =$3F02
sub_Mod         =$3F03
sub_Pix         =$3F04
sub_Rand        =$3F05
sub_FastCpy     =$3F06
sub_OrSprite    =$3F07
sub_XorSprite   =$3F08
sub_OffSprite   =$3F09
sub_DrawInv     =$3F0A
sub_ShiftLeft   =$3F0B
sub_ShiftRight  =$3F0C
sub_ShiftUp     =$3F0D
sub_ShiftDown   =$3F0E
sub_DirectKey   =$3F0F
sub_FreqOut     =$3F10
sub_Sqrt        =$3F11
sub_GetCalc     =$3F12
sub_NewVar      =$3F13
sub_Unarc       =$3F14
sub_Arc         =$3F15
sub_Sin         =$3F16
sub_DispGS      =$3F17
sub_Line        =$3F18
sub_SDiv        =$3F19
sub_TextInt     =$3F1A
sub_4Lvl        =$3F1B
sub_SortD       =$3F1C
sub_EquStr      =$3F1D
sub_Mul88       =$3F1E
sub_Rect        =$3F1F
sub_Circle      =$3F20
sub_RectInv     =$3F21
sub_GetArc      =$3F22
sub_ReadArc     =$3F23
sub_CopyArc     =$3F24
sub_MskSprite   =$3F25
sub_GetByte     =$3F26
sub_SendByte    =$3F27
sub_RotC        =$3F28
sub_RotCC       =$3F29
sub_FlipH       =$3F2A
sub_FlipV       =$3F2B
sub_InData      =$3F2C
sub_Input       =$3F2D
sub_Nib1        =$3F2E
sub_Nib2        =$3F2F
sub_NibSto      =$3F30
sub_Length      =$3F31
sub_GetKeyVar   =$3F32
sub_DrawClr     =$3F33
sub_ToHex       =$3F34
sub_Safety      =$3F35
sub_DispApp     =$3F36
sub_TextApp     =$3F37
sub_Recip	=$3F38
sub_ChkSum	=$3F39
sub_MskSprite2	=$3F3A
sub_CallHL	=$3F3B
sub_DispGSClr	=$3F3C
sub_Disp4Clr	=$3F3D
sub_ReadArcApp	=$3F3E
sub_MulFull     =$3F3F
sub_GetSprite   =$3F40
sub_DrawBmp     =$3F41
sub_ArcTan      =$3F42
sub_Sqrt88      =$3F43
sub_GetKeyPause =$3F44
sub_NthStr      =$3F45
sub_Switch      =$3F46
sub_Div88	=$3F47
sub_DrawRcl	=$3F48
sub_HLine	=$3F49
sub_VLine	=$3F4A
sub_WHLine	=$3F4B
sub_IHLine	=$3F4C
sub_HLineShr	=$3F4D
sub_WVLine	=$3F4E
sub_IVLine	=$3F4F
sub_VLineShr	=$3F50
sub_WLine	=$3F51
sub_ILine	=$3F52
sub_LineShr	=$3F53
sub_WRect	=$3F54
;sub_IRect	=$3F21
sub_RectShr	=$3F55
sub_WCircle	=$3F56
sub_ICircle	=$3F57
;sub_CircleShr	=$3F58
sub_AndSprite	=$3F59

sub_Axiom1      =$3F60
sub_Axiom2      =$3F61
sub_Axiom3      =$3F62
sub_Axiom4      =$3F63
sub_Axiom5      =$3F64
sub_Axiom6      =$3F65
sub_Axiom7      =$3F66
sub_Axiom8      =$3F67
sub_Axiom9      =$3F68
sub_Axiom10     =$3F69
sub_Axiom11     =$3F6A
sub_Axiom12     =$3F6B
sub_Axiom13     =$3F6C
sub_Axiom14     =$3F6D
sub_Axiom15     =$3F6E
sub_Axiom16     =$3F6F
sub_Axiom17     =$3F70
sub_Axiom18     =$3F71
sub_Axiom19     =$3F72
sub_Axiom20     =$3F73
sub_Axiom21     =$3F74
sub_Axiom22     =$3F75
sub_Axiom23     =$3F76
sub_Axiom24     =$3F77
sub_Axiom25     =$3F78
sub_Axiom26     =$3F79
sub_Axiom27     =$3F7A
sub_Axiom28     =$3F7B
sub_Axiom29     =$3F7C
sub_Axiom30     =$3F7D
sub_Axiom31     =$3F7E
sub_Axiom32     =$3F7F

;############################
;#      Axe Variables       #
;############################

axv_A           =$9CFB
axv_B           =$9CFD
axv_C           =$9CFF
axv_D           =$9D01
axv_E           =$9D03
axv_F           =$9D05
axv_G           =$9D07
axv_H           =$9D09
axv_I           =$9D0B
axv_J           =$9D0D
axv_K           =$9D0F
axv_L           =$9D11
axv_M           =$9D13
axv_N           =$9D15
axv_O           =$9D17
axv_P           =$9D19
axv_Q           =$9D1B
axv_R           =$9D1D
axv_S           =$9D1F
axv_T           =$9D21
axv_U           =$9D23
axv_V           =$9D25
axv_W           =$9D27
axv_X           =$9D29
axv_Y           =$9D2B
axv_Z           =$9D2D
axv_Theta       =$9D2F

axv_R1          =$9D31
axv_R2          =$9D33
axv_R3          =$9D35
axv_R4          =$9D37
axv_R5          =$9D39
axv_R6          =$9D3B

axv_Y1          =$9D3D
axv_Y1Page      =$9D3F
axv_Y2          =$9D40
axv_Y2Page      =$9D42
axv_Y3          =$9D43
axv_Y3Page      =$9D45
axv_Y4          =$9D46
axv_Y4Page      =$9D48
axv_Y5          =$9D49
axv_Y5Page      =$9D4B
axv_Y6          =$9D4C
axv_Y6Page      =$9D4E
axv_Y7          =$9D4F
axv_Y7Page      =$9D51
axv_Y8          =$9D52
axv_Y8Page      =$9D54
axv_Y9          =$9D55
axv_Y9Page      =$9D57
axv_Y0          =$9D58
axv_Y0Page      =$9D5A

axv_RandSeed    =$9D5B

axv_SpriteBuff  =$9D5D

axv_Y1t         =$84EB
axv_Y2t         =$84ED
axv_X1t         =$84EF
axv_X2t         =$84F1
axv_Y3t         =$84F3
axv_Y4t         =$84F5
axv_X3t         =$84F7
axv_X4t         =$84F9
axv_Y5t         =$84FB
axv_Y6t         =$84FD
axv_X5t         =$84FF
axv_X6t         =$8501

;############################
;#    Axe RAM Locations     #
;############################

axr_L1          =$86EC          ;768 bytes
axr_L2          =$8A3A          ;531 bytes
axr_L3          =$9872          ;768 bytes
axr_L4          =$82A5          ;323 bytes
axr_L5          =$8508          ;128 bytes
axr_L6          =$9340          ;768 bytes

;##########################
;#     API Jump Table     #
;##########################

api_MainMenu    =$4083
api_CompileOP1  =$4086
api_TokenHook   =$4089

;###############################
;#     Other API Constants     #
;###############################

api_NoShell     =0
api_Ion         =1
api_MirageOS    =2
api_DoorsCS     =3
api_Application =4
api_Fusion	=5