module dulse.input.device.gamepad;

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
	trigger_left,
	trigger_right,
}

enum GamepadTrigger
{
	none = -1,
	left,
	right,
}

enum GamepadStick
{
	none = -1,
	left,
	right,
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
