module kelp_core.core.subsystem;

//import kelp_api;
import kelp_core.core;
import std.array, std.algorithm;

class SubsystemPool
{
	InterfacedPool!(Subsystem) pool;

	typeof(this) initialize()
	{
		foreach (subsystem; this.pool.all)
		{
			subsystem.initialize();
		}
		return this;
	}

	typeof(this) finalize()
	{
		foreach_reverse (subsystem; this.pool.all)
		{
			subsystem.finalize();
		}
		return this;
	}

	typeof(this) process()
	{
		foreach (subsystem; this.pool.all)
		{
			subsystem.process();
		}
		return this;
	}
	
//	alias append = pool.append;

	typeof(this) append(Subsystem[] subsystem_list...)
	{
		foreach (subsystem; subsystem_list)
		{
			subsystem.initialize();
			this.pool.append(subsystem);
		}
		return this;
	}

	/+Subsystem[] opIndex(string id)
	{
		return this.pool.all.filter!(subsystem => subsystem.id == id).array();
	}+/
	
}

interface Subsystem
{
	void initialize();
	void finalize();
	void process();
}