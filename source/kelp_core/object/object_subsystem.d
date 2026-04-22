module kelp_core.object.object_subsystem;

import kelp_core.core;
import kelp_core.object;

class ObjectSubsystem : Subsystem
{
	protected Core core;
	//ObjectStore object_store;

	this(Core core)
	{
		this.core = core;
		return;
	}

	void initialize()
	{
		//this.object_store = ObjectStore();
		return;
	}

	void finalize()
	{
		return;
	}

	void process()
	{
		return;
	}
}