module kelp_core.device.gamepad;

import kelp_core.device;
import kelp_core.core.container : RingQueue;

class Gamepad
{
	RingQueue!(GamepadState, 10) state_list;

	void intialize()
	{
		return;
	}

	void finalize()
	{
		return;
	}

	void process()
	{
		return;
	}
}

struct GamepadState
{
	ButtonState south, east, west, north;
	ButtonState back, guide, start;
	StickState stick_left, stick_right;
	TriggerState shoulder_left, shoulder_right;
	ButtonState dpad_up, dpad_down, dpad_left, dpad_right;
	ButtonState misc1;
	ButtonState paddle_right_1, paddle_left_1, paddle_right_2, paddle_left_2;
	ButtonState touchpad;
	ButtonState misc2, misc3, misc4, misc5, misc6;
}

enum GamepadButton
{
	none = -1,
	south,
	east,
	west,
	north,

	back,
	guide,
	start,

	stick_left,
	stick_right,

	shoulder_left,
	shoulder_right,

	dpad_up,
	dpad_down,
	dpad_left,
	dpad_right,

	misc1,

	paddle_right_1,
	paddle_left_1,
	paddle_right_2,
	paddle_left_2,

	touchpad,

	misc_2,
	misc_3,
	misc_4,
	misc_5,
	misc_6,
}

enum GamepadAxis
{
	none = -1,
	left_x,
	left_y,
	right_x,
	right_y,
	left_trigger,
	right_trigger,
}

enum GamepadType
{
	unknown = 0,
	standard,
	xbox360,
	xboxone,
	ps3,
	ps4,
	ps5,
	nintendo_switch_pro,
	nintendo_switch_left,
	nintendo_switch_right,
	nintendo_switch_pair,
	gamecube,
}
