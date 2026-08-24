module kelp_core.input.state.keyboard;

import kelp_core.input.device.keyboard;
import kelp_core.input.event.event;
import kelp_core.input.event.keyboard;
import core.time : MonoTime;

struct KeyboardState
{
	public uint id;
	public KeyboardKeyState[Scancode.max + 1] key_list;

	ref KeyboardKeyState opIndex(in Scancode scancode) return pure nothrow @nogc @safe
	in (scancode < key_list.length)
	{
		return this.key_list[scancode];
	}

	bool pressed(in Scancode scancode) const pure nothrow @nogc @safe
	{
		return this.key_list[scancode].pressed;
	}
}

struct KeyboardKeyState
{
	bool pressed, pressed_just, released_just;
	MonoTime time;

	this(this) pure nothrow @nogc @safe
	{
		this.pressed_just = false;
		this.released_just = false;
		return;
	}
}

KeyboardState apply(ref KeyboardState state, in Event[] event_list...) pure nothrow @nogc @safe
{
	foreach (event; event_list)
	{
		if (event.type.major == EventTypeMajor.keyboard)
		{
			state.apply(event);
		}
	}
	return state;
}

KeyboardState apply(ref KeyboardState state, in Event event) pure nothrow @nogc @safe
{
	scope KeyboardKeyEvent key_event = event.get!KeyboardKeyEvent;
	switch (event.type.minor)
	{
	case EventTypeMinor.keyboard_key:
		state.key_list[key_event.scancode].time = event.time;
		state.apply(event.get!KeyboardKeyEvent);
		return state;
	default:
		assert(false, "invalid minor event");
	}
	return state;
}

KeyboardState apply(ref KeyboardState state, in KeyboardKeyEvent key_event) pure nothrow @nogc @safe
{
	if (key_event.pressed)
	{
		state[key_event.scancode].pressed_just = true;
	}
	else
	{
		state[key_event.scancode].released_just = true;
	}
	return state;
}
