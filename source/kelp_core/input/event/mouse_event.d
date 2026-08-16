module kelp_core.input.event.mouse_event;

import kelp_core.device;
import kelp_core.math.linalg.vector;
import std.sumtype;

struct MouseEvent
{
	SumType!(
		MouseButtonEvent,
		MouseWheelEvent,
	) data;
}

struct MouseButtonEvent
{
	MouseButton type;
	bool down;
}

struct MouseWheelEvent
{
	Vec1 move;
}

struct MouseMotionEvent
{
	Vec2 pos;
	Vec2 delta;
}
