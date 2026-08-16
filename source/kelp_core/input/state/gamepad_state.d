module kelp_core.input.state.gamepad_state;

import kelp_core.device.gamepad;
import kelp_core.math.linalg.vector;

struct GamepadState
{
	GamepadButtonState[GamepadButton] button;
	GamepadTriggerState[GamepadTrigger] trigger;
	GamepadStickState[GamepadStick] stick;
}

struct GamepadButtonState
{
	bool value;
}

struct GamepadTriggerState
{
	Vector!(1) value;
}

struct GamepadStickState
{
	Vector!(2) value;
}