module kelp_core.device.device_desc;

import kelp_core.math : Vector, Vec1, Vec2;

struct ButtonState
{
	bool state;

	this(bool state) nothrow @nogc
	{
		this.state = state;
		return;
	}
}

struct TriggerState
{
	Vec1 state;

	this(Vec1 state)
	{
		this.state = state;
		return;
	}
}

struct StickState
{
	Vec2 state;

	this(Vec2 state)
	{
		this.state = state;
		return;
	}
}

struct PositionState
{
	Vec2 state;

	this(Vec2 state)
	{
		this.state = state;
		return;
	}
}
