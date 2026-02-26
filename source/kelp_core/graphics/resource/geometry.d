module kelp_core.graphics.resource.geometry;

import kelp_core.graphics.resource;
import kelp_core.math.linalg.vector;

import std.array : Appender;
import std.algorithm : map, sum;

struct GfxGeometry(V, I)
{
	DataVertex!(V) _vertex_data;
	DataIndex!(I) _index_data;

	this(V[] vertex_list, I[] index_list)
	{
		this._vertex_data = DataVertex!(V)(vertex_list);
		this._index_data = DataIndex!(I)(index_list);
		return;
	}

	this(DataVertex!(V) vertex_data, DataIndex!(I) index_data)
	{
		this._vertex_data = vertex_data;
		this._index_data = index_data;
		return;
	}
	// property
	@property size_t bytes() pure nothrow @nogc @safe
	{
		return this.bytes_vertex + this.bytes_index;
	}

	@property size_t bytes_vertex() pure nothrow @nogc @safe
	{
		return this._vertex_data.bytes;
	}

	@property size_t bytes_index() pure nothrow @nogc @safe
	{
		return this._index_data.bytes;
	}

	@property size_t count_vertex() pure nothrow @nogc @safe
	{
		return this._vertex_data.count;
	}

	@property size_t count_index() pure nothrow @nogc @safe
	{
		return this._index_data.count;
	}

	@property size_t offset_vertex() pure nothrow @nogc @safe
	{
		return 0;
	}

	@property size_t offset_index() pure nothrow @nogc @safe
	{
		return this.bytes_vertex;
	}

	@property size_t stride_vertex() pure nothrow @nogc @safe
	{
		return this._vertex_data.stride;
	}

	@property size_t stride_index() pure nothrow @nogc @safe
	{
		return this._index_data.stride;
	}

	@property V[] data_vertex() pure nothrow @nogc @safe
	{
		return this._vertex_data.data;
	}

	@property I[] data_index() pure nothrow @nogc @safe
	{
		return this._index_data.data;
	}
}

unittest
{
	import kelp_core : Vector, ColorF;

	GfxGeometry geometry = GfxGeometry!(Vector!(3), uint)([], []);
	assert(__traits(isPOD, typeof(geometry)));
}
