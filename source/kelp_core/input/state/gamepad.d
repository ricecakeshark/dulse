module kelp_core.input.state.gamepad;

import kelp_core.input.device.gamepad;
import kelp_core.input.event.event;
import kelp_core.input.event.gamepad_event;
import kelp_core.math.linalg.vector;

struct GamepadState
{
	public uint id;
	public GamepadType type;
	public GamepadButtonState[GamepadButton.max + 1] button;
	public GamepadTriggerState[GamepadTrigger.max + 1] trigger;
	public GamepadStickState[GamepadStick.max + 1] stick;

	bool pressed(in GamepadButton button) pure nothrow @nogc @safe
	{
		return this.button[button].pressed;
	}
}

struct GamepadButtonState
{
	public bool pressed;
	public bool pressed_just;
	public bool released_just;

	this(this) pure nothrow @nogc @safe
	{
		this.pressed_just = false;
		this.released_just = false;
		return;
	}
}

struct GamepadTriggerState
{
	Vector!(1) value;
	bool pressed;
}

struct GamepadStickState
{
	Vector!(2) value;
	bool pressed;
}

GamepadState apply(ref GamepadState state, in Event[] event_list...) pure nothrow
{
	foreach (event; event_list)
	{
		if (event.type.major == EventTypeMajor.gamepad)
		{
			state.apply(event);
		}
	}
	return state;
}

GamepadState apply(ref GamepadState state, in Event event) pure nothrow
{

	switch (event.type.minor)
	{
	case EventTypeMinor.gamepad_button:
		const scope GamepadButtonEvent button_event = event.get!GamepadButtonEvent;
		//state.button[button_event.type].time = event.time;
		state.apply(button_event);
		return state;
	case EventTypeMinor.gamepad_axis:
		const scope GamepadAxisEvent axis_event = event.get!GamepadAxisEvent;
		//state.axis[axis_event.type].time = event.time;
		state.apply(axis_event);
		return state;
	default:
		return state;
	}
	return state;
}

GamepadState apply(ref GamepadState state, in GamepadButtonEvent button_event) pure nothrow
{
	if (button_event.pressed == true)
	{
		state.button[button_event.type].pressed_just = true;
	}
	else
	{
		state.button[button_event.type].released_just = true;
	}
	return state;
}

GamepadState apply(ref GamepadState state, in GamepadAxisEvent axis_event) pure nothrow
{
	final switch (axis_event.type)
	{
	case GamepadAxis.left_x:
		state.stick[GamepadStick.left].value.x = axis_event.value[0];
		return state;
	case GamepadAxis.left_y:
		state.stick[GamepadStick.left].value.y = axis_event.value[0];
		return state;
	case GamepadAxis.right_x:
		state.stick[GamepadStick.right].value.x = axis_event.value[0];
		return state;
	case GamepadAxis.right_y:
		state.stick[GamepadStick.right].value.y = axis_event.value[0];
		return state;
	case GamepadAxis.trigger_left:
		state.trigger[GamepadTrigger.left].value[0] = axis_event.value[0];
		return state;
	case GamepadAxis.trigger_right:
		state.trigger[GamepadTrigger.right].value[0] = axis_event.value[0];
		return state;
	case GamepadAxis.none:
		assert(false);
	}
	assert(false);
}
