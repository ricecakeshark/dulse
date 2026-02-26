module kelp_core.graphics.resource.mesh;

import kelp_core.graphics.resource;
import std.array;
import std.algorithm;

struct GfxMesh
{
	void[] geometry_list;
	size_t _capacity_vertex;
	size_t _capacity_index;

	this(void[] geometry_list)
	{
		this.geometry_list = geometry_list;
		return;
	}

	typeof(this) initialize(
		in size_t capacity_vertex,
		in size_t capacity_index,
	)
	{
		this._capacity_vertex = capacity_vertex;
		this._capacity_index = capacity_index;
		return this;
	}

	@property size_t bytes(G)()
	{
		return (cast(G[]) this.geometry_list)
			.map!(geometry => geometry.bytes)
			.sum();
	}

	@property size_t bytes_vertex(G)()
	{
		return (cast(G[]) this.geometry_list)
			.map!(geometry => geometry.bytes_vertex)
			.sum();
	}

	@property size_t capacity()
	{
		return this._capacity_vertex + this._capacity_index;
	}

	@property size_t capacity_vertex()
	{
		return this._capacity_vertex;
	}

	@property size_t capacity_index()
	{
		return this._capacity_index;
	}

	@property size_t offset_vertex()
	{
		return 0;
	}

	@property size_t offset_index()
	{
		return this.capacity_vertex;
	}

	@property size_t count(G : GfxGeometry!(V, I), V, I)()
	{
		return (cast(G[]) this.geometry_list).length;
	}

	@property size_t count_vertex(G)()
	{
		return (cast(G[]) this.geometry_list)
			.map!(geometry => geometry.count_vertex)
			.sum();
	}

	@property size_t bytes_index(G)()
	{
		return (cast(G[]) this.geometry_list)
			.map!(geometry => geometry.bytes_index)
			.sum();
	}

	@property size_t count_index(G)()
	{
		return (cast(G[]) this.geometry_list)
			.map!(geometry => geometry.count_index)
			.sum();
	}

	@property G[] geometry(G : GfxGeometry!(V, I), V, I)()
	{
		return cast(G[]) this.geometry_list;
	}

	@property DataVertex!(V)[] vertices(G : GfxGeometry!(V, I), V, I)() pure nothrow
	{
		scope Appender!(DataVertex!(V)[]) data;
		foreach (geometry; cast(G[]) this.geometry_list)
		{
			data ~= geometry.vertex;
		}
		return data[];
	}

	@property DataIndex!(I)[] indices(G : GfxGeometry!(V, I), V, I)() pure nothrow
	{
		scope Appender!(DataIndex!(I)[]) data;
		foreach (geometry; cast(G[]) this.geometry_list)
		{
			data ~= geometry.index;
		}
		return data[];
	}

	@property V[] data_vertex(G : GfxGeometry!(V, I), V, I)() pure nothrow
	{
		scope Appender!(V[]) data;
		data.clear();
		foreach (geometry; cast(G[]) this.geometry_list)
		{
			data ~= geometry.data_vertex;
		}
		return data[];
	}

	@property I[] data_index(G : GfxGeometry!(V, I), V, I)() pure nothrow
	{
		scope Appender!(I[]) data;
		data.clear();
		foreach (geometry; cast(G[]) this.geometry_list)
		{
			data ~= geometry.data_index;
		}
		return data[];
	}

	auto opAssign(G : GfxGeometry!(V, I), V, I)(G[] geometry_list)
	{
		this.geometry_list = geometry_list;
		return this;
	}

}
