module kelp_core.object.component;

import std.exception;
import std.algorithm;

interface IComponentStore
{
}

class ComponentStore(Entity, Component) : IComponentStore
{
	Entity[] dense_entity;
	Component[] component;
	size_t[Entity] sparse;

	@property bool has(Entity entity)
	{
		return (entity in sparse) !is null;
	}

	@property size_t count()
	{
		return component.length;
	}

	@property Entity[] entities()
	{
		return this.dense_entity;
	}

	ref Component opIndex(Entity entity)
	{
		if (this.has(entity) == false)
		{
			this.create(entity);
		}
		return component[sparse[entity]];
	}

	ref Component get(Entity entity)
	{
		enforce(this.has(entity));
		return this.component[this.sparse[entity]];
	}

	ref Component require(Entity entity)
	{
		if (this.has(entity) == false)
		{
			this.create(entity);
		}
		return component[sparse[entity]];
	}

	typeof(this) clear()
	{
		this.dense_entity = [];
		this.component = [];
		this.sparse.clear();
		return this;
	}

	typeof(this) create(Entity entity)
	{
		enforce(this.has(entity) == false);
		dense_entity ~= entity;
		sparse[entity] = this.component.length;
		this.component ~= Component();
		return this;
	}

	typeof(this) create(Entity entity, Component component)
	{
		enforce(this.has(entity) == false);
		dense_entity ~= entity;
		sparse[entity] = this.component.length;
		this.component ~= component;
		return this;
	}

	typeof(this) query(out Component[] query)
	{
		query = component;
		return this;
	}
}

unittest
{
	import std.stdio;
	import std.datetime;
	import std.datetime.stopwatch;

	struct S1
	{
		float a = 1.0;
	}

	struct S2
	{
		float b = 1.0;
	}

	struct S3
	{
		float c = 1.0;
	}

	void f1()
	{
		scope ComponentStore!(uint, S1) store = new ComponentStore!(uint, S1);
		foreach (count; 0 .. 100)
			store.create(count, S1(2.0));
	}

	auto result = benchmark!(f1)(100);
	writefln("result1 : %s", result[0]);
}
