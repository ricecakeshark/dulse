module kelp_core.device.mouse;

import kelp_core.device;
import kelp_core.core.container : RingQueue;

class Mouse
{
	//MouseState last_mouse_state;
	RingQueue!(MouseState, 5) mouse_state;

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

	void update(ref MouseState mouse_state)
	{
		//this.last_mouse_state = mouse_state;
		this.mouse_state.append([mouse_state]);
		return;
	}
}

struct MouseState
{
	ButtonState left, middle, right, x1, x2;
	PositionState global;
}

enum MouseButton
{
	none = 0,
	left = 1u << 0,
	middle = 1u << 1,
	right = 1u << 2,
	x1 = 1u << 3,
	x2 = 1u << 4,
}
