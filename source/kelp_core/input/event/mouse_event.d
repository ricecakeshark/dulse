module kelp_core.input.event.mouse_event;

import kelp_core.input.device;
import kelp_core.math.linalg.vector;
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
	MouseButtonType type;
	bool downed;
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
