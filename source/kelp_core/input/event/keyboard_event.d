module kelp_core.input.event.keyboard_event;

import kelp_core.device;
import std.sumtype;

struct KeyboardEvent
{
	SumType!(
		KeyboardKeyEvent,
	) data;
}

struct KeyboardKeyEvent
{
	Scancode scancode;
	bool downed;
	bool repeated;
}
