module src.dulse.math.linalg.velocity;

import dulse.math.linalg;
import core.time;

alias Vel = Velocity;


static V velocty(V:Vector!(Length,Type),size_t Length,Type = float)(
	in V vec,
	in Duration dur,
)
{
	return vec / dur.total!"secs"();
}

struct Velocity(size_t Length, Type = float)
{
	alias V = Vector!(Length, Type);
	protected V vec;
	protected Duration unit_dur;

	this(V vec, Duration dur = dur!"msecs"(1000))
	{
		this.vec = vec;
		this.unit_dur = dur;
		return;
	}

	V opBinary(string op : "*", R)(in Duration dur) const pure nothrow @nogc @safe
	{
		return this.vec * dur / this.unit_dur;
	}
}
