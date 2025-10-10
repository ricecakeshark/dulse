module kelp_core.core.structure.interfaced_pool;

import kelp_core.core.structure.pool;
import std.array, std.algorithm;

class InterfacedPool(Interface) : Pool!(InterfacedPool, Interface)
{
	Interface[] pool;

	@property size_t count() const pure nothrow @nogc @safe
	{
		return this.pool.length;
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

	//@disable bool have_any(Args...)() pure nothrow @nogc @safe; 
	/+bool have_any(Args...)() pure nothrow @nogc @safe
	{
		return this.pool.any!(item => item.isAnyTypeOf!(Args));
	}+/
	//@disable bool have_all(Args...)() pure nothrow @nogc @safe; 
	/+bool have_all(Args...)(Args args) pure nothrow @nogc @safe
	{
		return this.pool.any!(item => item.isAnyTypeOf!(Args));
	}+/

	Type[] query(Type)() pure nothrow
	{
		return this.pool
			.filter!(item => cast(Type) item !is null)()
			.map!(item => cast(Type) item)()
			.array();
	}

	typeof(this) clear() pure nothrow @safe
	{
		this.pool = [];
		return this;
	}

	typeof(this) append(Args...)(Args args) pure nothrow @safe
	{
		foreach (item; args)
		{
			this.pool ~= item;
		}
		return this;
	}

	typeof(this) remove(RemoveList...)(RemoveList remove_list) pure nothrow @safe
	{
		this.pool.filter!(item=>item.isAnyTypeOf!(RemoveList)==false);
		return this;
	}
}

unittest
{
	import std.format;
	import std.stdio;

	interface IC
	{
	}

	class C1 : IC
	{
	}

	class C2 : IC
	{
	}

	class TestPool : InterfacedPool!(IC)
	{
	}

	C1 a = new C1();
	C2 b = new C2();
	C1 c = new C1();

	TestPool pool;
	pool = new TestPool();

	assert(pool.count == 0);
	assert(pool.contain!(C1)() == false);
	assert(pool.query!(C1)() == []);
	assert(pool.contain!(C2)() == false);
	assert(pool.query!(C2)() == []);
	pool.register(a, b, c);
	assert(pool.contain!(C1)() == true);
	assert(pool.query!(C1)() == [a, c]);
	assert(pool.contain!(C2)() == true);
	assert(pool.query!(C2)() == [b]);

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
