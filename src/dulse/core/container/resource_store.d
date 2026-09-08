module dulse.core.container.resource_store;

import std.sumtype;

class ResourceStore(ResourceType)
{
	protected ResourceType[][TypeInfo] resource_pool;

	this()
	{
		foreach (Type; ResourceType.Types)
		{
			this.resource_pool[typeid(Type)] = [];
		}
		return;
	}

	~this()
	{
		return;
	}

	typeof(this) register(TypeList...)(TypeList register_list)
	{
		foreach (target; register_list)
		{
			this.register(target);
		}
		return this;
	}

	typeof(this) register(Type)(Type register_target)
	{
		this.resource_pool[typeid(Type)] ~= ResourceType(register_target);
		return this;
	}

	typeof(this) release(TypeList...)()
	{
		foreach (Type; TypeList)
		{
			this.release!Type();
		}
		return this;
	}

	typeof(this) release(Type)()
	{
		foreach (ref resource; this.resource_pool[typeid(Type)])
		{
			if (resource.has!Type() == false)
			{
				assert(0);
			}
			//resource.get!Type.release();
			release(resource);
			destroy(resource);
		}
		this.resource_pool[typeid(Type)] = [];
		return this;
	}

	void release(ResourceType resource)
	{
		resource.match!((ref res) { res.release; });
		return;
	}

	typeof(this) release_all()
	{
		foreach_reverse (Type; ResourceType.Types)
		{
			this.release!Type();
		}
		return this;
	}
}
