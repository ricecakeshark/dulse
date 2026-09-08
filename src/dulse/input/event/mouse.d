module dulse.input.event.mouse;

import dulse.input.device;
import dulse.math.linalg.vector;
import std.sumtype;

struct MouseEvent
{
	uint mouse_id;
	SumType!(
		MouseMotionEvent,
		MouseButtonEvent,
		MouseWheelEvent,
	) data;
}

struct MouseButtonEvent
{
	MouseButton type;
	bool pressed;
}

struct MouseWheelEvent
{
	Vec2 move;
}

struct MouseMotionEvent
{
	Vec2 pos;
	Vec2 delta;
}
