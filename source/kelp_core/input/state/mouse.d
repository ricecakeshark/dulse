module kelp_core.input.state.mouse;

import kelp_core.input.event.event;
import kelp_core.input.event.mouse;
import kelp_core.input.device.mouse;
import kelp_core.math : Vector;

struct MouseState
{
	uint id;
	MouseButtonState[MouseButton.max + 1] button;
	Vector!(2, float) pos;
	Vector!(2, float) rel_pos;
}

struct MouseButtonState
{
	bool pressed;
	bool pressed_just;
	bool released_just;

	this(this) pure nothrow @safe
	{
		this.pressed_just = false;
		this.released_just = false;
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
	state.button[button_event.type].pressed = button_event.pressed;
	if (button_event.pressed)
	{
		state.button[button_event.type].pressed_just = true;
	}
	else
	{
		state.button[button_event.type].released_just = true;
	}

	return state;
}
