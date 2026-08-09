module source.kelp_core.core.container.index_pool;

import std.algorithm : any,canFind, count, remove, map, SwapStrategy;
import std.array : array;
import std.traits : isIntegral;
import std.typecons;

struct IndexPool(Type)
if (isIntegral!Type)
{
	Type[] index_pool;
	Type[] freed_pool;

	@disable this(this);

	size_t count() const pure nothrow @nogc @safe
	{
		return index_pool.length;
	}

	size_t count_freed() const pure nothrow @nogc @safe
	{
		return freed_pool.length;
	}

	ref typeof(this) query(IndexBox!Type[] index_list...) pure nothrow @safe
	{
		foreach (ref index; index_list)
		{
			this.query(index);
		}
		return this;
	}

	ref typeof(this) query(ref IndexBox!Type index) pure nothrow @safe
	{
		if (!index.is_null)
		{
			return this;
		}

		if (freed_pool.length > 0)
		{
			index = IndexBox!Type(freed_pool[$ - 1u]);
			index_pool ~= freed_pool[$ - 1u];
			freed_pool.length--;
			return this;
		}

		index = IndexBox!Type(index_pool.length);
		index_pool ~= index.get;
		return this;
	}

	ref typeof(this) restitute(IndexBox!Type[] index_list...) pure nothrow @safe
	{
		foreach (ref index; index_list)
		{
			this.restitute(index);
		}
		return this;
	}

	ref typeof(this) restitute(ref IndexBox!Type index) pure nothrow @safe
	{
		if (index.is_null)
		{
			return this;
		}

		if (!canFind(index_pool, index.get))
		{
			index.nullify;
			return this;
		}
		this.index_pool
			= this.index_pool.remove!(elem => elem == index.index, SwapStrategy.unstable);
		this.freed_pool ~= index.get;
		index.nullify;
		return this;
	}
}

struct IndexBox(Type)
{
	Nullable!Type index;

	this(Type value) pure nothrow @nogc @safe
	{
		this.index = Nullable!Type(value);
		return;
	}

	bool is_null() const pure nothrow @nogc @safe
	{
		return this.index.isNull;
	}

	Type get() pure nothrow @nogc @safe
	{
		return this.index.get;
	}

	ref typeof(this) nullify() return pure nothrow @nogc @safe
	{
		this.index.nullify;
		return this;
	}
}

bool contain_null(Type)(IndexBox!Type[] box_list) pure nothrow @nogc @safe
{
	return box_list.any!(box => box.is_null);
}

Type[] get(Type)(IndexBox!Type[] box_list) pure nothrow @safe
{
	return box_list.map!(box => box.get).array();
}

unittest
{
	IndexPool!size_t pool;
	IndexBox!size_t[3] index_list;

	assert(pool.count == 0 && pool.count_freed == 0);
	pool.query(index_list);
	pool.query(index_list);
	assert(pool.count == 3 && pool.count_freed == 0);
	assert(!index_list.contain_null);
	assert(index_list.get == [0, 1, 2]);
	pool.restitute(index_list);
	pool.restitute(index_list);
	assert(pool.count == 0 && pool.count_freed == 3);
}
