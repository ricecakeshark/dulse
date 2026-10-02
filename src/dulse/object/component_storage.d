module dulse.object.component_storage;

import dulse.object;
import std.exception : enforce;

class ComponentStorage
{
	IComponentStore[TypeInfo] component_store_list;

	@property size_t count_component_store() const pure nothrow @nogc @safe
	{
		return this.component_store_list.length;
	}

	@property IComponentStore[] list_component() pure nothrow @safe
	{
		return this.component_store_list.values;
	}

	bool has(Component)() pure nothrow @nogc @safe
	{
		if ((typeid(Component) in this.component_store_list) is null)
		{
			return false;
		}
		return true;
	}

	bool has(Component)(Entity entity) pure nothrow @nogc @safe
	{
		if ((typeid(Component) in this.component_store_list) is null)
		{
			return false;
		}
		return (cast(ComponentStore!Component) this.component_store_list[typeid(Component)])
			.has(entity);
	}

	ComponentStore!Component get(Component)() pure @safe
	{
		enforce((typeid(Component) in component_store_list) !is null);
		enforce((cast(ComponentStore!Component) component_store_list[typeid(Component)]) !is null);
		return cast(ComponentStore!Component) component_store_list[typeid(Component)];
	}

	ref Component get(Component)(Entity entity) pure @safe
	{
		enforce(typeid(Component) in this.component_store_list);
		return (cast(ComponentStore!Component) this.component_store_list[typeid(Component)])
			.get(entity);
	}

	typeof(this) query(Component)(out ComponentStore!Component out_buf) pure @safe
	{
		out_buf = this.get!Component();
		return this;
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
	// register Component
	typeof(this) append(Component)() pure nothrow @safe
	if (is(Component == struct))
	{
		component_store_list[typeid(Component)] = new ComponentStore!Component();
		return this;
	}

	typeof(this) append(ComponentList...)() pure nothrow @safe
	{
		foreach (Component; ComponentList)
		{
			this.append!Component();
		}
		return this;
	}

	typeof(this) remove(Component)() pure nothrow @nogc @safe
	{
		component_store_list.remove(typeid(Component));
		return this;
	}
	// attach Entity with Component
	typeof(this) attach(Component)(Entity[] entity_list...) pure @safe
	{
		enforce(typeid(Component) in this.component_store_list, "the component is not had by component storage.");
		this.component_store_list[typeid(Component)]
			.attach(entity_list);
		/+(cast(ComponentStore!Component) this.component_store_list[typeid(Component)])
			.attach(entity_list);+/
		return this;
	}
	// attach with components
	typeof(this) attach(ComponentList...)(Entity[] entity_list...) pure @safe
	{
		foreach (Component; ComponentList)
		{
			enforce(typeid(Component) in this.component_store_list);
			this.component_store_list[typeid(Component)]
				.attach(entity_list);
		}
		return this;
	}
	// detach from component
	typeof(this) detach(Component)(Entity[] entity_list...) pure nothrow @safe
	{
		enforce(typeid(Component) in this.component_store_list);
		this.component_store_list[typeid(Component)]
			.detach(entity_list);
		/+(cast(ComponentStore!Component) this.component_store_list[typeid(Component)])
			.detach(entity_list);+/
		return this;
	}
	// detach for components
	typeof(this) detach(ComponentList...)(Entity[] entity_list...) pure nothrow @safe
	{
		foreach (Component; ComponentList)
		{
			enforce(typeid(Component) in this.component_store_list);
			(cast(ComponentStore!Component) this.component_store_list[typeid(Component)])
				.detach(entity_list);
		}
		return this;
	}
	// detach for all component
	typeof(this) detach(Entity[] entity_list...) pure nothrow @safe
	{
		foreach (key, component_store; this.component_store_list)
		{
			component_store.detach(entity_list);
		}
		return this;
	}
}

unittest
{
	import std.algorithm;

	ComponentStorage storage;
	Entity[3] entity_list;
	struct C1
	{

	}

	struct C2
	{

	}

	storage = new ComponentStorage();
	foreach (ref key, entity; entity_list)
	{
		entity = Entity(cast(uint) key);
	}

	storage.append!(C1, C2);
	storage.attach!(C1, C2)(entity_list);

	assert(storage.has!(C1) == true);
	assert(storage.has!(C2) == true);
	assert(entity_list[].all!(entity => storage.has!C1(entity)));
	assert(entity_list[].all!(entity => storage.has!C2(entity)));

}
