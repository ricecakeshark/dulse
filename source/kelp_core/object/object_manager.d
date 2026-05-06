module kelp_core.object.object_manager;

import kelp_core.object;
import std.exception;
import std.meta : staticIndexOf, staticMap;
import std.traits : InterfacesTuple;
import std.algorithm : remove;
import std.conv : to;

class ObjectManager
{
	EntityStore entity_store;
	IComponentStore[TypeInfo] component_store_list;
	IObjectSystem[] system_list;
	ResourceStore resource_store;

	this() pure nothrow @safe
	{
		this.entity_store = new EntityStore();
		return;
	}
	// Entity
	@property size_t count_entity() const pure nothrow @nogc @safe
	{
		return this.entity_store.count;
	}

	@property ref Entity[] list_entity() pure nothrow @nogc @safe
	{
		return this.entity_store.all;
	}

	typeof(this) create(Entity[] out_entity_list...) pure nothrow @safe
	{
		this.entity_store.create(out_entity_list);
		return this;
	}
	// Component
	@property size_t count_component_store() const pure nothrow @nogc @safe
	{
		return this.component_store_list.length;
	}

	@property IComponentStore[] list_component() pure nothrow @safe
	{
		return this.component_store_list.values;
	}

	ComponentStore!Component get(Component)() pure @safe
	{
		enforce((typeid(Component) in component_store_list) !is null);
		enforce((cast(ComponentStore!Component) component_store_list[typeid(Component)]) !is null);
		return cast(ComponentStore!Component) component_store_list[typeid(Component)];
	}

	typeof(this) query(ComponentList...)(
		out staticMap!(ComponentStore, ComponentList) out_list
	) pure @safe
	{
		static foreach (count, Component; ComponentList)
		{
			out_list[count] = this.get_store!Component();
		}
		return this;
	}

	typeof(this) query(Component)(out ComponentStore!Component out_buf) pure @safe
	{
		out_buf = this.get!Component();
		return this;
	}

	typeof(this) register(Component)() pure nothrow @safe
	if (is(Component == struct))
	{
		component_store_list[typeid(Component)] = new ComponentStore!Component();
		return this;
	}

	typeof(this) remove(Component)() pure nothrow @nogc @safe
	{
		component_store_list.remove(typeid(Component));
		return this;
	}

	typeof(this) attach(Component)(Entity entity) pure @safe
	{
		enforce(typeid(Component) in this.component_store_list);
		scope store = (cast(ComponentStore!Component) this.component_store_list[typeid(Component)]);
		store.attach(entity);
		return this;
	}

	typeof(this) attach(Component)(Entity[] entity_list...) pure @safe
	{
		enforce(typeid(Component) in this.component_store_list);
		(cast(ComponentStore!Component) this.component_store_list[typeid(Component)]).attach(
			entity_list);
		return this;
	}

	ref Component get_component(Component)(Entity entity) pure @safe
	{
		enforce(typeid(Component) in this.component_store_list);
		return (cast(ComponentStore!Component) this.component_store_list[typeid(Component)])
			.get(entity);
	}

	// System
	@property size_t count_system() pure nothrow @nogc @safe
	{
		return this.system_list.length;
	}

	@property IObjectSystem[] list_system() pure nothrow @nogc @safe
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
	@property size_t count_resource()
	{
		return this.resource_store.count;
	}

	@property bool has(Resource)()
	{
		return this.resource_store.has!Resource;
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

	typeof(this) process()
	{
		foreach (system; this.system_list)
		{
			system.process(this);
		}
		return this;
	}

	typeof(this) with_store(Component)(
		void delegate(ComponentStore!Component) dlg
	)
	{
		dlg(this.get!Component());
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

unittest
{
	ObjectManager manager;
	Entity[3] entity;

	struct Comp
	{
		float param;
	}

	manager = new ObjectManager();
	assert(manager.count_entity == 0);
	assert(manager.count_component_store == 0);
	manager.register!Comp();
	assert(manager.count_component_store == 1);
	manager.create(entity[]);
	manager.attach!Comp(entity[]);
	assert(manager.count_entity == 3);
}
