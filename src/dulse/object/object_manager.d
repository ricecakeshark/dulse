module dulse.object.object_manager;

import dulse.object;
import std.exception;

import std.algorithm : remove;
import std.conv : to;
import std.meta : allSatisfy;

class ObjectManager
{
	protected EntityStore entity_store;
	protected ComponentStorage component_storage;
	//IObjectSystem[] system_list;
	protected SystemStore system_store;
	protected ResourceStore resource_store;

	this() pure nothrow @safe
	{
		this.entity_store = new EntityStore();
		this.component_storage = new ComponentStorage();
		this.system_store = new SystemStore(this);
		this.resource_store = new ResourceStore();
		return;
	}

	invariant
	{
		assert(this !is null, "this is null");
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

	bool has(Component)() pure nothrow @nogc @safe
	{
		return this.component_storage.has!Component();
	}

	bool has(Component)(Entity entity) pure nothrow @nogc @safe
	{
		if (!this.entity_store.has(entity))
		{
			return false;
		}
		return this.component_storage.has!Component(entity);
	}

	ComponentStore!Component get(Component)() pure @safe
	{
		return this.component_storage.get!Component();
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

	typeof(this) attach(ComponentList...)(Entity[] entity_list...) pure @safe
	{
		enforce(this.entity_store.has_all(entity_list));
		this.component_storage.attach!ComponentList(entity_list);
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
	@property SystemStore system()() pure nothrow @nogc @safe
	{
		return this.system_store;
	}

	typeof(this) register(SystemTypeList...)() @safe
	if (allSatisfy!(isSystemType, SystemTypeList))
	{
		this.system_store.register!SystemTypeList();
		return this;
	}

	typeof(this) remove(SystemTypeList...)() @nogc @safe
	if (allSatisfy!(isSystemType, SystemTypeList))
	{
		this.system_store.remove!SystemTypeList();
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

	typeof(this) append_resource(ResourceList...)() pure nothrow @safe
	{
		this.resource_store.append!(ResourceList);
		return this;
	}

	typeof(this) append_resource(TypeList...)(TypeList resource_list) pure nothrow @safe
	{
		this.resource_store.append!TypeList(resource_list);
		return this;
	}
	// general process
	typeof(this) initialize()
	{
		this.system_store.initialize();
		return this;
	}

	typeof(this) finalize()
	{
		this.system_store.finalize();
		return this;
	}

	typeof(this) process()
	{
		this.system_store.process();
		return this;
	}

}

unittest
{
	import std.algorithm;

	ObjectManager manager;
	Entity[3] entity_list;

	struct Comp1
	{
		float param;
	}

	struct Comp2
	{
		float param;
	}

	manager = new ObjectManager();
	assert(manager.entity.count == 0);
	assert(manager.component.count_component_store == 0);
	manager.append_component!(Comp1, Comp2);
	assert(manager.component.count_component_store == 2);
	assert(manager.has!Comp1 && manager.has!Comp2);
	manager.create(entity_list[]);
	manager.component.attach!(Comp1, Comp2)(entity_list[]);
	assert(manager.entity.count == 3);
	assert(entity_list[].all!(entity => manager.entity.has(entity)));
	manager.release(entity_list[$ - 1]);
	assert(manager.entity.count == 2);
	assert(!manager.entity.has(entity_list[$ - 1]));
	assert(!manager.has!Comp1(entity_list[$ - 1]));
	assert(!manager.has!Comp2(entity_list[$ - 1]));
}
