module kelp_core.core.structure.variant_pool;

import kelp_core.core.structure.pool;
import std.array;
import std.algorithm;
import std.sumtype;

class VariantPool(TypeList) : Pool!(VariantPool,TypeList)
{
	TypeList[] item_list;

	this()
	{
		return;
	}

	@property size_t count() const pure nothrow @nogc @safe
	{
		return this.item_list.length;
	}

	@property inout(TypeList[]) all() inout pure nothrow @nogc @safe
	{
		return this.item_list;
	}

	bool have(Type)() pure nothrow @nogc @safe
	{
		return this.item_list.any!(item=>item.has!(Type)())();
	}

	bool have(Type)(Type search_item) pure nothrow @nogc @safe
	{
		return this.item_list.filter!(item => item.has!(Type))()
			.map!(item => item.get!(Type)())()
			.any!(item => item is search_item);
	}

	typeof(this) clear() pure nothrow @safe
	{
		this.item_list = [];
		return this;
	}

	Type[] query(Type)() pure nothrow @safe
	{
		return item_list.filter!(item => item.has!(Type))
			.map!(item => item.get!(Type)())
			.array();
	}

	typeof(this) append(Type...)(Type append_list)
	{
		foreach(append_item;append_list)
		{
			this.item_list ~= cast(TypeList)append_item;
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

	struct S1{}
	struct S2{}
	struct S3{}
	alias S = SumType!(S1,S2,S3);

	S s1 = S1();
	S s2 = S2();
	assert(s1.has!(S1)==true);
	
	VariantPool!(S) pool = new VariantPool!(S)();

	assert(pool.count == 0);
	pool.append(s1,s2);
	assert(pool.count == 2,format("count: %s",pool.count));
	assert(pool.query!(S1)().length == 1);
	assert(pool.have!(S1) == true);
	assert(pool.have!(S2) == true);
	assert(pool.have!(S3) == false);
	//assert(typeof(pool.query!(S1)() is s1));
}
