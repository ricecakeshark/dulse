module dulse.core.subsystem;

import dulse.core;
import std.array, std.algorithm;

class SubsystemPool
{
	InterfacedPool!(ISubsystem) pool;
	Core core;

	this(Core core)
	{
		this.core = core;
		return;
	}

	typeof(this) initialize()
	{
		foreach (ref subsystem; this.pool.all)
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
		foreach (ref subsystem; this.pool.all)
		{
			subsystem.process();
		}
		return this;
	}

	typeof(this) append(TypeList...)(TypeList subsystem_list)
	{
		foreach (ref subsystem; subsystem_list)
		{
			assert(cast(ISubsystem) subsystem !is null);
			this.pool.append(cast(ISubsystem) subsystem);
		}
		/+foreach (ref subsystem; subsystem_list)
		{
			subsystem.initialize();
		}+/
		return this;
	}

	typeof(this) append(TypeList...)()
	{
		static foreach (Type; TypeList)
		{
			static assert(is(Type : ISubsystem));
		}

		foreach (Type; TypeList)
		{
			this.pool.append(new Type(core));
		}
		return this;
	}

	Type query(Type)()
	{
		return this.pool.query!Type();
	}

	typeof(this) query(TypeList...)(out TypeList query_list)
	{
		static foreach (query; query_list)
		{
			this.query(query);
		}
		return this;
	}

	typeof(this) query(Type)(out Type out_query)
	{
		this.pool.query(out_query);
		return this;
	}

	alias pool this;
}

interface ISubsystem
{
	ISubsystem initialize();
	ISubsystem finalize();
	ISubsystem process();
}

abstract class Subsystem(ActualSubsystem) : ISubsystem
{
	protected Core core;

	this(Core core)
	{
		this.core = core;
		return;
	}

	abstract ActualSubsystem initialize();
	abstract ActualSubsystem finalize();
	abstract ActualSubsystem process();

	invariant
	{
		assert(this !is null);
	}
}
