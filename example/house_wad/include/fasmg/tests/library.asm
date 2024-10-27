include 'tiformat.inc'
format ti executable protected program 'LIBRARY'
source 'library.src'
library 'library.lib'
locate .libs at $D1A881
order .libs, .text
require _main
include 'ld.alm'
