include 'ez80.inc'
macro test jump, cond&
	local	lab
	jump	cond lab
lab:
	jump	cond lab
	jump	cond lab
end macro
iterate jump, jr, jp, jq
	iterate cond, <>, <nz, >, <z, >, <nc, >, <c, >
		test jump, cond
	end iterate
	if `jump <> 'jr'
		iterate cond, <po, >, <pe, >, <p, >, <m, >
			test jump, cond
		end iterate
	end if
end iterate
