module kelp_core.graphics.resource.geometry;

import kelp_core.graphics.resource;
import kelp_core.math.linalg.vector;

struct GfxGeometry(V, I)
{
	V[] vertex_list;
	I[] index_list;

	size_t size() pure nothrow @nogc @safe
	{
		return (this.size_vertex + this.size_index);
	}

	size_t size(size_t index) pure nothrow @nogc @safe
	{
		final switch (index)
		{
		case 0:
			return this.size_vertex;
		case 1:
			return this.size_index;
		}
	}

	size_t offset(size_t index) pure nothrow @nogc @safe
	{
		final switch (index)
		{
		case 0:
			return 0;
		case 1:
			return this.size_vertex;
		case 2:
			return this.size_vertex + this.size_index;
		}
	}

	ref V[] vertex() pure nothrow @nogc @safe
	{
		return this.vertex_list;
	}

	ref I[] index() pure nothrow @nogc @safe
	{
		return this.index_list;
	}

	size_t size_vertex() pure nothrow @nogc @safe
	{
		return (V.sizeof * vertex_list.length);
	}

	size_t size_index() pure nothrow @nogc @safe
	{
		return (I.sizeof * index_list.length);
	}

	size_t offset_vertex() pure nothrow @nogc @safe
	{
		return 0;
	}

	size_t offset_index() pure nothrow @nogc @safe
	{
		return (V.sizeof * vertex_list.length);
	}

	// typeof(this) load() 
}

unittest
{
	import kelp_core : Vector, ColorF;

	Geometry!(Vector!(3), ColorF) geometry;
	assert(__traits(isPOD, typeof(geometry)));
}
