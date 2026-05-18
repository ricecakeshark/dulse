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
		foreach_reverse (ref subsystem; this.pool.all)
		{
			subsystem.finalize();
			destroy(subsystem);
		}
		this.pool.clear();
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

	typeof(this) append(Subsystem[] subsystem_list...)
	{
		foreach (ref subsystem; subsystem_list)
		{
			subsystem.initialize();
			this.pool.append(subsystem);
		}
		return this;
	}

	Type query(Type)()
	{
		return this.pool.query!Type();
	}

	typeof(this) query(Type)(out Type out_query)
	{
		this.pool.query(out_query);
		return this;
	}

	typeof(this) query(TypeList...)(out TypeList query_list)
	{
		static foreach (query; query_list)
		{
			this.query(query);
		}
		return this;
	}

	alias pool this;
}

interface Subsystem
{
	void initialize();
	void finalize();
	void process();
}
