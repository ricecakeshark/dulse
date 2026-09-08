module dulse.input.event.keyboard;

import dulse.input.device;
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
	bool pressed;
	bool repeated;

	this(
		MonoTime time,
		Scancode scancode,
		bool pressed,
		bool repeated = false,
	) pure nothrow @nogc @safe
	{
		this.time = time;
		this.scancode = scancode;
		this.pressed = pressed;
		this.repeated = repeated;
		return;
	}
}
