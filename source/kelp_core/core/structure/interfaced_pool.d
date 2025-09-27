module kelp_core.core.structure.interfaced_pool;

import std.array, std.algorithm;

abstract class InterfacedPool(Pool, Interface)
{
	Interface[] pool;

	@property size_t count() const pure nothrow @nogc @safe
	{
		return this.pool.length;
	}

	bool contain(Type)() pure nothrow @nogc @safe
	{
		return this.pool.any!(item => cast(Type) item !is null);
	}

	bool contain(Type)(Type target) pure nothrow @nogc @safe
	{
		return this.pool
			.filter!(item => cast(Type) item !is null)()
			.map!(item => cast(Type) item)
			.any!(item => item is target);
	}

	Type[] query(Type)() pure nothrow
	{
		return this.pool
			.filter!(item => cast(Type) item !is null)()
			.map!(item => cast(Type) item)()
			.array();
	}

	typeof(this) register(Args...)(Args args)
	{
		foreach (item; args)
		{
			this.pool ~= item;
		}
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

	class TestPool : InterfacedPool!(TestPool, IC)
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
