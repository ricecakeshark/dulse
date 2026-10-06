module dulse.object.object_subsystem;

import dulse.core;
import dulse.object;

class ObjectSubsystem : Subsystem!ObjectSubsystem
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

	override typeof(this) initialize()
	{
		foreach (manager; object_manager_list)
		{
			manager.initialize();
		}
		return this;
	}

	override typeof(this) finalize()
	{
		return this;
	}

	override typeof(this) process()
	{
		foreach (ref manager; object_manager_list)
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
