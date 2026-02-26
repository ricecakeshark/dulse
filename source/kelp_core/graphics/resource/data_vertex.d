module kelp_core.graphics.resource.data_vertex;

import std.algorithm : map, sum;

struct DataVertex(V)
{
	V[] _data;

	this(V[] vertex_data)
	{
		this._data = vertex_data;
		return;
	}

	@property size_t bytes() const pure nothrow @nogc @safe
	{
		return this._data.length * V.sizeof;
	}

	@property size_t count() const pure nothrow @nogc @safe
	{
		return this._data.length;
	}

	@property size_t stride() const pure nothrow @nogc @safe
	{
		return V.sizeof;
	}

	@property inout(V[]) data() inout pure nothrow @nogc @safe
	{
		return this._data;
	}
}
