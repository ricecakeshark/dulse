module kelp_core.core.container.mono_pool;

import kelp_core.core.container.pool;
import std.array : array;
import std.algorithm;

class MonoPool(TItem) : Pool!(MonoPool, TItem)
{
	TItem[] item_list;

	this()
	{
		return;
	}

	@property size_t count() const pure nothrow @nogc @safe
	{
		return this.item_list.length;
	}

	bool have(TItem search_item) const pure nothrow @nogc @safe
	{
		return item_list.canFind(search_item);
	}

	bool have_any(TItem[] search_list...) const pure nothrow @nogc @safe
	{
		return search_list.any!(item => item_list.canFind(item))();
	}

	bool have_all(TItem[] search_list...) const pure nothrow @nogc @safe
	{
		return search_list.all!(item => item_list.canFind(item))();
	}

	@property inout(TItem[]) all() inout pure nothrow @nogc @safe
	{
		return this.item_list;
	}

	typeof(this) clear() pure nothrow @safe
	{
		this.item_list = [];
		return this;
	}

	typeof(this) append(TItem[] append_list...) pure nothrow @safe
	{
		this.item_list ~= append_list;
		return this;
	}

	typeof(this) remove(TItem[] remove_list...) pure nothrow @safe
	{
		this.item_list = this.item_list
			.filter!(item => !remove_list.canFind(item))
			.array();
		return this;
	}
}

unittest
{
	enum E
	{
		a,
		b,
		c,
		d,
	}

	MonoPool!(E) pool = new MonoPool!(E);

	assert(pool.count == 0);
	assert(!pool.have_any(E.a, E.b, E.c));
	pool.append(E.a, E.b, E.c);
	assert(pool.count == 3);
	assert(!pool.have(E.d));
	assert(pool.have_all(E.a, E.b, E.c));
}
