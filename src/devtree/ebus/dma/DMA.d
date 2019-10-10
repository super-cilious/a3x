#include "<df>/dragonfruit.h"
#include "<inc>/a3x.h"

(* ebus dma controller driver *)

procedure BuildDMA (* -- *)
	DeviceNew
		"dma" DSetName

		pointerof DMATransfer "transfer" DAddMethod
	DeviceExit

	DMAWaitUnbusy
	0 DMARegisterStatus!
end

procedure DMAWaitUnbusy (* -- *)
	while (DMARegisterStatus@ 1 &) end
end

procedure DMADoOperation (* -- *)
	DMARegisterStatus@ 1 | DMARegisterStatus!
end

procedure DMATransfer { src dest srcinc destinc count mode -- }
	src@ DMARegisterSource!
	dest@ DMARegisterDest!
	srcinc@ DMARegisterSInc!
	destinc@ DMARegisterDInc!
	count@ DMARegisterCount!
	mode@ DMARegisterMode!

	DMADoOperation
	DMAWaitUnbusy
end