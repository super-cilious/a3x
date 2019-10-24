#include "<df>/dragonfruit.h"
#include "<inc>/a3x.h"

const SerialCmdPort 0x10
const SerialDataPort 0x11

const SerialCmdWrite 1
const SerialCmdRead 2

procedure BuildCSerial (* -- *)
	DeviceNew
		"serial" DSetName

		pointerof SerialWrite "write" DAddMethod
		pointerof SerialRead "read" DAddMethod

		"serial" "type" DAddProperty
	DeviceExit
end

procedure SerialWrite { c -- }
	auto rs
	InterruptDisable rs!

	c@ SerialDataPort DCitronOutb
	SerialCmdWrite SerialCmdPort DCitronCommand

	rs@ InterruptRestore
end

procedure SerialRead { -- c }
	auto rs
	InterruptDisable rs!

	SerialCmdRead SerialCmdPort DCitronCommand
	SerialDataPort DCitronIni c!

	rs@ InterruptRestore

	if (c@ 0xFFFF ==)
		ERR c! return
	end
end