var BUIGCNode 0

var BUIScreenNode 0

var BUIWidth 0
var BUIHeight 0

var BUIRectP 0

const BUIBoxW 426
const BUIBoxH 144

var BUIX 0
var BUIY 0

procedure BUIRect (* x y w h color -- *)
	BUIScreenNode@ DeviceSelectNode
		BUIRectP@ Call
	DeviceExit
end

procedure BUIBox (* title x y w h -- *)
	auto h
	h!

	auto w
	w!

	auto y
	y!

	auto x
	x!

	auto title
	title!

	x@ y@ w@ h@ 0x0F BUIRect
	x@ 1 + y@ 1 + w@ h@ 25 BUIRect
	x@ 1 + y@ 1 + w@ 1 - h@ 1 - 29 BUIRect
	x@ 10 + y@ 20 + w@ 18 - h@ 28 - 0x0F BUIRect
	x@ 10 + y@ 20 + w@ 19 - h@ 29 - 25 BUIRect
	x@ 11 + y@ 21 + w@ 21 - h@ 31 - 0x0F BUIRect
	x@ 12 + y@ 22 + w@ 22 - h@ 32 - 29 BUIRect

	auto tw
	title@ strlen FontWidth * tw!

	x@ w@ 2 / tw@ 2 / - + y@ 5 + title@ -1 0 FontDrawString
end

procedure BUIConDef (* -- *)
	BUIGCNode@ DeviceSelectNode
		-1 -1 -1 -1 -1 -1 "setScreen" DCallMethod drop
	DeviceExit
end

procedure BUIABD (* -- *)
	"false" "auto-boot?" NVRAMSetVar
end

procedure BootUIAuto (* -- *)
	auto delay

	"boot-delay" NVRAMGetVar dup if (0 ==)
		drop "10000" "boot-delay" NVRAMSetVar
		"10000"
	end

	atoi delay!

	delay@ 1000 / "Starting the system in %d seconds with:\n" Printf

	auto bd
	"boot-dev" NVRAMGetVar bd!

	if (bd@ 0 ~=)
		bd@ "  boot-dev:\t%s\n" Printf
	end else
		"  boot-dev:\tnone specified\n" Printf
	end

	auto ba
	"boot-args" NVRAMGetVar ba!

	if (ba@ 0 ~=)
		ba@ "  boot-args:\t'%s'\n" Printf
	end else
		"  boot-args:\tnone specified\n" Printf
	end

	"[RETURN] Boot right now.\t[PERIOD] View more options.\n" Printf

	auto cn
	"/clock" DevTreeWalk cn!

	if (cn@ 0 ==)
		"no clock. " Printf
	end else
		auto i
		0 i!

		auto units
		delay@ 100 / units!

		while (i@ units@ <)
			cn@ DeviceSelectNode
				100 "wait" DCallMethod drop
			DeviceExit

			auto c
			Getc c!
			while (c@ ERR ~=)
				if (c@ '.' ==)
					"cancelled\n" Printf
					-1 i!
				end

				if (c@ '\n' ==)
					-2 i!
				end

				Getc c!
			end

			if (i@ 0 s<)
				break
			end

			if (i@ 10 % 0 ==)
				'.' Putc
			end

			i@ 1 + i!
		end
	end

	if (i@ -1 ==)
		BootUIOptions
		return
	end

	"proceeding\n" Printf

	auto r
	AutoBoot r!

	BUIConDef

	[r@]BootErrors@ " boot: %s\n" Printf
end

procedure BootUIMore (* -- *)
	auto ob
	2 Calloc ob!

	"[press ENTER] " Printf

	ob@ 0 Gets

	ob@ Free
end

procedure BootUIOptions (* -- *)
	auto buf
	256 Calloc buf!

	auto buf2

	while (1)
		"== BOOT OPTIONS == (or 'reset')\n" Printf
		"1. Boot the system\n" Printf
		"2. Exit to full screen ROM prompt\n" Printf
		"3. Modify boot device and arguments\n" Printf
		"4. Toggle auto boot and set boot delay\n" Printf
		"5. Print boot information\n" Printf

		"? " Printf

		buf@ 255 Gets

		if (buf@ "1" strcmp)
			auto r
			AutoBoot r!

			BUIConDef

			[r@]BootErrors@ " boot: %s\n" Printf

			buf@ Free

			return
		end

		if (buf@ "2" strcmp)
			BUIConDef

			buf@ Free

			return
		end

		if (buf@ "3" strcmp)
			auto mod
			0 mod!

			240 Calloc buf2!

			"Pressing ENTER with an empty line will preserve contents.\n" Printf

			auto bd
			"boot-dev" NVRAMGetVar bd!

			if (bd@ 0 ~=)
				bd@ "  boot-dev:\t'%s'\n" Printf
			end else
				"  boot-dev:\tnone specified\n" Printf
			end

			"  new     :\t" Printf

			buf2@ 239 Gets

			if (buf2@ strlen 0 >)
				buf2@ "boot-dev" NVRAMSetVar
				1 mod!
			end

			auto ba
			"boot-args" NVRAMGetVar ba!

			if (ba@ 0 ~=)
				ba@ "  boot-args:\t'%s'\n" Printf
			end else
				"  boot-args:\tnone specified\n" Printf
			end

			"  new      :\t" Printf

			buf2@ 239 Gets

			if (buf2@ strlen 0 >)
				buf2@ "boot-args" NVRAMSetVar
				1 mod!
			end

			if (mod@)
				"Machine will now reboot\n" Printf

				BootUIMore

				LateReset
			end

			buf2@ Free
		end

		if (buf@ "4" strcmp)
			8 Calloc buf2!

			"Pressing ENTER with an empty line will preserve contents.\n" Printf

			"auto-boot?" NVRAMGetVar bd!

			if (bd@ 0 ~=)
				bd@ "  auto-boot?:\t%s\n" Printf
			end

			"  new       :\t" Printf

			buf2@ 6 Gets

			if (buf2@ strlen 0 >)
				buf2@ "auto-boot?" NVRAMSetVar
			end

			"boot-delay" NVRAMGetVarNum ba!

			if (ba@ 0 ~=)
				ba@ 1000 / "  boot-delay:\t%d sec\n" Printf
			end

			"  new       :\t" Printf

			buf2@ 7 Gets

			if (buf2@ strlen 0 >)
				buf2@ atoi 1000 * "boot-delay" NVRAMSetVarNum
			end

			buf2@ Free
		end

		if (buf@ "5" strcmp)
			"boot-dev" NVRAMGetVar bd!

			if (bd@ 0 ~=)
				bd@ "  boot-dev:\t%s\n" Printf
			end else
				"  boot-dev:\tnone specified\n" Printf
			end

			"boot-args" NVRAMGetVar ba!

			if (ba@ 0 ~=)
				ba@ "  boot-args:\t'%s'\n" Printf
			end else
				"  boot-args:\tnone specified\n" Printf
			end

			"auto-boot?" NVRAMGetVar ba!

			if (ba@ 0 ~=)
				ba@ "  auto-boot?:\t%s\n" Printf
			end else
				"  auto-boot:\tnone specified\n" Printf
			end

			"boot-delay" NVRAMGetVarNum ba!

			if (ba@ 0 ~=)
				ba@ 1000 / "  boot-delay:\t%d sec\n" Printf
			end else
				"  boot-delay:\tnone specified\n" Printf
			end

			BootUIMore
		end

		if (buf@ "reset" strcmp)
			LateReset
		end
	end
end

procedure BootUI (* -- *)
	"boot-ui?" NVRAMGetVar dup if (0 ==)
		drop "true" "boot-ui?" NVRAMSetVar
		"true"
	end

	if ("true" strcmp ~~)
		return
	end

	"/gconsole" DevTreeWalk BUIGCNode!

	if (BUIGCNode@ 0 ==)
		return
	end

	"/screen" DevTreeWalk BUIScreenNode!

	if (BUIScreenNode@ 0 ==)
		return
	end

	BUIScreenNode@ DeviceSelectNode
		"rectangle" DGetMethod BUIRectP!

		"width" DGetProperty BUIWidth!
		"height" DGetProperty BUIHeight!

		"init" DCallMethod drop
	DeviceExit

	auto bbx
	BUIWidth@ 2 / BUIBoxW 2 / - bbx!

	auto bby
	BUIHeight@ 2 / BUIBoxH 2 / - bby!

	bbx@ BUIX!
	bby@ BUIY!

	"ANTECEDENT 3.x Firmware" bbx@ bby@ BUIBoxW BUIBoxH BUIBox

	BUIGCNode@ DeviceSelectNode
		0x00 29 bbx@ 26 + bby@ 37 + BUIBoxW 50 - BUIBoxH 60 - "setScreen" DCallMethod drop
	DeviceExit

	ConsoleUserOut

	"auto-boot?" NVRAMGetVar dup if (0 ==)
		drop "true" "auto-boot?" NVRAMSetVar
		"true"
	end

	if ("true" strcmp)
		BootUIAuto
	end else
		BootUIOptions
	end

	Monitor

	LateReset
end