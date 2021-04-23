if $ <> $D00000
 include 'include/fasmg/ez80.inc'
 include 'vsl.inc'
 org	$D00000
end if

 align 65536
VX_LUT_CONVOLVE:
 db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 db	0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33,32,32,32,32,32,33,33,33
 db	0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33,32,32,32,32,33,33,33,33
 db	0,0,0,0,1,1,1,2,0,0,0,0,1,1,1,2,0,0,0,0,1,1,1,2,0,8,8,8,9,9,9,10,0,0,0,0,1,1,1,2,0,0,0,0,1,1,1,2,0,0,0,0,1,1,1,2,0,8,8,8,9,9,9,10,0,0,0,1,1,1,1,2,0,0,0,1,1,1,1,2,0,0,0,1,1,1,1,2,0,8,8,9,9,9,9,10,0,0,0,1,1,1,2,2,32,32,32,33,33,33,34,34,32,32,32,33,33,33,34,34,32,40,40,41,41,41,42,42,32,32,32,33,33,33,34,34,32,32,32,33,33,33,34,34,32,32,32,33,33,33,34,34,32,40,40,41,41,41,42,42,32,32,32,33,33,33,34,34,32,32,32,33,33,33,34,34,32,32,32,33,33,33,34,34,32,40,40,41,41,41,42,42,32,32,32,33,33,33,34,34,64,64,64,65,65,65,66,66,64,64,64,65,65,65,66,66,64,72,72,73,73,73,74,74,64,64,64,65,65,65,66,66,64,64,64,65,65,65,66,66,64,64,64,65,65,65,66,66,64,72,72,73,73,73,74,74
 db	0,0,0,1,1,1,2,2,0,0,0,1,1,1,2,2,0,0,0,1,1,9,10,10,8,8,8,9,9,9,10,10,0,0,0,1,1,1,2,2,0,0,0,1,1,1,2,2,0,0,0,1,1,9,10,10,8,8,8,9,9,9,10,10,0,0,0,1,1,1,2,2,0,0,0,1,1,1,2,2,0,0,0,1,1,9,10,10,40,40,40,41,41,41,42,42,32,32,32,33,33,34,34,34,32,32,32,33,33,34,34,34,32,32,32,33,33,42,42,42,40,40,40,41,41,42,42,42,32,32,32,33,33,34,34,34,32,32,32,33,33,34,34,34,32,32,32,33,33,42,42,42,40,40,40,41,41,42,42,42,32,32,32,33,33,34,34,34,64,64,64,65,65,66,66,66,64,64,64,65,65,74,74,74,72,72,72,73,73,74,74,74,64,64,65,65,65,66,66,66,64,64,65,65,65,66,66,66,64,64,65,65,65,74,74,74,72,72,73,73,73,74,74,74,64,64,65,65,65,66,66,66,64,64,65,65,65,66,66,66,64,64,65,65,65,74,74,74,72,72,73,73,73,74,74,74
 db	0,0,0,1,1,2,2,3,0,0,0,1,1,2,2,3,0,0,8,9,9,10,10,11,8,8,8,9,9,10,10,11,0,0,0,1,1,2,2,3,0,0,0,1,1,2,2,3,0,0,8,9,9,10,10,11,8,8,8,9,9,10,10,11,0,0,0,1,1,2,2,3,32,32,32,33,33,34,34,35,32,32,40,41,41,42,42,43,40,40,40,41,41,42,42,43,32,32,33,33,33,34,34,35,32,32,33,33,33,34,34,35,32,32,41,41,41,42,42,43,40,40,41,41,41,42,42,43,32,32,33,33,33,34,34,35,32,32,33,33,33,34,34,35,64,64,73,73,73,74,74,75,72,72,73,73,73,74,74,75,64,64,65,65,66,66,66,67,64,64,65,65,66,66,66,67,64,64,73,73,74,74,74,75,72,72,73,73,74,74,74,75,64,64,65,65,66,66,66,67,64,64,65,65,66,66,66,67,64,64,73,73,74,74,74,75,104,104,105,105,106,106,106,107,96,96,97,97,98,98,99,99,96,96,97,97,98,98,99,99,96,96,105,105,106,106,107,107,104,104,105,105,106,106,107,107
 db	0,0,1,1,2,2,3,3,0,0,1,1,2,2,3,3,8,8,9,9,10,10,11,11,8,8,9,9,10,10,11,11,0,0,1,1,2,2,3,3,0,0,1,1,2,2,3,3,8,8,9,9,10,10,11,11,8,8,9,9,10,10,11,11,32,32,33,33,34,34,35,35,32,32,33,33,34,34,35,35,40,40,41,41,42,42,43,43,40,40,41,41,42,42,43,43,32,32,33,33,34,34,35,35,32,32,33,33,34,34,35,35,40,40,41,41,42,42,43,43,40,40,41,41,42,42,43,43,64,64,65,65,66,66,67,67,64,64,65,65,66,66,67,67,72,72,73,73,74,74,75,75,72,72,73,73,74,74,75,75,64,64,65,65,66,66,67,67,64,64,65,65,66,66,67,67,72,72,73,73,74,74,75,75,72,72,73,73,74,74,75,75,96,96,97,97,98,98,99,99,96,96,97,97,98,98,99,99,104,104,105,105,106,106,107,107,104,104,105,105,106,106,107,107,96,96,97,97,98,98,99,99,96,96,97,97,98,98,99,99,104,104,105,105,106,106,107,107,104,104,105,105,106,106,107,107
 db	0,0,1,1,2,2,3,3,0,0,1,1,2,2,11,11,8,8,9,9,10,10,11,11,8,8,9,9,18,18,19,19,0,0,1,1,2,2,3,4,0,0,1,1,2,2,11,12,8,8,9,9,10,10,11,12,40,40,41,41,50,50,51,52,32,32,33,33,34,34,35,36,32,32,33,33,34,34,43,44,40,40,41,41,42,42,43,44,40,40,41,41,50,50,51,52,32,32,33,33,34,35,35,36,32,32,33,33,34,35,43,44,72,72,73,73,74,75,75,76,72,72,73,73,82,83,83,84,64,64,65,65,66,67,67,68,64,64,65,65,66,67,75,76,72,72,73,73,74,75,75,76,72,72,73,73,82,83,83,84,64,64,65,66,66,67,67,68,96,96,97,98,98,99,107,108,104,104,105,106,106,107,107,108,104,104,105,106,114,115,115,116,96,96,97,98,98,99,99,100,96,96,97,98,98,99,107,108,104,104,105,106,106,107,107,108,104,104,105,106,114,115,115,116,128,129,129,130,130,131,131,132,128,129,129,130,130,131,139,140,136,137,137,138,138,139,139,140,136,137,137,138,146,147,147,148
 db	0,0,1,1,2,3,3,4,0,0,1,1,2,11,11,12,8,8,9,9,10,11,11,12,8,16,17,17,18,19,19,20,0,0,1,1,2,3,3,4,0,0,1,1,2,11,11,12,8,8,9,9,10,11,11,12,40,48,49,49,50,51,51,52,32,32,33,34,34,35,35,36,32,32,33,34,34,43,43,44,40,40,41,42,42,43,43,44,40,48,49,50,50,51,51,52,32,32,33,34,34,35,36,36,64,64,65,66,66,75,76,76,72,72,73,74,74,75,76,76,72,80,81,82,82,83,84,84,64,64,65,66,66,67,68,68,64,64,65,66,66,75,76,76,72,72,73,74,74,75,76,76,104,112,113,114,114,115,116,116,96,97,97,98,98,99,100,100,96,97,97,98,98,107,108,108,104,105,105,106,106,107,108,108,104,113,113,114,114,115,116,116,96,97,97,98,99,99,100,100,128,129,129,130,131,139,140,140,136,137,137,138,139,139,140,140,136,145,145,146,147,147,148,148,128,129,129,130,131,131,132,132,128,129,129,130,131,139,140,140,136,137,137,138,139,139,140,140,136,145,145,146,147,147,148,148
 db	0,0,1,2,2,3,4,4,0,0,1,2,10,11,12,12,8,8,9,10,10,11,12,20,16,16,17,18,18,19,20,20,0,0,1,2,2,3,4,4,0,0,1,2,10,11,12,12,40,40,41,42,42,43,44,52,48,48,49,50,50,51,52,52,32,32,33,34,34,35,36,37,32,32,33,34,42,43,44,45,40,40,41,42,42,43,44,53,48,48,49,50,50,51,52,53,64,64,65,66,67,67,68,69,64,64,65,66,75,75,76,77,72,72,73,74,75,75,76,85,80,80,81,82,83,83,84,85,64,65,65,66,67,67,68,69,96,97,97,98,107,107,108,109,104,105,105,106,107,107,108,117,112,113,113,114,115,115,116,117,96,97,97,98,99,99,100,101,96,97,97,98,107,107,108,109,104,105,105,106,107,107,108,117,144,145,145,146,147,147,148,149,128,129,129,130,131,131,132,133,128,129,129,130,139,139,140,141,136,137,137,138,139,139,140,149,144,145,145,146,147,147,148,149,128,129,129,130,131,132,132,133,160,161,161,162,171,172,172,173,168,169,169,170,171,172,172,181,176,177,177,178,179,180,180,181
 db	0,0,1,2,3,3,4,5,0,0,1,10,11,11,12,13,8,8,9,10,11,19,20,21,16,16,17,18,19,19,20,21,0,0,1,2,3,3,4,5,0,0,1,10,11,11,12,13,40,40,41,42,43,51,52,53,48,48,49,50,51,51,52,53,32,32,33,34,35,35,36,37,32,32,33,42,43,43,44,45,40,40,41,42,43,51,52,53,80,80,81,82,83,83,84,85,64,65,65,66,67,68,68,69,64,65,65,74,75,76,76,77,72,73,73,74,75,84,84,85,80,81,81,82,83,84,84,85,96,97,97,98,99,100,100,101,96,97,97,106,107,108,108,109,104,105,105,106,107,116,116,117,112,113,113,114,115,116,116,117,96,97,97,98,99,100,101,101,128,129,129,138,139,140,141,141,136,137,137,138,139,148,149,149,144,145,145,146,147,148,149,149,128,129,130,130,131,132,133,133,128,129,130,138,139,140,141,141,168,169,170,170,171,180,181,181,176,177,178,178,179,180,181,181,160,161,162,162,163,164,165,165,160,161,162,170,171,172,173,173,168,169,170,170,171,180,181,181,176,177,178,178,179,180,181,181
 db	0,0,1,2,3,4,4,5,0,0,9,10,11,12,12,13,8,8,9,10,19,20,20,21,16,16,17,18,19,28,28,29,0,0,1,2,3,4,5,5,32,32,41,42,43,44,45,45,40,40,41,42,51,52,53,53,48,48,49,50,51,60,61,61,32,33,33,34,35,36,37,37,32,33,41,42,43,44,45,45,72,73,73,74,83,84,85,85,80,81,81,82,83,92,93,93,64,65,65,66,67,68,69,70,64,65,73,74,75,76,77,78,72,73,73,74,83,84,85,86,112,113,113,114,115,124,125,126,96,97,98,98,99,100,101,102,96,97,106,106,107,108,109,110,104,105,106,106,115,116,117,118,112,113,114,114,115,124,125,126,128,129,130,130,131,132,133,134,128,129,138,138,139,140,141,142,136,137,138,138,147,148,149,150,144,145,146,146,147,156,157,158,160,161,162,163,163,164,165,166,160,161,170,171,171,172,173,174,168,169,170,171,179,180,181,182,176,177,178,179,179,188,189,190,160,161,162,163,164,164,165,166,192,193,202,203,204,204,205,206,200,201,202,203,212,212,213,214,208,209,210,211,212,220,221,222
 db	0,0,1,2,3,4,5,6,0,8,9,10,11,12,13,14,8,8,17,18,19,20,21,22,16,16,17,26,27,28,29,30,0,0,1,2,3,4,5,6,32,40,41,42,43,44,45,46,40,40,49,50,51,52,53,54,48,48,49,58,59,60,61,62,32,33,33,34,35,36,37,38,64,73,73,74,75,76,77,78,72,73,81,82,83,84,85,86,80,81,81,90,91,92,93,94,64,65,66,66,67,68,69,70,64,73,74,74,75,76,77,78,104,105,114,114,115,116,117,118,112,113,114,122,123,124,125,126,96,97,98,99,99,100,101,102,96,105,106,107,107,108,109,110,136,137,146,147,147,148,149,150,144,145,146,155,155,156,157,158,128,129,130,131,132,132,133,134,128,137,138,139,140,140,141,142,136,137,146,147,148,148,149,150,176,177,178,187,188,188,189,190,160,161,162,163,164,165,165,166,160,169,170,171,172,173,173,174,168,169,178,179,180,181,181,182,208,209,210,219,220,221,221,222,192,193,194,195,196,197,198,198,192,201,202,203,204,205,206,206,200,201,210,211,212,213,214,214,208,209,210,219,220,221,222,222
 db	0,0,1,2,3,4,5,6,0,8,9,10,11,12,13,14,8,16,17,18,19,20,21,22,16,24,25,26,27,28,29,30,0,1,2,2,3,4,5,6,32,41,42,42,43,44,45,46,40,49,50,50,51,52,53,54,48,57,58,58,59,60,61,62,32,33,34,35,36,36,37,38,64,73,74,75,76,76,77,78,72,81,82,83,84,84,85,86,80,89,90,91,92,92,93,94,64,65,66,67,68,69,70,71,96,105,106,107,108,109,110,111,104,113,114,115,116,117,118,119,112,121,122,123,124,125,126,127,96,97,98,99,100,101,102,103,128,137,138,139,140,141,142,143,136,145,146,147,148,149,150,151,144,153,154,155,156,157,158,159,128,129,130,131,132,133,134,135,160,169,170,171,172,173,174,175,168,177,178,179,180,181,182,183,176,185,186,187,188,189,190,191,160,161,162,163,164,165,166,167,192,201,202,203,204,205,206,207,200,209,210,211,212,213,214,215,208,217,218,219,220,221,222,223,192,193,194,195,196,197,198,199,224,233,234,235,236,237,238,239,232,241,242,243,244,245,246,247,240,249,250,251,252,253,254,255
 db	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255
 db	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,23,16,17,18,19,20,21,30,31,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,55,48,49,50,51,52,53,62,63,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,87,80,81,82,83,84,85,94,95,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,119,112,113,114,115,116,117,126,127,152,153,154,155,156,157,158,159,128,129,130,131,132,133,135,135,136,137,138,139,140,141,143,151,144,145,146,147,148,149,159,159,184,185,186,187,188,189,191,191,160,161,162,163,164,166,167,167,168,169,170,171,172,174,175,183,208,209,210,211,212,214,223,223,216,217,218,219,220,222,223,223,192,193,194,196,197,198,199,199,200,201,202,204,205,206,207,215,240,241,242,244,245,246,255,255,248,249,250,252,253,254,255,255,224,225,227,228,229,230,231,231,232,233,235,236,237,238,239,247,240,241,243,244,245,246,255,255,248,249,251,252,253,254,255,255
 db	0,1,2,3,4,5,6,15,8,9,10,11,12,13,22,23,16,17,18,19,20,29,30,31,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,47,40,41,42,43,44,45,54,55,48,49,50,51,52,61,62,63,88,89,90,91,92,93,94,95,64,65,66,67,68,69,71,79,72,73,74,75,76,77,87,87,80,81,82,83,84,93,95,95,120,121,122,123,124,125,127,127,96,97,98,99,100,102,103,111,104,105,106,107,108,110,119,119,144,145,146,147,148,158,159,159,152,153,154,155,156,158,159,159,128,129,130,131,133,134,135,143,136,137,138,139,141,142,151,151,176,177,178,179,181,190,191,191,184,185,186,187,189,190,191,191,160,161,162,164,165,166,167,175,200,201,202,204,205,206,215,215,208,209,210,212,213,222,223,223,216,217,218,220,221,222,223,223,192,193,195,196,197,198,199,207,232,233,235,236,237,238,247,247,240,241,243,244,245,254,255,255,248,249,251,252,253,254,255,255,224,226,227,228,229,230,231,239,232,234,235,236,237,238,247,247,240,242,243,244,245,254,255,255,248,250,251,252,253,254,255,255
 db	0,1,2,3,4,6,7,15,8,9,10,11,12,14,23,23,16,17,18,19,28,30,31,31,24,25,26,27,28,30,31,31,32,33,34,35,36,38,39,47,40,41,42,43,44,46,55,55,48,49,50,51,60,62,63,63,88,89,90,91,92,94,95,95,64,65,66,67,69,70,71,79,72,73,74,75,77,78,87,87,112,113,114,115,125,126,127,127,120,121,122,123,125,126,127,127,96,97,98,100,101,102,103,111,104,105,106,108,109,110,119,119,144,145,146,148,157,158,159,159,152,153,154,156,157,158,159,159,128,129,131,132,133,134,135,143,168,169,171,172,173,174,183,183,176,177,179,180,189,190,191,191,184,185,187,188,189,190,191,191,192,193,195,196,197,198,199,207,200,201,203,204,205,206,215,215,208,209,211,212,221,222,223,223,248,249,251,252,253,254,255,255,224,226,227,228,229,230,231,239,232,234,235,236,237,238,247,247,240,242,243,244,253,254,255,255,248,250,251,252,253,254,255,255,225,226,227,228,229,231,231,239,233,234,235,236,237,239,247,247,241,242,243,244,253,255,255,255,249,250,251,252,253,255,255,255
 db	0,1,2,3,5,6,7,15,8,9,10,11,13,22,23,23,16,17,18,27,29,30,31,31,24,25,26,27,29,30,31,31,32,33,34,35,37,38,39,47,40,41,42,43,45,54,55,55,48,49,50,59,61,62,63,63,88,89,90,91,93,94,95,95,64,65,66,68,69,70,71,79,72,73,74,76,77,86,87,87,112,113,114,124,125,126,127,127,120,121,122,124,125,126,127,127,96,97,99,100,101,102,103,111,136,137,139,140,141,150,151,151,144,145,147,156,157,158,159,159,152,153,155,156,157,158,159,159,160,161,163,164,165,166,167,175,168,169,171,172,173,182,183,183,176,177,179,188,189,190,191,191,216,217,219,220,221,222,223,223,192,194,195,196,197,199,199,207,200,202,203,204,205,215,215,215,240,242,243,252,253,255,255,255,248,250,251,252,253,255,255,255,224,226,227,228,230,231,231,239,232,234,235,236,238,247,247,247,240,242,243,252,254,255,255,255,248,250,251,252,254,255,255,255,225,226,227,228,230,231,231,239,233,234,235,236,238,247,247,247,241,242,243,252,254,255,255,255,249,250,251,252,254,255,255,255
 db	0,1,2,3,5,6,15,15,8,9,10,11,21,22,23,23,16,17,26,27,29,30,31,31,24,25,26,27,29,30,31,31,32,33,34,36,37,38,47,47,40,41,42,44,53,54,55,55,80,81,90,92,93,94,95,95,88,89,90,92,93,94,95,95,64,65,66,68,69,70,79,79,104,105,106,108,117,118,119,119,112,113,122,124,125,126,127,127,120,121,122,124,125,126,127,127,128,129,131,132,133,135,143,143,136,137,139,140,149,151,151,151,144,145,155,156,157,159,159,159,184,185,187,188,189,191,191,191,160,161,163,164,165,167,175,175,168,169,171,172,181,183,183,183,208,209,219,220,221,223,223,223,216,217,219,220,221,223,223,223,192,194,195,196,198,199,207,207,232,234,235,236,246,247,247,247,240,242,251,252,254,255,255,255,248,250,251,252,254,255,255,255,224,226,227,228,230,231,239,239,232,234,235,236,246,247,247,247,240,242,251,252,254,255,255,255,248,250,251,252,254,255,255,255,225,226,227,229,230,231,239,239,233,234,235,237,246,247,247,247,241,242,251,253,254,255,255,255,249,250,251,253,254,255,255,255
 db	0,1,2,4,5,6,15,15,8,9,10,12,21,22,23,23,16,25,26,28,29,30,31,31,56,57,58,60,61,62,63,63,32,33,34,36,37,39,47,47,40,41,42,44,53,55,55,55,80,89,90,92,93,95,95,95,88,89,90,92,93,95,95,95,64,65,67,68,69,71,79,79,104,105,107,108,117,119,119,119,112,121,123,124,125,127,127,127,120,121,123,124,125,127,127,127,128,129,131,132,134,135,143,143,136,137,139,140,150,151,151,151,144,153,155,156,158,159,159,159,184,185,187,188,190,191,191,191,160,162,163,164,166,167,175,175,200,202,203,204,214,215,215,215,208,218,219,220,222,223,223,223,216,218,219,220,222,223,223,223,224,226,227,229,230,231,239,239,232,234,235,237,246,247,247,247,240,250,251,253,254,255,255,255,248,250,251,253,254,255,255,255,225,226,227,229,230,231,239,239,233,234,235,237,246,247,247,247,241,250,251,253,254,255,255,255,249,250,251,253,254,255,255,255,225,226,227,229,230,231,239,239,233,234,235,237,246,247,247,247,241,250,251,253,254,255,255,255,249,250,251,253,254,255,255,255
 db	0,1,2,4,5,7,15,15,8,9,10,20,21,23,23,23,16,25,26,28,29,31,31,31,56,57,58,60,61,63,63,63,32,33,35,36,38,39,47,47,40,41,43,52,54,55,55,55,80,89,91,92,94,95,95,95,88,89,91,92,94,95,95,95,64,65,67,68,70,71,79,79,104,105,107,116,118,119,119,119,112,121,123,124,126,127,127,127,152,153,155,156,158,159,159,159,128,129,131,132,134,135,143,143,136,137,139,148,150,151,151,151,176,185,187,188,190,191,191,191,184,185,187,188,190,191,191,191,160,162,163,165,166,167,175,175,200,202,203,213,214,215,215,215,208,218,219,221,222,223,223,223,248,250,251,253,254,255,255,255,224,226,227,229,230,231,239,239,232,234,235,245,246,247,247,247,240,250,251,253,254,255,255,255,248,250,251,253,254,255,255,255,225,226,227,229,230,231,239,239,233,234,235,245,246,247,247,247,241,250,251,253,254,255,255,255,249,250,251,253,254,255,255,255,225,226,228,229,231,231,239,239,233,234,236,245,247,247,247,247,241,250,252,253,255,255,255,255,249,250,252,253,255,255,255,255
 db	0,1,3,4,6,7,15,15,8,9,11,20,22,23,23,23,24,25,27,28,30,31,31,31,56,57,59,60,62,63,63,63,32,33,35,36,38,39,47,47,40,41,43,52,54,55,55,55,88,89,91,92,94,95,95,95,88,89,91,92,94,95,95,95,96,97,99,100,102,103,111,111,104,105,107,116,118,119,119,119,120,121,123,124,126,127,127,127,152,153,155,156,158,159,159,159,128,130,131,133,134,135,143,143,168,170,171,181,182,183,183,183,184,186,187,189,190,191,191,191,184,186,187,189,190,191,191,191,192,194,195,197,198,199,207,207,200,202,203,213,214,215,215,215,216,218,219,221,222,223,223,223,248,250,251,253,254,255,255,255,224,226,227,229,231,231,239,239,232,234,235,245,247,247,247,247,248,250,251,253,255,255,255,255,248,250,251,253,255,255,255,255,225,226,228,229,231,231,239,239,233,234,236,245,247,247,247,247,249,250,252,253,255,255,255,255,249,250,252,253,255,255,255,255,225,226,228,229,231,231,239,239,233,234,236,245,247,247,247,247,249,250,252,253,255,255,255,255,249,250,252,253,255,255,255,255
 db	0,1,3,4,6,15,15,15,8,9,19,20,22,23,23,31,24,25,27,28,30,31,31,31,56,57,59,60,62,63,63,63,32,33,35,36,38,47,47,47,72,73,83,84,86,87,87,95,88,89,91,92,94,95,95,95,88,89,91,92,94,95,95,95,96,97,99,101,102,111,111,111,104,105,115,117,118,119,119,127,152,153,155,157,158,159,159,159,152,153,155,157,158,159,159,159,128,130,131,133,134,143,143,143,168,170,179,181,182,183,183,191,184,186,187,189,190,191,191,191,216,218,219,221,222,223,223,223,192,194,195,197,199,207,207,207,200,202,211,213,215,215,215,223,248,250,251,253,255,255,255,255,248,250,251,253,255,255,255,255,224,226,228,229,231,239,239,239,232,234,244,245,247,247,247,255,248,250,252,253,255,255,255,255,248,250,252,253,255,255,255,255,225,226,228,229,231,239,239,239,233,234,244,245,247,247,247,255,249,250,252,253,255,255,255,255,249,250,252,253,255,255,255,255,225,226,228,230,231,239,239,239,233,234,244,246,247,247,247,255,249,250,252,254,255,255,255,255,249,250,252,254,255,255,255,255
 db	0,1,3,4,6,15,15,15,8,9,19,20,22,23,23,31,24,25,27,28,30,31,31,31,56,57,59,60,62,63,63,63,32,33,35,37,38,47,47,47,72,73,83,85,86,87,87,95,88,89,91,93,94,95,95,95,88,89,91,93,94,95,95,95,96,98,99,101,103,111,111,111,104,106,115,117,119,119,119,127,152,154,155,157,159,159,159,159,152,154,155,157,159,159,159,159,160,162,163,165,167,175,175,175,168,170,179,181,183,183,183,191,184,186,187,189,191,191,191,191,216,218,219,221,223,223,223,223,192,194,196,197,199,207,207,207,232,234,244,245,247,247,247,255,248,250,252,253,255,255,255,255,248,250,252,253,255,255,255,255,225,226,228,229,231,239,239,239,233,234,244,245,247,247,247,255,249,250,252,253,255,255,255,255,249,250,252,253,255,255,255,255,225,226,228,230,231,239,239,239,233,234,244,246,247,247,247,255,249,250,252,254,255,255,255,255,249,250,252,254,255,255,255,255,225,227,228,230,231,239,239,239,233,235,244,246,247,247,247,255,249,251,252,254,255,255,255,255,249,251,252,254,255,255,255,255
 db	0,1,3,5,6,15,15,15,8,9,19,21,22,23,31,31,24,25,27,29,30,31,31,31,56,57,59,61,62,63,63,63,32,33,35,37,39,47,47,47,72,73,83,85,87,87,95,95,88,89,91,93,95,95,95,95,120,121,123,125,127,127,127,127,96,98,99,101,103,111,111,111,104,106,115,117,119,119,127,127,152,154,155,157,159,159,159,159,152,154,155,157,159,159,159,159,160,162,164,165,167,175,175,175,168,170,180,181,183,183,191,191,216,218,220,221,223,223,223,223,216,218,220,221,223,223,223,223,192,194,196,197,199,207,207,207,232,234,244,245,247,247,255,255,248,250,252,253,255,255,255,255,248,250,252,253,255,255,255,255,225,226,228,230,231,239,239,239,233,234,244,246,247,247,255,255,249,250,252,254,255,255,255,255,249,250,252,254,255,255,255,255,225,226,228,230,231,239,239,239,233,234,244,246,247,247,255,255,249,250,252,254,255,255,255,255,249,250,252,254,255,255,255,255,225,227,228,230,231,239,239,239,233,235,244,246,247,247,255,255,249,251,252,254,255,255,255,255,249,251,252,254,255,255,255,255
 db	0,1,3,5,7,15,15,15,8,17,19,21,23,23,31,31,24,25,27,29,31,31,31,31,56,57,59,61,63,63,63,63,32,33,35,37,39,47,47,47,72,81,83,85,87,87,95,95,88,89,91,93,95,95,95,95,120,121,123,125,127,127,127,127,96,98,99,101,103,111,111,111,136,146,147,149,151,151,159,159,152,154,155,157,159,159,159,159,152,154,155,157,159,159,159,159,160,162,164,165,167,175,175,175,168,178,180,181,183,183,191,191,216,218,220,221,223,223,223,223,216,218,220,221,223,223,223,223,224,226,228,230,231,239,239,239,232,242,244,246,247,247,255,255,248,250,252,254,255,255,255,255,248,250,252,254,255,255,255,255,225,226,228,230,231,239,239,239,233,242,244,246,247,247,255,255,249,250,252,254,255,255,255,255,249,250,252,254,255,255,255,255,225,227,228,230,231,239,239,239,233,243,244,246,247,247,255,255,249,251,252,254,255,255,255,255,249,251,252,254,255,255,255,255,225,227,229,230,231,239,239,239,233,243,245,246,247,247,255,255,249,251,253,254,255,255,255,255,249,251,253,254,255,255,255,255
 db	0,1,3,5,7,15,15,15,8,17,19,21,23,31,31,31,24,25,27,29,31,31,31,31,56,57,59,61,63,63,63,63,32,34,35,37,39,47,47,47,72,82,83,85,87,95,95,95,88,90,91,93,95,95,95,95,120,122,123,125,127,127,127,127,96,98,100,101,103,111,111,111,136,146,148,149,151,159,159,159,152,154,156,157,159,159,159,159,184,186,188,189,191,191,191,191,160,162,164,166,167,175,175,175,200,210,212,214,215,223,223,223,216,218,220,222,223,223,223,223,216,218,220,222,223,223,223,223,224,226,228,230,231,239,239,239,232,242,244,246,247,255,255,255,248,250,252,254,255,255,255,255,248,250,252,254,255,255,255,255,225,226,228,230,231,239,239,239,233,242,244,246,247,255,255,255,249,250,252,254,255,255,255,255,249,250,252,254,255,255,255,255,225,227,229,230,231,239,239,239,233,243,245,246,247,255,255,255,249,251,253,254,255,255,255,255,249,251,253,254,255,255,255,255,225,227,229,231,231,239,239,239,233,243,245,247,247,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255
 db	0,1,3,5,7,15,15,15,8,17,19,21,23,31,31,31,24,25,27,29,31,31,31,31,56,57,59,61,63,63,63,63,32,34,36,37,39,47,47,47,72,82,84,85,87,95,95,95,88,90,92,93,95,95,95,95,120,122,124,125,127,127,127,127,96,98,100,102,103,111,111,111,136,146,148,150,151,159,159,159,152,154,156,158,159,159,159,159,184,186,188,190,191,191,191,191,160,162,164,166,167,175,175,175,200,210,212,214,215,223,223,223,216,218,220,222,223,223,223,223,248,250,252,254,255,255,255,255,224,226,228,230,231,239,239,239,232,242,244,246,247,255,255,255,248,250,252,254,255,255,255,255,248,250,252,254,255,255,255,255,225,227,228,230,231,239,239,239,233,243,244,246,247,255,255,255,249,251,252,254,255,255,255,255,249,251,252,254,255,255,255,255,225,227,229,231,231,239,239,239,233,243,245,247,247,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255,225,227,229,231,231,239,239,239,233,243,245,247,247,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255
 db	0,1,3,5,7,15,15,15,8,17,19,21,23,31,31,31,24,25,27,29,31,31,31,31,56,57,59,61,63,63,63,63,32,34,36,38,39,47,47,47,72,82,84,86,87,95,95,95,88,90,92,94,95,95,95,95,120,122,124,126,127,127,127,127,96,98,100,102,103,111,111,111,136,146,148,150,151,159,159,159,152,154,156,158,159,159,159,159,184,186,188,190,191,191,191,191,160,162,164,166,167,175,175,175,200,210,212,214,215,223,223,223,216,218,220,222,223,223,223,223,248,250,252,254,255,255,255,255,224,226,228,230,231,239,239,239,232,242,244,246,247,255,255,255,248,250,252,254,255,255,255,255,248,250,252,254,255,255,255,255,225,227,229,231,231,239,239,239,233,243,245,247,247,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255,225,227,229,231,231,239,239,239,233,243,245,247,247,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255,225,227,229,231,231,239,239,239,233,243,245,247,247,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255
 db	0,2,4,6,15,15,15,15,16,18,20,22,31,31,31,31,56,58,60,62,63,63,63,63,56,58,60,62,63,63,63,63,64,66,68,70,79,79,79,79,80,82,84,86,95,95,95,95,120,122,124,126,127,127,127,127,120,122,124,126,127,127,127,127,128,130,132,134,143,143,143,143,144,146,148,150,159,159,159,159,184,186,188,190,191,191,191,191,184,186,188,190,191,191,191,191,192,194,196,198,207,207,207,207,208,210,212,214,223,223,223,223,248,250,252,254,255,255,255,255,248,250,252,254,255,255,255,255,225,227,229,231,239,239,239,239,241,243,245,247,255,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255,225,227,229,231,239,239,239,239,241,243,245,247,255,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255,225,227,229,231,239,239,239,239,241,243,245,247,255,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255,225,227,229,231,239,239,239,239,241,243,245,247,255,255,255,255,249,251,253,255,255,255,255,255,249,251,253,255,255,255,255,255

 align	1024
VX_VIEW_MLTX:
 rb	256
VX_VIEW_MLTY:
 rb	256
VX_VIEW_MLTZ:
 rb	256 
; free span
 rb	256

 align 512
VX_LUT_SIN:
 dw 0
 dw 101
 dw 201
 dw 302
 dw 402
 dw 503
 dw 603
 dw 704
 dw 804
 dw 904
 dw 1005
 dw 1105
 dw 1205
 dw 1306
 dw 1406
 dw 1506
 dw 1606
 dw 1706
 dw 1806
 dw 1906
 dw 2006
 dw 2105
 dw 2205
 dw 2305
 dw 2404
 dw 2503
 dw 2603
 dw 2702
 dw 2801
 dw 2900
 dw 2999
 dw 3098
 dw 3196
 dw 3295
 dw 3393
 dw 3492
 dw 3590
 dw 3688
 dw 3786
 dw 3883
 dw 3981
 dw 4078
 dw 4176
 dw 4273
 dw 4370
 dw 4467
 dw 4563
 dw 4660
 dw 4756
 dw 4852
 dw 4948
 dw 5044
 dw 5139
 dw 5235
 dw 5330
 dw 5425
 dw 5520
 dw 5614
 dw 5708
 dw 5803
 dw 5897
 dw 5990
 dw 6084
 dw 6177
 dw 6270
 dw 6363
 dw 6455
 dw 6547
 dw 6639
 dw 6731
 dw 6823
 dw 6914
 dw 7005
 dw 7096
 dw 7186
 dw 7276
 dw 7366
 dw 7456
 dw 7545
 dw 7635
 dw 7723
 dw 7812
 dw 7900
 dw 7988
 dw 8076
 dw 8163
 dw 8250
 dw 8337
 dw 8423
 dw 8509
 dw 8595
 dw 8680
 dw 8765
 dw 8850
 dw 8935
 dw 9019
 dw 9102
 dw 9186
 dw 9269
 dw 9352
 dw 9434
 dw 9516
 dw 9598
 dw 9679
 dw 9760
 dw 9841
 dw 9921
 dw 10001
 dw 10080
 dw 10159
 dw 10238
 dw 10316
 dw 10394
 dw 10471
 dw 10549
 dw 10625
 dw 10702
 dw 10778
 dw 10853
 dw 10928
 dw 11003
 dw 11077
 dw 11151
 dw 11224
 dw 11297
 dw 11370
 dw 11442
 dw 11514
 dw 11585
 dw 11656
 dw 11727
 dw 11797
 dw 11866
 dw 11935
 dw 12004
 dw 12072
 dw 12140
 dw 12207
 dw 12274
 dw 12340
 dw 12406
 dw 12472
 dw 12537
 dw 12601
 dw 12665
 dw 12729
 dw 12792
 dw 12854
 dw 12916
 dw 12978
 dw 13039
 dw 13100
 dw 13160
 dw 13219
 dw 13279
 dw 13337
 dw 13395
 dw 13453
 dw 13510
 dw 13567
 dw 13623
 dw 13678
 dw 13733
 dw 13788
 dw 13842
 dw 13896
 dw 13949
 dw 14001
 dw 14053
 dw 14104
 dw 14155
 dw 14206
 dw 14256
 dw 14305
 dw 14354
 dw 14402
 dw 14449
 dw 14497
 dw 14543
 dw 14589
 dw 14635
 dw 14680
 dw 14724
 dw 14768
 dw 14811
 dw 14854
 dw 14896
 dw 14937
 dw 14978
 dw 15019
 dw 15059
 dw 15098
 dw 15137
 dw 15175
 dw 15213
 dw 15250
 dw 15286
 dw 15322
 dw 15357
 dw 15392
 dw 15426
 dw 15460
 dw 15493
 dw 15525
 dw 15557
 dw 15588
 dw 15619
 dw 15649
 dw 15679
 dw 15707
 dw 15736
 dw 15763
 dw 15791
 dw 15817
 dw 15843
 dw 15868
 dw 15893
 dw 15917
 dw 15941
 dw 15964
 dw 15986
 dw 16008
 dw 16029
 dw 16049
 dw 16069
 dw 16088
 dw 16107
 dw 16125
 dw 16143
 dw 16160
 dw 16176
 dw 16192
 dw 16207
 dw 16221
 dw 16235
 dw 16248
 dw 16261
 dw 16273
 dw 16284
 dw 16295
 dw 16305
 dw 16315
 dw 16324
 dw 16332
 dw 16340
 dw 16347
 dw 16353
 dw 16359
 dw 16364
 dw 16369
 dw 16373
 dw 16376
 dw 16379
 dw 16381
 dw 16383
 dw 16384

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
