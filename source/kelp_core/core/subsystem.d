module kelp_core.core.subsystem;

//import kelp_api;
import kelp_core.core;
import std.array, std.algorithm;

class SubsystemPool : InterfacedPool!(Subsystem)
{
	//Subsystem[] pool;

	typeof(this) initialize()
	{
		foreach (subsystem; this.pool)
		{
			subsystem.initialize();
		}
		return this;
	}

	typeof(this) finalize()
	{
		foreach_reverse (subsystem; this.pool)
		{
			subsystem.finalize();
		}
		return this;
	}

	typeof(this) process()
	{
		foreach (subsystem; this.pool)
		{
			subsystem.process();
		}
		return this;
	}
	/+
	typeof(this) append(Subsystem[] subsystem_list...)
	{
		foreach (subsystem; subsystem_list)
		{
			subsystem.initialize();
			pool ~= subsystem;
		}
		return this;
	}

	Subsystem[] opIndex(string id)
	{
		return this.pool.filter!(subsystem => subsystem.id == id).array();
	}
	+/
}

interface Subsystem
{
	void initialize();
	void finalize();
	void process();
}