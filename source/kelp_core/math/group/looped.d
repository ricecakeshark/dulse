module kelp_core.math.group.looped;

import std.math;

struct LoopedInt(long Limit)
{
	long internal_value;

	this(int init_value)
	{
		this.internal_value = init_value.normalize(Limit);
		return;
	}

	@property long value() const pure nothrow @nogc @safe
	{
		return internal_value;
	}

	long opUnary(string op : "++")() pure nothrow @nogc @safe
	{
		this.internal_value = normalize(this.internal_value + 1, Limit);
		return this.internal_value;
	}

	long opUnary(string op : "--")() pure nothrow @nogc @safe
	{
		this.internal_value = normalize(this.internal_value - 1, Limit);
		return this.internal_value;
	}

	long opBinary(string op, R)(in R rhs) const pure nothrow @nogc @safe
	{
		static if (op == "+")
		{
			return this.internal_value + rhs;
		}
		else static if (op == "-")
		{
			return this.internal_value - rhs;
		}
		else static if (op == "*")
		{
			return this.internal_value * rhs;
		}
		else static if (op == "/")
		{
			return this.internal_value / rhs;
		}
		else static if (op == "^^")
		{
			return this.internal_value.pow(rhs);
		}
		else static if (op == "&")
		{
			return this.internal_value & rhs;
		}
		else static if (op == "|")
		{
			return this.internal_value | rhs;
		}
		else static if (op == "^")
		{
			return this.internal_value ^ rhs;
		}
		else static if (op == "<<")
		{
			return this.internal_value << rhs;
		}
		else static if (op == ">>")
		{
			return this.internal_value >> rhs;
		}
		else static if (op == ">>>")
		{
			return this.internal_value >>> rhs;
		}
		else
		{
			static assert(false, "\"" ~ op ~ "\" operator is not implemented");
		}

	}

	auto opAssign(T)(T value) pure nothrow @safe
	{
		this.internal_value = value.normalize(Limit);
		return value;
	}

	bool opEquals(in typeof(this) rhs) const pure nothrow @nogc @safe
	{
		return this.internal_value == rhs.internal_value;
	}

	bool opEquals(in int rhs) const pure nothrow @nogc @safe
	{
		return internal_value == rhs;
	}

	size_t toHash() const pure nothrow @nogc @safe
	{
		return this.internal_value.hashOf;
	}

	inout(long) opCast(T : long)() inout pure nothrow @nogc @safe
	{
		return this.internal_value;
	}

	alias value this;
}

unittest
{
	import std.format : format;

	assert(normalize(10, 10) == 0);
	assert(normalize(0, 10) == 0);
	assert(normalize(33, 10) == 3);
	assert(normalize(-17, 10) == 3, format("%d", normalize(-17, 10)));
}

struct LoopedFloat(real Limit)
{
	real internal_value;

	this(real init_value)
	{
		this.internal_value = init_value.normalize(Limit);
		return;
	}

	@property real value() const pure nothrow @nogc @safe
	{
		return this.internal_value;
	}

	real opBinary(string op, T)(in T rhs) const pure nothrow @nogc @safe
	{
		static if (op == "+")
		{
			return this.internal_value + rhs;
		}
		else static if (op == "-")
		{
			return this.internal_value - rhs;
		}
		else static if (op == "*")
		{
			return this.internal_value * rhs;
		}
		else static if (op == "/")
		{
			return this.internal_value / rhs;
		}
		else static if (op == "^^")
		{
			return this.internal_value.pow(rhs);
		}
		else
		{
			static assert(false, "\"" ~ op ~ "\" operator is not implemented");
		}
	}

	auto opAssign(real value) pure nothrow @safe
	{
		this.internal_value = value.normalize(Limit);
		return value;
	}

	typeof(this) opOpAssign(string op : "+", T)(in T value)
	{
		this.internal_value = normalize(this.internal_value + value, Limit);
		return this;
	}

	typeof(this) opOpAssign(string op : "-", T)(in T value)
	{
		this.internal_value = normalize(this.internal_value + value, Limit);
		return this;
	}

	bool opEquals(in real rhs) const pure nothrow @nogc @safe
	{
		return isClose(internal_value, rhs);
	}

	size_t toHash() const pure nothrow @nogc @safe
	{
		return this.internal_value.hashOf;
	}

	alias value this;
}

long normalize(in long value, in long limit) pure nothrow @nogc @safe
{
	return (value % limit + limit) % limit;
}

real normalize(in real value, in real limit) pure nothrow @nogc @safe
{
	return value - floor(value / limit) * limit;
}

unittest
{
	import std.format : format;

	LoopedFloat!(10.0f) looped;
	looped = 0.0;

	assert(LoopedFloat!(10.0L)(10.0L).isClose(+0.0L), format("%f", LoopedFloat!(10.0f)(10.0f)));
	assert(LoopedFloat!(10.0L)(0.0L).isClose(+0.0L));
	assert(LoopedFloat!(10.0L)(33.0L).isClose(+3.0L));
	assert(LoopedFloat!(10.0L)(-17.0L).isClose(+3.0L), format("%f", looped - 17.0f));
}
