module kelp_core.object.component_store;

import kelp_core.object;
import std.exception;
import std.algorithm;
import std.typecons;
import std.traits;

interface IComponentStore
{
}

class ComponentStore(EntityType, Component) : IComponentStore
{
	Entity[] entity_list;
	Component[] component_list;
	Nullable!size_t[] lookup_list;

	@property bool has(Entity entity)
	{
		if (entity.index >= lookup_list.length)
		{
			return false;
		}
		return this.lookup_list[entity.index].isNull;
	}

	@property size_t count()
	{
		return component_list.length;
	}

	@property Entity[] entities()
	{
		return this.entity_list;
	}

	@property Component[] components()
	{
		return this.component_list;
	}

	ref Component opIndex(Entity entity)
	{
		if (this.has(entity) == false)
		{
			this.create(entity);
		}
		return this.component_list[lookup(entity)];
	}

	ref Component get(Entity entity)
	{
		enforce(this.has(entity));
		return this.component_list[lookup(entity)];
	}

	ref Component require(Entity entity)
	{
		if (this.has(entity) == false)
		{
			this.create(entity);
		}
		return this.component_list[lookup(entity)];
	}

	typeof(this) clear()
	{
		this.entity_list = [];
		this.component_list = [];
		this.lookup_list = [];
		return this;
	}

	typeof(this) create(Entity entity)
	{
		enforce(this.has(entity) == false);

		if (entity.index >= lookup_list.length)
		{
			lookup_list.length = cast(size_t)(entity.index+1);
		}
		entity_list ~= entity;
		lookup_list[entity.index] = cast(size_t) this.component_list.length;
		this.component_list ~= Component();
		return this;
	}

	typeof(this) create(Entity entity, Component component)
	{
		enforce(this.has(entity) == false);
		if (entity.index >= lookup_list.length)
		{
			lookup_list.length = cast(size_t) entity.index;
		}
		entity_list ~= entity;
		lookup_list[entity.index] = cast(size_t) this.component_list.length;
		this.component_list ~= component;
		return this;
	}

	protected:
	size_t lookup(Entity entity) pure nothrow @nogc @safe
	{
		return lookup_list[cast(size_t)entity.index].get();
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
