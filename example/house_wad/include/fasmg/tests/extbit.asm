include 'ez80.inc'
iterate inst, bit, res, set
	repeat 8, bit: 0
		iterate reg, b, c, d, e, h, l, (hl), a
			inst	bit, reg
		end iterate
	end repeat
	repeat 16, bit: 0
		iterate <hi,lo*>, b,c, d,e, h,l
			inst	bit, hi#lo
		end iterate
	end repeat
	inst -2048, (ix + $80)
	inst 2047, (iy - $80)
end iterate
