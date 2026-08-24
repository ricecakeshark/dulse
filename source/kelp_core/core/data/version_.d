module kelp_core.core.data.version_;

import std.format : format;

alias Ver3 = Version!(3);

struct Version(size_t Length = 3)
{
	int[Length] ver_list;

	this(int[Length] ver_list...) pure nothrow @nogc @safe
	{
		this.ver_list = ver_list;
		return;
	}

	@property ref int[Length] ver() pure nothrow @nogc @safe
	{
		return this.ver_list;
	}

	@property size_t length() const pure nothrow @nogc @safe
	{
		return Length;
	}

	ref inout(int) opIndex(size_t index) inout pure nothrow @nogc @safe
	in
	{
		assert(index < Length, "a index is out of Version Length");
	}
	do
	{
		return this.ver_list[index];
	}

	ref typeof(this) initialize(int[Length] ver_list...) pure nothrow @nogc @safe
	{
		this.ver_list = ver_list;
		return this;
	}

	string to_string() const pure @safe
	{
		return format!("[%(%2d,%)]")(this.ver_list);
	}
}

unittest
{
	Version!3 ver;
	ver.initialize(1, 2, 3);
}
