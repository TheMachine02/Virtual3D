source 'global_first.src', 'global_second.src'
locate .text at $D1A881
require _first
include 'tiformat.inc'
format ti executable protected program 'GLOBAL'
include 'ld.alm'
