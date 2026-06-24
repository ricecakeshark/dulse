module kelp_core.graphics.resource.geometry;

import kelp_core.graphics.resource;
import kelp_core.math.linalg.vector;

import std.array : Appender;
import std.algorithm : map, sum;

struct GfxGeometry(V, I)
{
	V[] _vertex_list;
	I[] _index_list;

	this(V[] vertex_list, I[] index_list) pure nothrow @nogc @safe
	{
		this._vertex_list = vertex_list;
		this._index_list = index_list;
		return;
	}
	// property
	// size
	@property size_t size() const pure nothrow @nogc @safe
	{
		return this.size_vertex + this.size_index;
	}

	@property size_t size_vertex() const pure nothrow @nogc @safe
	{
		return V.sizeof * this._vertex_list.length;
	}

	@property size_t size_index() const pure nothrow @nogc @safe
	{
		return I.sizeof * this._index_list.length;
	}
	// count
	@property size_t count_vertex() const pure nothrow @nogc @safe
	{
		return this._vertex_list.length;
	}

	@property size_t count_index() const pure nothrow @nogc @safe
	{
		return this._index_list.length;
	}
	// offset
	@property size_t offset_vertex() const pure nothrow @nogc @safe
	{
		return 0;
	}

	@property size_t offset_index() const pure nothrow @nogc @safe
	{
		return this.size_vertex;
	}
	// stride
	@property size_t stride_vertex() const pure nothrow @nogc @safe
	{
		return V.sizeof;
	}

	@property size_t stride_index() const pure nothrow @nogc @safe
	{
		return I.sizeof;
	}
	// reference data
	@property ref V[] vertices() pure nothrow @nogc @safe
	{
		return this._vertex_list;
	}

	@property ref I[] indices() pure nothrow @nogc @safe
	{
		return this._index_list;
	}
	// state of them
	@property bool has_empty() const pure nothrow @nogc @safe
	{
		return (this.size_vertex == 0 && this.size_index == 0) ? true : false;
	}

	GfxGeometry!(V, I) opAssign(V, I)(GfxGeometry!(V, I) geometry) pure nothrow @nogc @safe
	{
		this._vertex_list = geometry._vertex_list;
		this._index_list = geometry._index_list;
		return geometry;
	}

	typeof(this) set(V, I)(V[] vertices, I[] indices) pure nothrow @nogc @safe
	{
		this._vertex_list = vertices;
		this._index_list = indices;
		return this;
	}
}
// GfxGeometry(V, I)[] funcition
// size
size_t size(G : GfxGeometry!(V, I), V, I)(G[] geometry_list...) pure nothrow @nogc @safe
{
	return geometry_list
		.map!(geometry => geometry.size)
		.sum();
}

size_t size_vertex(G : GfxGeometry!(V, I), V, I)(G[] geometry_list...) pure nothrow @nogc @safe
{
	return geometry_list
		.map!(geometry => geometry.size_vertex)
		.sum();
}

size_t size_index(G : GfxGeometry!(V, I), V, I)(G[] geometry_list...) pure nothrow @nogc @safe
{
	return geometry_list
		.map!(geometry => geometry.size_index)
		.sum();
}
// count
size_t count_vertex(G : GfxGeometry!(V, I), V, I)(G[] geometry_list...) pure nothrow @nogc @safe
{
	return geometry_list
		.map!(geometry => geometry.count_vertex)
		.sum();
}

size_t count_index(G : GfxGeometry!(V, I), V, I)(G[] geometry_list...) pure nothrow @nogc @safe
{
	return geometry_list
		.map!(geometry => geometry.count_index)
		.sum();
}
// offset
size_t offset_vertex(G : GfxGeometry!(V, I), V, I)(G[] geometry_list...) pure nothrow @nogc @safe
{
	return 0;
}

size_t offset_index(G : GfxGeometry!(V, I), V, I)(G[] geometry_list...) pure nothrow @nogc @safe
{
	return geometry_list.size_vertex;
}

unittest
{
	import kelp_core : Vector, ColorF;

	auto geometry = GfxGeometry!(Vector!(3), uint)([], []);
	assert(__traits(isPOD, typeof(geometry)));

	assert(size(geometry, geometry, geometry) == 0u);
}
