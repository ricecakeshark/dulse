module kelp_core.object.object_subsystem;

import kelp_core.core;
import kelp_core.object;

class ObjectSubsystem : Subsystem
{
	protected Core core;
	//IObjectManager[] object_manager_list;

	this(Core core)
	{
		super(core);
		return;
	}

	typeof(this) initialize()
	{
		/+foreach (manager; object_manager_list)
		{
			manager.initialize();
		}+/
		return this;
	}

	typeof(this) finalize()
	{
		return this;
	}

	typeof(this) process()
	{
		/+foreach (manager; object_manager_list)
		{
			manager.process();
		}+/
		return this;
	}
}
