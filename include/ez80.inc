if ~definite ez80cmd
	include 'commands.alm'
	include 'ez80.alm'
; add extra instruction / special stuff here	
	calminstruction (var) strcalc? val
		compute val, val        ; compute expression
		arrange val, val        ; convert result to a decimal token
		stringify val           ; convert decimal token to string
		publish var, val
	end calminstruction
	ez80cmd:=0
end if
