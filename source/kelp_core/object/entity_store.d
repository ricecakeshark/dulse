module kelp_core.object.entity_store;

import std.algorithm : all, any, canFind, countUntil, swapAt;
import std.exception : enforce;

struct Entity
{
	uint index;
}

class EntityStore
{
	protected uint next_id;
	protected Entity[] entity_list;
	protected Entity[] free_list;
	//bool[] entity_table;

	@property size_t count() const pure nothrow @nogc @safe
	{
		return this.entity_list.length;
	}

	@property size_t opDollar() const pure nothrow @nogc @safe
	{
		return this.entity_list.length;
	}

	@property ref Entity[] list() pure nothrow @nogc @safe
	{
		return this.entity_list;
	}

	Entity opIndex(in size_t index) pure @safe
	{
		enforce(index < this.count);
		return this.entity_list[index];
	}

	bool has(Entity entity) pure nothrow @nogc @safe
	{
		return this.entity_list.canFind(entity);
	}

	bool has_all(Entity[] entity_list...) pure nothrow @nogc @safe
	{
		return entity_list.all!(entity => this.has(entity));
	}

	bool has_any(Entity[] entity_list...) pure nothrow @nogc @safe
	{
		return entity_list.any!(entity => this.has(entity));
	}

	typeof(this) create(out Entity out_entity) pure nothrow @safe
	{
		scope Entity entity;
		entity = Entity(cast(uint) this.next_id);
		out_entity = entity;
		// internal
		this.entity_list ~= entity;
		next_id += 1;
		return this;
	}

	typeof(this) create(Entity[] out_entity_list...) pure nothrow @safe
	{
		foreach (ref out_entity; out_entity_list)
		{
			this.create(out_entity);
		}
		return this;
	}

	typeof(this) release(Entity entity) pure nothrow @safe
	{
		size_t count;
		count = entity_list.countUntil(entity);
		if (count >= 0)
		{
			this.entity_list.swapAt(count, entity_list.length - 1u);
			this.entity_list.length -= 1;
			this.free_list ~= entity;
		}
		return this;
	}

	typeof(this) release(Entity[] entity_list...) pure nothrow @safe
	{
		foreach (ref entity; entity_list)
		{
			this.release(entity);
		}
		return this;
	}
}

unittest
{
	EntityStore store;
	Entity[3] entity_list;

	store = new EntityStore();
	assert(store.count == 0);
	assert(store.list is null);
	store.create(entity_list);
	assert(store.count == 3);
	assert(entity_list[].all!(entity => store.has(entity)));
	store.release(entity_list[0]);
	assert(store.count == 2);
	assert(store.has(entity_list[0]) == false);
}
