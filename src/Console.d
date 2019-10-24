#include "<df>/dragonfruit.h"
#include "<inc>/a3x.h"

var EarlyBufferPtr 0

var ConsoleOut 0
public ConsoleOut

var ConsoleIn 0
public ConsoleIn

var ConsoleOutMethod 0
public ConsoleOutMethod

var ConsoleInMethod 0
public ConsoleInMethod

var EarlyBuffer 0
const EarlyBufferSize 2048
var EarlyBufPtr 0
var EarlyBufSP 0
var EarlyCCount 0

var Early 1

var UserOut 0

procedure EarlyPut { c -- }
	c@ EarlyBuffer@ EarlyBufPtr@ EarlyBufferSize % + sb

	EarlyBufPtr@ 1 + EarlyBufPtr!

	if (EarlyBufPtr@ EarlyBufferSize >=)
		EarlyBufSP@ 1 + EarlyBufSP!
	end

	EarlyCCount@ 1 + EarlyBufferSize min EarlyCCount!
end

procedure DumpEarly (* -- *)
	0 Early!

	auto sp
	EarlyBufSP@ sp!

	auto i
	0 i!

	while (i@ EarlyCCount@ <)
		auto c
		EarlyBuffer@ sp@ EarlyBufferSize % + gb c!

		if (c@ 0 ~=)
			c@ Putc
		end

		sp@ 1 + sp!
		i@ 1 + i!
	end
end

procedure ConsoleSetIn { dn -- }
	dn@ ConsoleIn!

	if (dn@ 0 ==)
		0 ConsoleIn!
		0 ConsoleInMethod!
		return
	end

	dn@ DeviceSelectNode
		"read" DGetMethod ConsoleInMethod!
	DeviceExit
end

procedure ConsoleSetOut { dn -- }
	dn@ ConsoleOut!

	if (dn@ 0 ==)
		0 ConsoleOut!
		0 ConsoleOutMethod!
		return
	end

	dn@ DeviceSelectNode
		"write" DGetMethod ConsoleOutMethod!
	DeviceExit

	if (ConsoleOutMethod@ 0 ~=)
		DumpEarly
	end
end

procedure Putc { c -- }
	if (ConsoleOutMethod@ 0 ==)
		if (EarlyBuffer@ 0 ~=)
			c@ EarlyPut
		end

		return
	end

	ConsoleOut@ DeviceSelectNode
		c@ ConsoleOutMethod@ DCallMethodPtr
	DeviceExit
end

procedure Getc { -- c }
	if (ConsoleInMethod@ 0 ==) ERR return end

	ConsoleIn@ DeviceSelectNode
		ConsoleInMethod@ DCallMethodPtr c!
	DeviceExit
end

(* try to redirect stdout/stdin to /gconsole and /keyboard if these nodes exist *)
procedure ConsoleUserOut (* -- *)
	if (UserOut@)
		return
	end

	auto gcn
	"/gconsole" DevTreeWalk gcn!

	auto kbn
	"/keyboard" DevTreeWalk kbn!

	if (gcn@)
		gcn@ ConsoleSetOut

		if (kbn@)
			kbn@ ConsoleSetIn
		end

		1 UserOut!
	end
end

procedure ConsoleEarlyInit (* -- *)
	EarlyBufferSize Malloc EarlyBuffer!
end

procedure ConsoleInit (* -- *)
	auto co
	auto ci

	"console-stdout" NVRAMGetVar dup if (0 ==)
		drop "/serial" "console-stdout" NVRAMSetVar
		"/serial"
	end

	DevTreeWalk co!

	"console-stdin" NVRAMGetVar dup if (0 ==)
		drop "/serial" "console-stdin" NVRAMSetVar
		"/serial"
	end

	DevTreeWalk ci!

	co@ ConsoleSetOut
	ci@ ConsoleSetIn

	if (ConsoleOut@ 0 ==)
		"/serial" DevTreeWalk ConsoleSetOut
	end

	if (ConsoleIn@ 0 ==)
		"/serial" DevTreeWalk ConsoleSetIn
	end
end