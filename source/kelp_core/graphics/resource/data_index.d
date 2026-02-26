module kelp_core.graphics.resource.data_index;

import std.algorithm : map, sum;

struct DataIndex(I)
{
	I[] _data;

	this(I[] index_data)
	{
		this._data = index_data;
		return;
	}

	@property size_t bytes() const pure nothrow @nogc @safe
	{
		return this._data.length * I.sizeof;
	}

	@property size_t count() const pure nothrow @nogc @safe
	{
		return this._data.length;
	}

	@property size_t stride() const pure nothrow @nogc @safe
	{
		return I.sizeof;
	}

	@property inout(I[]) data() inout pure nothrow @nogc @safe
	{
		return this._data;
	}
}
