module kelp_core.core.container.type_table;

import std.array;
import std.algorithm;

import std.typecons : Tuple;
import std.meta;

alias ToArray(Type) = Type[];

struct TypeTable(TypeList...)
{
	alias ArrayTypeList = staticMap!(ToArray, TypeList);
	Tuple!(ArrayTypeList) table;

	@property size_t count()() pure nothrow @nogc @safe
	{
		scope size_t sum_length;
		foreach (list; this.table)
		{
			sum_length += list.length;
		}
		return sum_length;
	}

	@property size_t count(Type)() pure nothrow @nogc @safe
	{
		enum index = index_of!Type;
		if (index == -1)
		{
			return 0;
		}
		return this.table[index].count();
	}

	bool has() pure nothrow @nogc @safe
	{
		foreach (Type; TypeList)
		{
			if (this.table[index_of!Type].length >= 1)
			{
				return true;
			}
		}
		return false;
	}

	bool has(Type)() pure nothrow @nogc @safe
	{
		return (this.index_of!Type != -1) && (this.table[this.index_of!Type].count >= 1);
	}

	bool has(Type)(Type target) pure nothrow @nogc @safe
	{
		return this.table[this.index_of!Type].canFind(target);
	}

	ref typeof(this) append(Types...)(Types element_list) pure nothrow @safe
	{
		foreach (element; element_list)
		{
			this.append(element);
		}
		return this;
	}

	ref typeof(this) append(Type)(Type element) pure nothrow @safe
	{
		this.table[this.index_of!Type] ~= element;
		return this;
	}

	ref typeof(this) remove(Types...)(Types element_list) pure nothrow @safe
	{
		foreach (element; element_list)
		{
			this.remove(element);
		}
		return this;
	}

	ref typeof(this) remove(Type)(Type element) pure nothrow @safe
	{
		this.table[this.index_of!Type] =
			this.table[this.index_of!Type]
			.remove!(elem => elem == element, SwapStrategy.unstable);
		return this;
	}

	ref typeof(this) remove(TypeList...)() pure nothrow @safe
	{
		foreach (Type; TypeList)
		{
			this.remove!Type();
		}
		return this;
	}

	ref typeof(this) remove(Type)() pure nothrow @safe
	{
		this.table[this.index_of!Type] = [];
		return this;
	}

	Type[] query(Type)() pure nothrow @nogc @safe
	{
		return this.table[this.index_of!Type];
	}

	ref typeof(this) query(Type)(out Type[] out_list) pure nothrow @safe
	{
		out_list = this.table[this.index_of!Type];
		return this;
	}

	typeof(this) query(alias pred, Type)(out Type[] out_buf)
	{
		out_buf = this.table[index_of!Type]
			.filter!pred
			.array();
		return this;
	}

	typeof(this) query(Type, Pred)(out Type[] out_buf, scope Pred pred)
	{
		out_buf = this.table[index_of!Type]
			.filter!(elem => pred(elem))
			.array();
		return this;
	}

private:
	enum has_index(Type) = staticIndexOf!(Type, TypeList) != -1;
	enum index_of(Type) = staticIndexOf!(Type, TypeList);
}

unittest
{
	struct S1
	{
		int a;
	}

	struct S2
	{
		int a;
	}

	struct S3
	{
		int a;
	}

	TypeTable!(S1, S2, S3) table;

	assert(!table.has);
	assert(!table.has!S1 && !table.has!S2 && !table.has!S3);
	assert(table.count == 0);
	assert(table.count!S1 == 0 && table.count!S2 == 0 && table.count!S3 == 0);
	table.append(
		S1(1), S2(2), S2(3),
		S3(4), S3(5), S3(6),
	);
	assert(table.has);
	assert(table.has!S1 && table.has!S2 && table.has!S3);
	assert(table.count == 6);
	assert(table.count!S1 == 1 && table.count!S2 == 2 && table.count!S3 == 3);
	table.remove!S2();
	table.remove!S1();
	table.remove(S1());
	assert(!table.has!S1);
	assert(!table.has!S1 && !table.has!S2 && table.has!S3);
	assert(table.count == 3);
	assert(table.count!S1 == 0 && table.count!S2 == 0 && table.count!S3 == 3);

	S3[] s_list;
	// deprecated: require dual-context
	//table.query!(function(elem) => elem.a == 5)(s_list);
	table.query(s_list, (S3 elem) => elem.a == 5);
	assert(s_list.length == 1);
}
