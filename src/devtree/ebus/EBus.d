#include "<df>/dragonfruit.h"
#include "<inc>/a3x.h"

extern BuildDMA
extern BuildPBoard
extern BuildKinnow3

procedure BuildEBus (* -- *)
	DeviceNew
		"ebus" DSetName

		BuildDMA
		BuildPBoard
		BuildKinnow3
	DeviceExit
end

(* find first board of id *)
procedure EBusFindFirstBoard (* id -- slot *)
	auto id
	id!

	auto i
	0 i!

	while (i@ EBusSlots <)
		auto bp
		i@ EBusSlotSpace * EBusSlotsStart + bp!

		if (bp@@ EBusBoardMagic ==)
			if (bp@ 4 + @ id@ ==)
				i@ return
			end
		end

		1 i@ + i!
	end

	ERR return
end

procedure EBusSlotInterruptRegister (* handler slot -- *)
	0x98 + InterruptRegister
end