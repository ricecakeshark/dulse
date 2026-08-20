module kelp_core.input.state.gamepad_state;

import kelp_core.input;
import kelp_core.math.linalg.vector;
import kelp_core.core.container.ring_buffer;

class Gamepad
{
	RingBuffer!(GamepadState, 5) state_list;

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
		this.state_list.append(GamepadState.init);
		return;
	}

	void apply(in Event[] event_list...) pure nothrow
	{
		this.state_list.tail.apply(event_list);
		return;
	}

	bool pressed(GamepadButton button)
	{
		return this.state_list[$ - 1].pressed(button);
	}

	bool released(GamepadButton button)
	{
		return this.state_list[$ - 1].pressed(button);
	}

	bool pressed_just(GamepadButton button)
	{
		return (this.state_list[$ - 1].pressed(button) && !this.state_list[$ - 2].pressed(
				button));
	}

	bool released_just(GamepadButton button)
	{
		return (!this.state_list[$ - 1].pressed(button) && this.state_list[$ - 2].pressed(
				button));
	}
}

struct GamepadState
{
	uint id;
	GamepadType type;
	GamepadButtonState[GamepadButton.max + 1] button;
	GamepadTriggerState[GamepadTrigger.max + 1] trigger;
	GamepadStickState[GamepadStick.max + 1] stick;

	bool pressed(in GamepadButton button)
	{
		return this.button[button].downed;
	}
}

struct GamepadButtonState
{
	bool downed;
}

struct GamepadTriggerState
{
	Vector!(1) value;
	bool downed;
}

struct GamepadStickState
{
	Vector!(2) value;
	bool downed;
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
		debug
		{
			import std.stdio;

			writeln("gamepad state: gamepad_button");
		}
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
	if (state.button[button_event.type].downed != button_event.downed)
	{
		state.button[button_event.type].downed = button_event.downed;
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
