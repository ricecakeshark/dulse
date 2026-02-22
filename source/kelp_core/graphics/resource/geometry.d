module kelp_core.graphics.resource.geometry;

import kelp_core.graphics.resource;
import kelp_core.math.linalg.vector;

struct GfxGeometry(V, I)
{
	V[] vertex_list;
	I[] index_list;

	typeof(this) initialize() pure nothrow @safe
	{
		this.vertex_list = new V[](0);
		this.index_list = new I[](0);
		return this;
	}

	typeof(this) initialize(in size_t count_vertex, in size_t count_index) pure nothrow @safe
	{
		this.vertex_list = new V[](count_vertex);
		this.index_list = new I[](count_index);
		return this;
	}
	// property
	@property size_t bytes() pure nothrow @nogc @safe
	{
		return this.bytes_vertex + this.bytes_index;
	}
	// vertex property
	@property size_t bytes_vertex() pure nothrow @nogc @safe
	{
		return V.sizeof * this.vertex_list.length;
	}

	@property size_t count_vertex() pure nothrow @nogc @safe
	{
		return this.vertex_list.length;
	}

	@property size_t offset_vertex() pure nothrow @nogc @safe
	{
		return 0;
	}

	@property size_t stride_vertex() pure nothrow @nogc @safe
	{
		return V.sizeof;
	}
	// index property
	@property size_t bytes_index()
	{
		return I.sizeof * this.index_list.length;
	}

	@property size_t count_index() pure nothrow @nogc @safe
	{
		return this.index_list.length;
	}

	@property size_t offset_index() pure nothrow @nogc @safe
	{
		return this.bytes_vertex;
	}

	@property size_t stride_index() pure nothrow @nogc @safe
	{
		return I.sizeof;
	}

	size_t offset(in size_t index) pure nothrow @nogc @safe
	{
		final switch (index)
		{
		case 0:
			return 0;
		case 1:
			return this.bytes_vertex;
		case 2:
			return this.bytes_vertex + this.bytes_index;
		}
	}

	@property ref V[] vertex() pure nothrow @nogc @safe
	{
		return this.vertex_list;
	}

	@property ref I[] index() pure nothrow @nogc @safe
	{
		return this.index_list;
	}

	// typeof(this) load() 
}

unittest
{
	import kelp_core : Vector, ColorF;

	GfxGeometry!(Vector!(3), ColorF) geometry;
	assert(__traits(isPOD, typeof(geometry)));
}
