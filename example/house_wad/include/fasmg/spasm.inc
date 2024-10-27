macro .org? address*
	org address
end macro
macro .block? size*
	rb? size
end macro
macro .fill? size*, value:?
	db? size dup? value
end macro
macro .db? data&
	db? data
end macro
macro .byte? data&
	db? data
end macro
macro .dw? data&
	dw? data
end macro
macro .word? data&
	dw? data
end macro
macro .dl? data&
	dl? data
end macro
macro .long? data&
	dl? data
end macro
struc .equ? value
	. =: value
end struc
macro .echo? first*, rest&
	if 0 eqtype first
		repeat 1, int:first
			display `int
		end repeat
	else
		display first
	end if
	match any, rest
		.echo? any
	else
		display 13, 10
	end match
end macro
macro .error? text&
	err? text
end macro
macro .list?
end macro
macro .nolist?
end macro
macro .end?
	macro ?! line&
	end macro
end macro
macro #comment?
	macro ?! line&
		match #=endcomment?, line
			purge ?
		end match
	end macro
end macro
macro #define? line&
	rmatch name value, line
		redefine name (value)
	else rmatch name, line
		redefine name
	end rmatch
end macro
macro #undef? name*
	restore name
end macro
macro #undefine? name*
	restore name
end macro
macro #ifdef? name&
	local save
	if defined save | ~ defined name
		redefine save
	end if
	if ~ defined save
end macro
macro #ifndef? name&
	local save
	if defined save | ~ defined name
		redefine save
end macro
macro #elif?! cond&
	else if cond
end macro
macro #endif?!
	end if
end macro
macro #endmacro?!
	esc end macro
end macro
