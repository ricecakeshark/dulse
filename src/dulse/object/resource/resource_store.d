module dulse.object.resource.resource_store;

import dulse.object.resource;
import std.exception:enforce;

class ResourceStore
{
	IResourceBox[TypeInfo] resource_list;

	this() pure nothrow @trusted
	{
		this.resource_list = new IResourceBox[TypeInfo];
		return;
	}

	@property bool has(Type)() pure nothrow @nogc @safe
	{
		return (typeid(Type) in resource_list) !is null;
	}

	@property size_t count() pure nothrow @nogc @safe
	{
		return this.resource_list.length;
	}

	ref Resource query(Resource)() pure nothrow @nogc @safe
	{
		return (cast(ResourceBox!Resource) this.resource_list[typeid(Resource)]).get();
	}

	typeof(this) clear() pure nothrow @nogc @safe
	{
		this.resource_list.clear();
		return this;
	}

	typeof(this) append(ResourceList...)() pure nothrow @safe
	{
		foreach (Resource; ResourceList)
		{
			this.append(Resource());
		}
		return this;
	}

	typeof(this) append(TypeList...)(TypeList resource_list) pure nothrow @safe
	{
		foreach (resource; resource_list)
		{
			this.append(resource);
		}
		return this;
	}

	typeof(this) append(Type)(Type resource) pure nothrow @safe
	{
		resource_list[typeid(Type)] = new ResourceBox!Type(resource);
		return this;
	}

	typeof(this) remove(TypeList...)() pure nothrow @safe
	{
		foreach (Type; TypeList)
		{
			resource_list.remove(typeid(Type));
		}
		return this;
	}

	typeof(this) remove(Type)() pure nothrow @safe
	{
		resource_list.remove(typeid(Type));
		return this;
	}

	typeof(this) query(Type)(out Type out_resource) pure nothrow @safe
	{
		enforce(this.has!Type);
		out_resource = this.resource_list[TypeInfo(Type)];
		return this;
	}

	typeof(this) query(TypeList...)(out TypeList out_resource_list) pure nothrow @safe
	{
		foreach (out_resource; out_resource_list)
		{
			this.query(out_resource);
		}
		return this;
	}
}

unittest
{
	ResourceStore store;
	struct S1
	{
	}

	struct S2
	{
	}

	struct S3
	{
	}

	store = new ResourceStore();
	assert(store.count == 0);
	assert(store.has!S1() == false);
	assert(store.has!S2() == false);
	assert(store.has!S3() == false);
	store.append(S1(), S2());
	assert(store.count == 2);
	assert(store.has!S1);
	assert(store.has!S2);
	store.remove!S2();
	assert(store.count == 1);
	assert(store.has!S2 == false);
	store.clear();
	assert(store.count == 0);
	assert(store.has!S1() == false);
	assert(store.has!S2() == false);
	assert(store.has!S3() == false);
}
