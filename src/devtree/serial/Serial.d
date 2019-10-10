#include "<df>/dragonfruit.h"
#include "<inc>/a3x.h"

(* platform independent serial interface, antecedent standard *)

var SSerialNode 0

procedure GSerialDefault { -- defaultnode }
	"serial-dev" NVRAMGetVar dup if (0 ==)
		drop "/ebus/platformboard/citron/serial" "serial-dev" NVRAMSetVar
		"/ebus/platformboard/citron/serial"
	end

	DevTreeWalk defaultnode!

	if (defaultnode@ 0 ==)
		"/ebus/platformboard/citron/serial" "serial-dev" NVRAMSetVar
		"/ebus/platformboard/citron/serial" DevTreeWalk defaultnode!
	end
end

procedure BuildSerial (* -- *)
	GSerialDefault SSerialNode!

	if (SSerialNode@ 0 ~=)
		SSerialNode@ DeviceClone
			"serial" DSetName
		DeviceExit
	end
end