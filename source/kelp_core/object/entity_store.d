module kelp_core.object.entity_store;

import std.algorithm;

struct Entity
{
	uint index;
}

class EntityStore
{
	uint next_id;
	Entity[] entity_list;
	Entity[] free_list;
	//bool[] entity_table;

	@property size_t count() pure nothrow @nogc @safe
	{
		return this.entity_list.length;
	}

	@property ref Entity[] all() pure nothrow @nogc @safe
	{
		return this.entity_list;
	}

	bool has(Entity entity)
	{
		return this.entity_list.canFind(entity);
	}

	typeof(this) create(Entity[] out_entity_list...)
	{
		foreach (ref out_entity; out_entity_list)
		{
			this.create(out_entity);
		}
		return this;
	}

	typeof(this) create(out Entity out_entity)
	{
		scope Entity entity;
		entity = Entity(cast(uint) this.next_id);
		out_entity = entity;
		this.entity_list ~= entity;
		next_id += 1;
		return this;
	}

	typeof(this) release(Entity entity)
	{
		size_t count = entity_list.countUntil(entity);
		if (count >= 0)
		{
			this.entity_list.swapAt(count, entity_list.length - 1u);
			this.entity_list.length -= 1;
			this.free_list ~= entity;
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
	assert(store.all is null);
	store.create(entity_list);
	assert(store.count == 3);
	assert(entity_list[].all!(entity => store.has(entity)));
	store.release(entity_list[0]);
	assert(store.count == 2);
	assert(store.has(entity_list[0]) == false);

}
