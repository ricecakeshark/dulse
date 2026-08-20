module kelp_core.input.state.keyboard_state;

import kelp_core.input;
import kelp_core.core.container.ring_buffer;

//import std.sumtype;
import core.time : MonoTime;

class Keyboard
{
	RingBuffer!(KeyboardState, 5) state_list;

	invariant
	{
		assert(this !is null);
	}

	void initialize()
	{
		this.state_list.fill();
		return;
	}

	void finalize()
	{
		return;
	}

	void process()
	{
		this.state_list.append(KeyboardState.init);
		return;
	}

	void apply(in Event[] event_list...) pure nothrow
	{
		this.state_list.tail.apply(event_list);

		return;
	}

	bool pressed(Scancode scancode)
	{
		return this.state_list[$ - 1].pressed(scancode);
	}

	bool released(Scancode scancode)
	{
		return this.state_list[$ - 1].pressed(scancode);
	}

	bool pressed_just(Scancode scancode)
	{
		return (this.state_list[$ - 1].pressed(scancode) && !this.state_list[$ - 2].pressed(
				scancode));
	}

	bool released_just(Scancode scancode)
	{
		return (!this.state_list[$ - 1].pressed(scancode) && this.state_list[$ - 2].pressed(
				scancode));
	}
}

struct KeyboardState
{
	uint id;
	KeyboardKeyState[Scancode.max + 1] state_dict;

	bool pressed(Scancode scancode)
	{
		return this.state_dict[scancode].downed;
	}
}

struct KeyboardKeyState
{
	bool downed;
	MonoTime time;
}

KeyboardState apply(ref KeyboardState state, in Event[] event_list...) pure nothrow
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

KeyboardState apply(ref KeyboardState state, in Event event) pure nothrow
{
	scope KeyboardKeyEvent key_event = event.get!KeyboardKeyEvent;
	switch (event.type.minor)
	{
	case EventTypeMinor.keyboard_key:
		state.state_dict[key_event.scancode].time = event.time;
		state.apply(event.get!KeyboardKeyEvent);
		return state;
	default:
		return state;
	}
	return state;
}

KeyboardState apply(ref KeyboardState state, in KeyboardKeyEvent key_event) pure nothrow
{
	if (state.state_dict[key_event.scancode].downed != key_event.downed)
	{
		state.state_dict[key_event.scancode].downed = key_event.downed;
	}
	return state;
}
