module kelp_core.object.entity_store;

struct Entity
{
	uint index;
}

class EntityStore
{
	uint next_id;
	Entity[] free_list;
	bool[] entity_table;

	typeof(this) create(Entity[] out_entity_list...)
	{
		foreach (out_entity; out_entity_list)
		{
			this.create(out_entity);
		}
		return this;
	}

	typeof(this) create(out Entity out_entity)
	{
		out_entity = Entity(cast(uint)this.entity_table.length);
		this.entity_table.length += 1;
		this.entity_table[$-1] = true;
		return this;
	}
}
