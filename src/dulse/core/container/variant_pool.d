module dulse.core.container.variant_pool;

import dulse.core.container.pool;
import std.array : array;
import std.algorithm : any, filter, map;
import std.sumtype;
import std.traits : isArray;

struct VariantPool(TypeList)
{
	TypeList[] item_list;

	@property size_t count() const pure nothrow @nogc @safe
	{
		return this.item_list.length;
	}

	@property bool is_empty() const pure nothrow @nogc @safe
	{
		return (this.item_list.length == 0);
	}

	@property inout(TypeList[]) all() inout pure nothrow @nogc @safe
	{
		return this.item_list;
	}

	bool have(Type)() pure nothrow @nogc @safe
	{
		return this.item_list.any!(item => item.has!(Type));
	}

	bool have(Type)(Type search_item) pure nothrow @nogc @safe
	{
		return this.item_list
			.filter!(item => item.has!(Type))
			.map!(item => item.get!(Type)())()
			.any!(item => item is search_item);
	}

	typeof(this) clear() pure nothrow @safe
	{
		this.item_list = [];
		return this;
	}

	Type query(Type)() pure nothrow @safe
	{
		return item_list.filter!(item => item.has!(Type))
			.map!(item => item.get!(Type)())
			.array()[0];
	}

	Type[] query_all(Type)() pure nothrow @safe
	{
		return item_list.filter!(item => item.has!(Type))
			.map!(item => item.get!(Type)())
			.array();
	}

	bool query(Type)(out Type query_buffer) pure nothrow @safe
	if (isArray!Type == false)
	{
		if (!this.have!(Type))
		{
			return false;
		}
		query_buffer = this.item_list
			.filter!(item => item.has!(Type))
			.map!(item => item.get!(Type)())
			.array()[0];
		return true;
	}

	bool query(Type)(out Type[] query_buffer) pure nothrow @safe
	{
		if (!this.have!(Type))
		{
			return false;
		}
		query_buffer = item_list
			.filter!(item => item.has!(Type))
			.map!(item => item.get!(Type)())
			.array();
		return true;
	}

	typeof(this) query(TypeList...)(out TypeList query_list) pure nothrow @safe
	{
		foreach (count, Type; TypeList)
		{
			this.query(query_list[count]);
		}
		return this;
	}

	typeof(this) append(TypeList[] append_list...)
	{
		foreach (count, append_item; append_list)
		{
			this.item_list ~= cast(TypeList) append_item;
		}
		return this;
	}

	typeof(this) remove(TypeList remove_item)
	{
		this.item_list = this.item_list.filter!(item => item != remove_item).array();
		return this;
	}
}

unittest
{
	import std.format;

	struct S1
	{
	}

	struct S2
	{
	}

	struct S3
	{
	}

	alias S = SumType!(S1, S2, S3);

	S s1 = S1();
	S s2 = S2();
	assert(s1.has!(S1) == true);

	VariantPool!(S) pool;

	assert(pool.count == 0);
	pool.append(s1, s2);
	assert(pool.count == 2, format("count: %s", pool.count));
	assert(pool.have!(S1) == true);
	assert(pool.have!(S2) == true);
	assert(pool.have!(S3) == false);

	S1[] buf_s1;
	S2[] buf_s2;
	S3[] buf_s3;
	pool.query(buf_s1, buf_s2, buf_s3);
	assert(buf_s1.length == 1);
	assert(buf_s2.length == 1);
	assert(buf_s3.length == 0);

}
