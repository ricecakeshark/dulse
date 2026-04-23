module kelp_core.object.object_manager;

import kelp_core.object;
import std.exception;
import std.meta : staticIndexOf;
import std.traits : InterfacesTuple;
import std.algorithm : remove;

class ObjectManager(EntityType)
{
	alias StoreOf(Component) = ComponentStore!(EntityType, Component);

	EntityStore entity_store;
	IComponentStore[TypeInfo] component_store_list;
	IObjectSystem!EntityType[] system_list;

	this()
	{
		this.entity_store = new EntityStore();
		return;
	}

	typeof(this) create(Entity[] out_entity_list...)
	{
		this.entity_store.create(out_entity_list);
		return this;
	}

	typeof(this) register(Component)()
	if (is(Component == struct))
	{
		component_store_list[typeid(Component)] = new StoreOf!Component();
		return this;
	}

	typeof(this) remove(Component)()
	{
		component_store_list.remove(typeid(Component));
		return this;
	}

	typeof(this) register(SystemType)()
	if (isSystemType!(SystemType, EntityType))
	{
		system_list ~= new SystemType();
		return this;
	}

	typeof(this) remove(SystemType)(SystemType system)
	if (isSystemType!(SystemType, EntityType))
	{
		system_list.remove(system);
		return this;
	}

	StoreOf!Component get_store(Component)()
	{
		auto store_ref = typeid(Component) in component_store_list;
		enforce(store_ref !is null);
		auto store_ref_2 = cast(StoreOf!Component)*store_ref;
		enforce(store_ref_2 !is null);
		return store_ref_2;
	}

	typeof(this) store(ComponentList...)(
		out staticMap!(StoreOf, ComponentList) out_list
	)
	{
		static foreach (count, Component; ComponentList)
		{
			out_list[count] = this.get_store!Component();
		}
		return this;
	}

	typeof(this) store(Component)(out StoreOf!Component out_buf)
	{
		out_buf = this.get_store!Component();
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

	typeof(this) with_store(Component)(void delegate(StoreOf!Component) dlg)
	{
		//scope StoreOf!Component store;
		dlg(this.get_store!Component());
		return this;
	}

}

template isComponentType(T)
{
	enum bool isComponentType = is(T == class) && staticIndexOf!(IComponentStore, InterfacesTuple!T) >= 0;
}

template isSystemType(T, EntityType)
{
	enum bool isSystemType = is(T == class) && staticIndexOf!(IObjectSystem!EntityType, InterfacesTuple!T) >= 0;
}
