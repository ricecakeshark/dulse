module kelp_core.object.object_manager;

import kelp_core.object;
import std.exception;
import std.meta : staticIndexOf,staticMap;
import std.traits : InterfacesTuple;
import std.algorithm : remove;
import std.conv:to;

class ObjectManager
{
	EntityStore entity_store;
	IComponentStore[TypeInfo] component_store_list;
	IObjectSystem[] system_list;

	this()
	{
		this.entity_store = new EntityStore();
		return;
	}
	// Entity
	@property ref Entity[] list_entity() pure nothrow @nogc @safe
	{
		return this.entity_store.all;
	}

	typeof(this) create(Entity[] out_entity_list...)
	{
		this.entity_store.create(out_entity_list);
		return this;
	}
	// Component
	@property ref Entity[] list_component() pure nothrow @nogc @safe
	{
		return this.entity_store.all;
	}

	ComponentStore!Component get(Component)()
	{
		auto store_ref = typeid(Component) in component_store_list;
		enforce(store_ref !is null);
		auto store_ref_2 = cast(ComponentStore!Component)*store_ref;
		enforce(store_ref_2 !is null);
		return store_ref_2;
	}

	typeof(this) query(ComponentList...)(
		out staticMap!(ComponentStore, ComponentList) out_list
	)
	{
		static foreach (count, Component; ComponentList)
		{
			out_list[count] = this.get_store!Component();
		}
		return this;
	}

	typeof(this) query(Component)(out ComponentStore!Component out_buf)
	{
		out_buf = this.get!Component();
		return this;
	}

	typeof(this) register(Component)()
	if (is(Component == struct))
	{
		component_store_list[typeid(Component)] = new ComponentStore!Component();
		return this;
	}

	typeof(this) remove(Component)()
	{
		component_store_list.remove(typeid(Component));
		return this;
	}

	typeof(this) attach(Component)(Entity entity)
	{
		enforce(typeid(Component) in this.component_store_list);
		auto store = cast(ComponentStore!Component)(this.component_store_list[typeid(Component)]);
		store.attach(entity);
		return this;
	}

	typeof(this) attach(Component)(Entity[] entity_list...)
	{
		enforce(typeid(Component) in this.component_store_list);
		cast(ComponentStore!Component)(this.component_store_list[typeid(Component)]).attach(entity_list);
		return this;
	}

	ref Component get_component(Component)(Entity entity)
	{
		return this.component_store_list[typeid(Component)]
			.to!(ComponentStore!Component)
			.get(entity);
	}

	// System
	@property IObjectSystem[] list_system() pure nothrow @nogc @safe
	{
		return this.system_list;
	}

	typeof(this) register(SystemType)()
	if (isSystemType!SystemType)
	{
		system_list ~= new SystemType();
		return this;
	}

	typeof(this) remove(SystemType)(SystemType system)
	if (isSystemType!SystemType)
	{
		system_list.remove(system);
		return this;
	}

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

	typeof(this) with_store(Component)(void delegate(ComponentStore!Component) dlg)
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

	manager.register!Comp();
	manager.create(entity[]);
	manager.attach(entity[]);


}