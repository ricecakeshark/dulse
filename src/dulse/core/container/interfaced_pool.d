module dulse.core.container.interfaced_pool;

import dulse.core.container.pool;
import std.array : array;
import std.algorithm : any, count, filter, map;
import std.meta : anySatisfy;

struct InterfacedPool(Interface)
{
	Interface[] pool;

	@property size_t count() const pure nothrow @nogc @safe
	{
		return this.pool.length;
	}

	size_t count(Type)() pure nothrow
	{
		return this.pool
			.filter!(item => cast(Type) item !is null)()
			.count();
	}

	@property inout(Interface[]) all() inout pure nothrow @nogc @safe
	{
		return this.pool;
	}

	bool have(Type)() pure nothrow @nogc @safe
	{
		return this.pool.any!(item => cast(Type) item !is null);
	}

	bool have(Type)(Type target) pure nothrow @nogc @safe
	{
		return this.pool
			.filter!(item => cast(Type) item !is null)()
			.map!(item => cast(Type) item)
			.any!(item => item is target);
	}

	ref typeof(this) clear() pure nothrow @safe
	{
		this.pool = [];
		return this;
	}

	ref typeof(this) append(TypeList...)() pure nothrow @safe
	{
		foreach (Type; TypeList)
		{
			this.pool ~= new Type();
		}
		return this;
	}

	ref typeof(this) append(Args...)(Args args) pure nothrow @safe
	{
		foreach (item; args)
		{
			this.pool ~= item;
		}
		return this;
	}

	ref typeof(this) remove(RemoveList...)(RemoveList remove_list) pure nothrow @safe
	{
		this.pool.filter!(item => item.isAnyTypeOf!(RemoveList) == false);
		return this;
	}

	ref typeof(this) apply()(void delegate(Interface) dlg)
	{
		foreach (item; this.pool)
		{
			dlg(item);
		}
		return this;
	}

	/+Type query(Type)() pure nothrow @safe
	in
	{
		assert(this.pool.any!(item => (cast(Type) item) !is null), "the Type not found");
	}
	do
	{
		return this.pool
			.filter!(item => cast(Type) item !is null)()
			.map!(item => cast(Type) item)()
			.array()[0];
	}+/

	Type[] query(Type)() pure nothrow @safe
	{
		return this.pool
			.filter!(item => cast(Type) item !is null)()
			.map!(item => cast(Type) item)()
			.array();
	}

	Interface[] query(TypeList...)() pure nothrow @safe
	{
		scope Interface[] temp_list;
		outer: foreach (ref _item; this.pool)
		{
			foreach (Type; TypeList)
			{
				if (cast(Type) _item !is null)
				{
					temp_list ~= _item;
					continue outer;
				}
			}
		}
		return temp_list.dup;
	}

	ref typeof(this) query(TypeList...)(out TypeList query_list) pure nothrow @safe
	{
		foreach (ref _query; query_list)
		{
			this.query(_query);
		}
		return this;
	}

	bool query(Type)(out Type query_buffer) pure nothrow @safe
	{
		if (!this.have!Type)
		{
			return false;
		}
		query_buffer = this.pool
			.filter!(item => cast(Type) item !is null)()
			.map!(item => cast(Type) item)()
			.array()[0];
		return true;
	}

	bool query(Type)(out Type[] query_buffer) pure nothrow @safe
	{
		if (!this.have!Type)
		{
			return false;
		}
		query_buffer = this.pool
			.filter!(item => cast(Type) item !is null)()
			.map!(item => cast(Type) item)()
			.array();
		return true;
	}
}

unittest
{
	import std.format;

	interface IC
	{
	}

	class C1 : IC
	{
	}

	class C2 : IC
	{
	}

	class C3 : IC
	{

	}

	C1 a = new C1();
	C2 b = new C2();
	C1 c = new C1();

	InterfacedPool!(IC) pool;

	assert(pool.count == 0);
	assert(pool.have!C1 == false);
	assert(pool.count!C1 == 0);
	assert(pool.have!C2 == false);
	assert(pool.count!C2 == 0);
	pool.append(a, b, c);
	assert(pool.have!C1 == true);
	assert(pool.count!C1 == 2);
	assert(pool.query!C1 == [a, c]);
	assert(pool.have!C2 == true);
	assert(pool.count!C2 == 1);
	assert(pool.query!C2 == [b]);
	assert(pool.have!C3 == false);
	assert(pool.count!C3 == 0);
	assert(pool.query!(C1, C2) == [a, b, c]);
}

bool isAnyTypeOf(Types...)(target) pure nothrow @safe
{
	bool found = false;
	static foreach (Type; Types)
	{
		found |= cast(Type) target !is null;
	}
	return found;
}
