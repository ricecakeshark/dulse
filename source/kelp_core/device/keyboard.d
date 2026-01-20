module kelp_core.device.keyboard;

import kelp_core.core.container : RingQueue;

class Keyboard
{
	//KeyboardInputState[2] input_state;
	RingQueue!(KeyboardInputState, 5) state_list;

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

	typeof(this) update(KeyboardInputState keyboard_input_state)
	{
		state_list.append([keyboard_input_state]);
		return this;
	}

	bool pressed(Scancode scancode)
	{
		return (state_list[0][scancode] == true) ? true : false;
	}

	bool released(Scancode scancode)
	{
		return (state_list[0][scancode] == false) ? true : false;
	}

	bool pressed_just(Scancode scancode)
	{
		return (state_list[0][scancode] == true
				&& state_list[1][scancode] == false) ? true : false;
	}

	bool released_just(Scancode scancode)
	{
		return (state_list[0][scancode] == false
				&& state_list[1][scancode] == true) ? true : false;
	}
}

struct KeyboardInputState
{
	bool[512] key_state;

	this(const bool[] key_state)
	{
		this.key_state = key_state.dup;
		return;
	}

	inout(bool) opIndex(const size_t index) inout pure nothrow @nogc @safe
	{
		return key_state[index];
	}

	bool pressed(const Scancode scancode) const pure nothrow @nogc @safe
	{
		return (this.key_state[scancode] == true);
	}

	bool released(const Scancode scancode) const pure nothrow @nogc @safe
	{
		return (this.key_state[scancode] == false);
	}
}

enum Scancode
{
	none = 0,

	A = 4,
	B,
	C,
	D,
	E,
	F,
	G,
	H,
	I,
	J,
	K,
	L,
	M,
	N,
	O,
	P,
	Q,
	R,
	S,
	T,
	U,
	V,
	W,
	X,
	Y,
	Z,

	num_1 = 30,
	num_2,
	num_3,
	num_4,
	num_5,
	num_6,
	num_7,
	num_8,
	num_9,
	num_10,

	Return = 40,
	escape = 41,
	backspace,
	tab,
	space,

	minus = 45,
	equals,
	left_braket = 47,
	right_braket,
	backslash = 49,
	nonushash = 50,

	f1 = 58,
	f2,
	f3,
	f4,
	f5,
	f6,
	f7,
	f8,
	f9,
	f10,
	f11,
	f12,

	printscreen = 70,
	scrolllock,
	pause,
	insert,

	home = 74,
	pageup,
	delete_,
	end,
	pagedown,
	right = 79,
	left,
	down,
	up,

	numlockclear = 83,

	left_ctrl = 224,
	left_shift,
	left_alt,
	left_gui,
	right_ctrl = 228,
	right_shift,
	right_alt,
	right_gui,
}
