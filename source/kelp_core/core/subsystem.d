module kelp_core.core.subsystem;

import kelp_api;

class SubsystemPool
{
	Subsystem[] pool;

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

	typeof(this) append(Subsystem[] subsystem_list...)
	{
		foreach (subsystem; subsystem_list)
		{
			subsystem.initialize();
			pool ~= subsystem;
		}
		return this;
	}
}
