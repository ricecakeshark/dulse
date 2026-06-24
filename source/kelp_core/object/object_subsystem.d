module kelp_core.object.object_subsystem;

import kelp_core.core;
import kelp_core.object;

class ObjectSubsystem : Subsystem
{
	protected Core core;
	ObjectManager[] object_manager_list;

	this(Core core)
	{
		super(core);
		return;
	}

	invariant
	{
		assert(this !is null);
	}

	typeof(this) initialize()
	{
		foreach (manager; object_manager_list)
		{
			manager.initialize();
		}
		return this;
	}

	typeof(this) finalize()
	{
		return this;
	}

	typeof(this) process()
	{
		foreach (manager; object_manager_list)
		{
			manager.process();
		}
		return this;
	}

	typeof(this) create(out ObjectManager manager)
	{
		manager = new ObjectManager();
		this.object_manager_list ~= manager;
		return this;
	}

	typeof(this) create(ObjectManager[] manager_list...)
	{
		foreach (ref manager; manager_list)
		{
			this.create(manager);
		}
		return this;
	}
}
