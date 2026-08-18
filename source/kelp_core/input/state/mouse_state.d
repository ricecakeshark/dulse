module kelp_core.input.state.mouse_state;

import kelp_core.input;
import kelp_core.core.container.ring_buffer;
import kelp_core.math.linalg.vector;

class Mouse
{
	RingBuffer!(MouseState, 5) state_list;

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
		this.state_list.append(this.state_list[$ - 1]);
		return;
	}

	void apply(in Event[] event_list...) pure nothrow
	{
		this.state_list.tail.apply(event_list);
		return;
	}

	bool moved()
	{
		if (this.state_list.tail.rel_pos != Vec2(0f, 0f))
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	bool pressed(MouseButtonType button_type)
	{
		return this.state_list.tail.button[button_type].downed;
	}

	bool pressed_just(MouseButtonType button_type)
	{
		return this.state_list.tail.button[button_type].downed_just;
	}

	bool released(MouseButtonType button_type)
	{
		return !this.state_list.tail.button[button_type].downed;
	}

	bool released_just(MouseButtonType button_type)
	{
		return this.state_list.tail.button[button_type].uponed_just;
	}
}

struct MouseState
{
	MouseButtonState[MouseButtonType.max + 1] button;
	Vector!(2, float) pos;
	Vector!(2, float) rel_pos;
}

struct MouseButtonState
{
	bool downed;
	bool downed_just;
	bool uponed_just;

	this(this) pure nothrow @safe
	{
		this.downed_just = false;
		this.uponed_just = false;
		return;
	}
}

MouseState apply(ref MouseState state, in Event[] event_list...) pure nothrow
{
	foreach (event; event_list)
	{
		if (event.type.major == EventTypeMajor.mouse)
		{
			state.apply(event);
		}
	}
	return state;
}

MouseState apply(ref MouseState state, in Event event) pure nothrow
{
	//scope KeyboardKeyEvent key_event = event.get!KeyboardKeyEvent;
	switch (event.type.minor)
	{
	case EventTypeMinor.mouse_motion:
		//state.state_dict[key_event.scancode].time = event.time;
		state.apply(event.get!MouseMotionEvent);
		return state;
	case EventTypeMinor.mouse_button:
		state.apply(event.get!MouseButtonEvent);
		return state;
	default:
		return state;
	}
	return state;
}

MouseState apply(ref MouseState state, in MouseMotionEvent motion_event) pure nothrow
{
	state.pos = motion_event.pos;
	state.rel_pos = motion_event.delta;
	return state;
}

MouseState apply(ref MouseState state, in MouseButtonEvent button_event) pure nothrow
{
	state.button[button_event.type].downed = button_event.downed;
	if (button_event.downed)
	{
		state.button[button_event.type].downed_just = true;
	}
	else
	{
		state.button[button_event.type].uponed_just = true;
	}

	return state;
}
