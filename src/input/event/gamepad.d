module dulse.input.event.gamepad;

import dulse.input.device;
import dulse.math.linalg.vector;
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
	bool pressed;
}

struct GamepadAxisEvent
{
	GamepadAxis type;
	Vec1 value;
}
