module kelp_core.object.object_manager;

import kelp_core.object;
import std.exception;
import std.meta : allSatisfy,staticIndexOf, staticMap;
import std.traits : InterfacesTuple;
import std.algorithm : remove;
import std.conv : to;

class ObjectManager
{
	EntityStore entity_store;
	ComponentStorage component_storage;
	IObjectSystem[] system_list;
	ResourceStore resource_store;

	this() pure nothrow @safe
	{
		this.entity_store = new EntityStore();
		this.component_storage = new ComponentStorage();
		this.resource_store = new ResourceStore();
		return;
	}

	// EntityStore
	@property ref EntityStore entity() pure nothrow @nogc @safe
	{
		return this.entity_store;
	}

	typeof(this) create(Entity[] out_entity_list...) pure nothrow @safe
	{
		this.entity_store.create(out_entity_list);
		return this;
	}

	typeof(this) release(Entity[] entity_list...) pure nothrow @safe
	{
		this.entity_store.release(entity_list);
		// later
		this.component_storage.detach(entity_list);
		return this;
	}
	// Component
	@property ref ComponentStorage component() pure nothrow @nogc @safe
	{
		return this.component_storage;
	}

	bool has(Component)(Entity entity) pure nothrow @nogc @safe
	{
		if (!this.entity_store.has(entity))
		{
			return false;
		}
		return this.component_storage.has!Component(entity);
	}

	ref Component get(Component)(Entity entity) pure @safe
	{
		enofrce(this.entity_store.has(entity));
		return this.component_storage.get!Component(entity);
	}

	typeof(this) append_component(ComponentTypeList...)()
	if (allSatisfy!(isStructType, ComponentTypeList))
	{
		this.component_storage.append!ComponentTypeList();
		return this;
	}

	typeof(this) attach(Component)(Entity[] entity_list...) pure @safe
	{
		enforce(this.entity_store.has_all(entity_list));
		this.component_storage.attach!Component(entity_list);
		return this;
	}

	typeof(this) detach(Component)(Entity[] entity_list...) pure @safe
	{
		this.component_storage.detach!Component(entity_list);
		return this;
	}

	typeof(this) with_in(
		void delegate(ref ComponentStorage) dlg
	)
	{
		dlg(this.component_storage);
		return this;
	}
	// System
	@property ref IObjectSystem[] system()() pure nothrow @nogc @safe
	{
		return this.system_list;
	}

	deprecated @property size_t count_system() pure nothrow @nogc @safe
	{
		return this.system_list.length;
	}

	deprecated @property IObjectSystem[] list_system() pure nothrow @nogc @safe
	{
		return this.system_list;
	}

	typeof(this) register(SystemType)() pure nothrow @safe
	if (isSystemType!SystemType)
	{
		system_list ~= new SystemType();
		return this;
	}

	typeof(this) remove(SystemType)(SystemType system) pure nothrow @nogc @safe
	if (isSystemType!SystemType)
	{
		system_list.remove(system);
		return this;
	}
	// Resouce
	@property ResourceStore resource() pure nothrow @nogc @safe
	{
		return this.resource_store;
	}

	@property size_t count_resource() pure nothrow @nogc @safe
	{
		return this.resource_store.count;
	}

	typeof(this) append_resource(TypeList...)(TypeList resource_list) pure nothrow @safe
	{
		this.resource_store.append!TypeList(resource_list);
		return this;
	}
	// general process
	typeof(this) initialize()
	{
		foreach (system; this.system_list)
		{
			system.initialize(this);
		}
		return this;
	}

	typeof(this) finalize()
	{
		foreach (system; this.system_list)
		{
			system.finalize(this);
		}
		return this;
	}

	typeof(this) process()
	{
		foreach (system; this.system_list)
		{
			system.process(this);
		}
		return this;
	}

}

template isComponentType(T)
{
	enum bool isComponentType = is(T == struct) && staticIndexOf!(IComponentStore, InterfacesTuple!T) >= 0;
}

template isSystemType(T)
{
	enum bool isSystemType = is(T == class) && staticIndexOf!(IObjectSystem, InterfacesTuple!T) >= 0;
}

template isStructType(T)
{
	enum bool isStructType = is(T == struct);
}

unittest
{
	ObjectManager manager;
	Entity[3] entity;

	struct Comp
	{
		float param;
	}

	manager = new ObjectManager();
	assert(manager.entity.count == 0);
	assert(manager.component.count_component_store == 0);
	manager.append_component!(Comp);
	assert(manager.component.count_component_store == 1);
	manager.create(entity[]);
	manager.component.attach!(Comp)(entity[]);
	assert(manager.entity.count == 3);
}
