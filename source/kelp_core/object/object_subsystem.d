module kelp_core.object.object_subsystem;

import kelp_core.core;
import kelp_core.object;

class ObjectSubsystem : Subsystem
{
	protected Core core;
	//IObjectManager[] object_manager_list;

	this(Core core)
	{
		this.core = core;
		return;
	}

	void initialize()
	{
		/+foreach (manager; object_manager_list)
		{
			manager.initialize();
		}+/
		return;
	}

	void finalize()
	{
		return;
	}

	void process()
	{
		/+foreach (manager; object_manager_list)
		{
			manager.process();
		}+/
		return;
	}
}
