module kelp_core.object.object_store;

import kelp_core.object;
import std.exception;
import std.meta;
import std.traits;

class ObjectManager(Entity)
{
	alias StoreOf(Component) = ComponentStore!(Entity, Component);

	IComponentStore[TypeInfo] component_store_list;
	IObjectSystem!Entity[] system_list;

	typeof(this) register(Component)()
	if (is(Component == struct))
	{
		component_store_list[typeid(Component)] = new StoreOf!Component();
		return this;
	}

	typeof(this) register(SystemType)()
	if (isSystemType!(SystemType, Entity))
	{
		system_list ~= new SystemType();
		return this;
	}

	StoreOf!Component get_store(Component)()
	{
		auto store_ref = typeid(Component) in component_store_list;
		enforce(store_ref !is null);
		auto store_ref_2 = cast(StoreOf!Component) *store_ref;
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

template isSystemType(T, Entity)
{
	enum bool isSystemType = is(T == class) && staticIndexOf!(IObjectSystem!Entity, InterfacesTuple!T) >= 0;
}
