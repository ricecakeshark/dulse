module kelp_core.math.group.looped;

//import std.bigint;

struct LoopedInt(long Length)
{
	long internal_value;

	this(int init_value)
	{
		this.internal_value = init_value;
		return;
	}

	long opUnary(string op : "++")() pure nothrow @nogc @safe
	{
		this.internal_value += 1;
		return this.internal_value;
	}

	long opUnary(string op : "--")() pure nothrow @nogc @safe
	{
		this.internal_value -= 1;
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
			static assert(false,"\""~op~ "\" operator is not implemented");
		}
		
	}

	auto opAssign(T)(T value) pure nothrow @safe
	{
		this.internal_value = value.normalize(Length);
		return value;
	}

	bool opEquals(in int rhs) const pure nothrow @nogc @safe
	{
		return internal_value == rhs;
	}

	size_t toHash() const pure nothrow @nogc @safe
	{
		return this.internal_value.hashOf;
	}

	//alias this = internal_value;
}

T normalize(T)(in T value, in T len) pure nothrow @nogc @safe
{
	if (value >= len)
	{
		return value - len * (value / len);
	}
	else if (value < 0)
	{
		return value + len * ((-value / len) + 1);
	}
	return value;
}

unittest
{
	import std.format : format;

	assert(normalize(10, 10) == 0);
	assert(normalize(0, 10) == 0);
	assert(normalize(33, 10) == 3);
	assert(normalize(-17, 10) == 3, format("%d", normalize(-17, 10)));
}
