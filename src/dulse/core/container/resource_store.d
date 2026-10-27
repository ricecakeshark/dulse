module dulse.core.container.resource_store;

import dulse.core.container.typed_table;
import std.meta : NoDuplicates, Reverse;

class ResourceStore(ResourceType...)
{
	protected TypedTable!ResourceType pool;

	this()
	{
		return;
	}

	~this()
	{
		return;
	}

	typeof(this) register(TypeList...)(TypeList register_list)
	{
		this.pool.append(register_list);
		return this;
	}

	typeof(this) release(TypeList...)()
	{
		foreach (Type; NoDuplicates!TypeList)
		{
			if (!this.pool.has_key!Type)
			{
				continue;
			}
			foreach (ref res; this.pool.refer!Type)
			{
				res.release();
				destroy(res);
			}
		}
		this.pool.remove!TypeList;
		return this;
	}

	typeof(this) release_all()
	{
		foreach (Type; Reverse!ResourceType)
		{
			this.release!Type();
		}
		return this;
	}
}
