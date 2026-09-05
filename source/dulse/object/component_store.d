module dulse.object.component_store;

import dulse.object;
import std.exception;
import std.algorithm;
import std.typecons;
import std.traits;

interface IComponentStore
{
	@property bool has(Entity entity) pure nothrow @nogc @safe;

	@property size_t count() pure nothrow @nogc @safe;

	@property Entity[] entities() pure nothrow @nogc;

	@property TypeInfo type() pure nothrow @nogc @safe;

	typeof(this) clear() pure nothrow @nogc @safe;

	typeof(this) attach(in Entity[] entity_list...) pure nothrow @safe;

	typeof(this) detach(in Entity[]...) pure nothrow @safe;
}

class ComponentStore(Component) : IComponentStore
{
	Entity[] entity_list;
	Component[] component_list;
	Nullable!size_t[] lookup_list;

	@property bool has(Entity entity) const pure nothrow @nogc @safe
	{
		if (entity.index >= lookup_list.length)
		{
			return false;
		}
		return this.lookup_list[entity.index].isNull == false;
	}

	@property size_t count() pure nothrow @nogc @safe
	{
		return component_list.length;
	}

	@property Entity[] entities() pure nothrow @nogc
	{
		return this.entity_list;
	}

	@property ref Component[] components() pure nothrow @nogc
	{
		return this.component_list;
	}

	@property TypeInfo type() pure nothrow @nogc @safe
	{
		return typeid(Component);
	}

	ref Component opIndex(Entity entity) pure @safe
	{
		enforce(this.has(entity));
		return this.component_list[lookup(entity)];
	}

	ref Component get(Entity entity) pure @safe
	{
		enforce(this.has(entity));
		return this.component_list[lookup(entity)];
	}

	ref Component require(Entity entity) pure nothrow
	{
		if (this.has(entity) == false)
		{
			this.attach(entity);
		}
		return this.component_list[lookup(entity)];
	}

	typeof(this) clear() pure nothrow @nogc @safe
	{
		this.entity_list = [];
		this.component_list = [];
		this.lookup_list = [];
		return this;
	}

	typeof(this) attach(in Entity entity) pure nothrow @safe
	{
		if (this.has(entity))
		{
			return this;
		}
		if (entity.index >= lookup_list.length)
		{
			lookup_list.length = cast(size_t)(entity.index + 1);
		}
		// attach entity_list
		this.entity_list ~= entity;
		// attach lookup_list
		this.lookup_list[entity.index] = cast(size_t) this.component_list.length;
		// attach component_list
		this.component_list ~= Component();
		return this;
	}

	typeof(this) attach(in Entity[] entity_list...) pure nothrow @safe
	{
		foreach (entity; entity_list)
		{
			this.attach(entity);
		}
		return this;
	}

	typeof(this) detach(in Entity entity) pure nothrow @safe
	{
		if (this.has(entity) == false)
		{
			return this;
		}
		size_t count = this.entity_list.countUntil(entity);
		if (count >= 0)
		{
			// detach component_list
			this.component_list.swapAt(lookup(entity), component_list.length - 1u);
			this.component_list.length -= 1;
			// detach lookup_list
			this.lookup_list[entity.index].nullify();
			// detach entity_list
			this.entity_list.swapAt(count, entity_list.length - 1u);
			this.entity_list.length -= 1;
		}
		return this;
	}

	typeof(this) detach(in Entity[] entity_list...) pure nothrow @safe
	{
		foreach (entity; entity_list)
		{
			this.detach(entity);
		}
		return this;
	}

protected:
	size_t lookup(Entity entity) pure nothrow @nogc @safe
	{
		return lookup_list[cast(size_t) entity.index].get();
	}

	/+bool try_lookup(Entity entity, out size_t index) pure nothrow @nogc @safe
	{
		if (cast(size_t)entity.index !in lookup_list)
		{
			return false;
		}
		index = lookup_list[cast(size_t) entity.index].get();
		return true;
	}+/
}

unittest
{
	import std.algorithm : all;
	import std.exception : collectException;

	struct C
	{
		float param;
	}

	ComponentStore!C store;
	Entity[] entity_list;

	store = new ComponentStore!C();
	foreach (count; 0 .. 3)
	{
		entity_list ~= Entity(cast(uint) count);
	}
	assert(store.count == 0);
	assert(entity_list.all!(entity => store.has(entity) == false));
	assert(collectException!Exception({ store.get(entity_list[0]); }) is null);

	foreach (entity; entity_list)
	{
		store.attach(entity);
	}
	assert(store.count == 3);
	assert(store.entities.length == 3);
	assert(store.components.length == 3);
	assert(entity_list.all!(entity => store.has(entity)));
	store.detach(entity_list[$ - 1]);
	assert(store.count == 2);
	assert(store.entities.length == 2);
	assert(store.components.length == 2);
	C ret = store.require(entity_list[2]);
	assert(is(typeof(ret) == C));
	assert(store.count == 3);
	assert(entity_list.all!(entity => store.has(entity)));
	store.clear();
	assert(store.count == 0);
	assert(entity_list.all!(entity => store.has(entity) == false));
}
