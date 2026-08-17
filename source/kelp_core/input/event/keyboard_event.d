module kelp_core.input.event.keyboard_event;

import kelp_core.device;
import std.sumtype;
import core.time : MonoTime;

struct KeyboardEvent
{
	SumType!(
		KeyboardKeyEvent,
	) data;
}

struct KeyboardKeyEvent
{
	MonoTime time;
	Scancode scancode;
	bool downed;
	bool repeated;

	this(
		MonoTime time,
		Scancode scancode,
		bool downed,
		bool repeated = false,
	)
	{
		this.time = time;
		this.scancode = scancode;
		this.downed = downed;
		this.repeated = repeated;
		return;
	}
}
