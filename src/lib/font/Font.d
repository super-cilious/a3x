#include "<df>/dragonfruit.h"
#include "<inc>/a3x.h"

var FontScreenNode 0

var FontBBP 0

asm "

Font:
	.static cp881-16.bmp

"

procedure FontInit (* -- *)
	"/screen" DevTreeWalk FontScreenNode!
	if (FontScreenNode@ 0 ==)
		return
	end

	FontScreenNode@ DeviceSelectNode
		"blitBits" DGetMethod FontBBP!
	DeviceExit
end

procedure private FontBlitBits (* bpr fg bg bitd bmp x y w h -- *)
	FontScreenNode@ DeviceSelectNode
		FontBBP@ DCallMethodPtr
	DeviceExit
end

procedure FontDrawChar { x y char bg color -- }
	(* dont draw spaces *)
	if (char@ ' ' ==)
		return
	end

	auto bmp
	char@ FontBytesPerRow FontHeight * * pointerof Font + bmp!

	FontBytesPerRow color@ bg@ FontBitD bmp@ x@ y@ FontWidth FontHeight FontBlitBits
end

procedure FontDrawString { x y str bg color -- }
	auto sx
	x@ sx!

	auto c
	str@ gb c!

	while (c@ 0 ~=)
		if (c@ '\n' ==)
			y@ FontHeight + y!
			sx@ x!
		end else
			x@ y@ c@ bg@ color@ FontDrawChar

			x@ FontWidth + x!
		end

		1 str +=
		str@ gb c!
	end
end