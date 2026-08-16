module kelp_core.input.event.gamepad_event;

import kelp_core.device;
import kelp_core.math.linalg.vector;
import std.sumtype;

struct GamepadEvent
{
	// GamepadID
	SumType!(
		GamepadButtonEvent,
		GamepadAxisEvent,
	) data;
}

struct GamepadButtonEvent
{
	GamepadButton type;
	bool down;
}

struct GamepadAxisEvent
{
	GamepadTrigger type;
	Vec1 value;
}
