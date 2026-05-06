module kelp_core.object.resource_store;

import std.algorithm;
import std.exception;

class ResourceStore
{
	IResourceBox[TypeInfo] resource_list;

	this()
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

	typeof(this) clear() pure nothrow @nogc @safe
	{
		this.resource_list.clear();
		return this;
	}

	typeof(this) append(Type)(Type resource) pure nothrow @safe
	{
		resource_list[typeid(Type)] = new ResourceBox!Type(resource);
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

	typeof(this) remove(Type)() pure nothrow @safe
	{
		resource_list.remove(typeid(Type));
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

	typeof(this) query(Type)(out Type out_resource)
	{
		enforce(this.has!Type);
		out_resource = this.resource_list[TypeInfo(Type)];
		return this;
	}

	typeof(this) query(TypeList...)(out TypeList out_resource_list)
	{
		foreach (out_resource; out_resource_list)
		{
			this.query(out_resource);
		}
		return this;
	}
}

class ResourceBox(Type) : IResourceBox
{
	Type resource;

	this(Type resource)
	{
		this.resource = resource;
		return;
	}
}

interface IResourceBox
{

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
