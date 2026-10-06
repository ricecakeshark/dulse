module dulse.object.system_store;

import dulse.object;
import dulse.core.container : InterfacedPool;
import std.exception : enforce;
import std.meta;

class SystemStore
{
	protected InterfacedPool!IObjectSystem system_list;
	protected ObjectManager manager;

	this(ObjectManager manager) pure nothrow @nogc @safe
	{
		this.manager = manager;
		return;
	}

	invariant
	{
		assert(this !is null, "this is null");
	}

	IObjectSystem[] list()
	{
		return this.system_list.all;
	}

	@property size_t count()
	{
		return this.system_list.count;
	}

	bool have(SystemType)()
	{
		return this.system_list.have!SystemType();
	}

	typeof(this) clear()
	{
		this.system_list.clear();
		return this;
	}

	typeof(this) register(SystemTypeList...)() @safe
	{
		assert(allSatisfy!(isSystemType, SystemTypeList));
		this.system_list.append!SystemTypeList();
		foreach (ref system; this.system_list.query!SystemTypeList())
		{
			system.initialize(this.manager);
		}
		return this;
	}

	typeof(this) unregister(SystemTypeList...)()
	{
		assert(allSatisfy!(isSystemType, SystemTypeList));
		foreach (ref system; this.system_list.query!SystemTypeList())
		{
			system.finalize(this.manager);
		}
		this.system_list.remove!SystemTypeList();
		return this;
	}

	typeof(this) initialize()
	{
		foreach (ref system; this.list)
		{
			system.initialize(manager);
		}
		return this;
	}

	typeof(this) finalize()
	{
		foreach (ref system; this.list)
		{
			system.finalize(manager);
		}
		return this;
	}

	typeof(this) process()
	{
		foreach (ref system; this.list)
		{
			system.process(manager);
		}
		return this;
	}
}
