module dulse.core.container.typed_table;

import std.array : array;
import std.algorithm : count, equal, filter, range_remove = remove, SwapStrategy;

import std.typecons : Tuple;
import std.meta : ApplyLeft, Filter, NoDuplicates, staticIndexOf, staticMap;

struct TypedTable(TypeList...)
{
	Tuple!(staticMap!(ToArray, TypeList)) table;

	this(Args...)(Args args) pure nothrow @safe
	{
		this.assign(args);
		return;
	}

	alias has_key(Type) = has_index!Type;

	bool has(Type)() pure nothrow @nogc @safe
	{
		return has_index!Type && (this.table[index_of!Type].count >= 1);
	}

	bool has(Type)(Type target) pure nothrow @nogc @safe
	{
		return this.table[this.index_of!Type].canFind(target);
	}

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
		if (!has_index!Type)
		{
			return 0;
		}
		return this.table[index_of!Type].count();
	}

	bool is_empty() pure nothrow @nogc @safe
	{
		foreach (Type; TypeList)
		{
			if (this.table[index_of!Type].length >= 1)
			{
				return false;
			}
		}
		return true;
	}

	bool opEquals(in typeof(this) rhs) const pure nothrow @nogc @safe
	{
		return this.table == rhs.table;
	}

	ref inout(Type[]) index(Type)() inout pure nothrow @nogc @safe
	in
	{
		static assert(has_index!Type);
	}
	do
	{
		return this.table[this.index_of!Type];
	}

	typeof(this) opBinary(string op : "+")(in typeof(this) rhs) const pure
	{
		return this.add(rhs);
	}

	ref typeof(this) clear() pure nothrow @nogc @safe
	{
		foreach (ref list; this.table)
		{
			list = list.init;
		}
		return this;
	}

	ref typeof(this) append(Types...)(Types element_list) pure nothrow @safe
	{
		this._append(element_list);
		return this;
	}

	ref typeof(this) remove(Types...)() pure nothrow @safe
	{
		foreach (Type; Types)
		{
			assert(this.has_index!Type);
			this.table[this.index_of!Type] = [];
		}
		return this;
	}

	ref typeof(this) remove(Types...)(Types element_list) pure nothrow @safe
	{
		foreach (Type; Types)
		{
			this.remove([Filter!(ApplyLeft!(type_is, Type), element_list)]);
		}
		return this;
	}

	ref typeof(this) remove(Type)(Type[] element_list) pure nothrow @safe
	{
		foreach (element; element_list)
		{
			this.table[this.index_of!Type] =
				this.table[this.index_of!Type]
				.range_remove!(elem => elem == element, SwapStrategy.unstable);
		}
		return this;
	}

	inout(Type)[] query(Type)() inout pure nothrow @nogc @safe
	{
		return this.table[this.index_of!Type];
	}

	ref typeof(this) query(Type)(out Type[] out_list) pure nothrow @safe
	{
		out_list = this.table[this.index_of!Type];
		return this;
	}

	ref typeof(this) query(alias pred, Type)(out Type[] out_buf)
	{
		out_buf = this.table[index_of!Type]
			.filter!pred
			.array();
		return this;
	}

	ref typeof(this) query(Type, Pred)(out Type[] out_buf, scope Pred pred)
	{
		out_buf = this.table[index_of!Type]
			.filter!(elem => pred(elem))
			.array();
		return this;
	}

	ref typeof(this) opOpAssign(string op : "~", Args...)(Args args)
	{
		this._append(args);
		return this;
	}

protected:
	typeof(this) add(in typeof(this) rhs) const pure nothrow @safe
	{
		scope TypedTable!(TypeList) new_table;
		foreach (Type; TypeList)
		{
			new_table.index!Type = this.index!Type.dup ~ rhs.index!Type.dup;
		}
		return new_table;
	}

	void assign(Args...)(Args args) pure nothrow @safe
	{
		foreach (Type; TypeList)
		{
			table[index_of!Type] = [Filter!(ApplyLeft!(type_is, Type), args)];
		}
		return;
	}

	void _append(Args...)(Args args) pure nothrow @safe
	{
		foreach (Type; TypeList)
		{
			table[index_of!Type] ~= [Filter!(ApplyLeft!(type_is, Type), args)];
		}
		return;
	}

	size_t toHash() const pure nothrow @nogc @safe
	{
		return hashOf(this.table);
	}

	alias ToArray(Type) = Type[];
	enum bool has_index(Type) = staticIndexOf!(Type, TypeList) != -1;
	enum int index_of(Type) = staticIndexOf!(Type, TypeList);
	template type_is(Type, alias a)
	{
		enum type_is = is(typeof(a) == Type);
	}

	template type_is_not(Type, alias a)
	{
		enum type_is_not = !is(typeof(a) == Type);
	}

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

	TypedTable!(S1, S2, S3) table_1, table_2, table_3;

	assert(table_1.is_empty);
	assert(!table_1.has!S1 && !table_1.has!S2 && !table_1.has!S3);
	assert(table_1.count == 0);
	assert(table_1.count!S1 == 0 && table_1.count!S2 == 0 && table_1.count!S3 == 0);
	table_1.append(
		S1(1), S2(2), S2(3),
	);
	table_2.append(
		S3(4), S3(5), S3(6),
	);
	assert(table_1 != table_2);
	with (table_1)
	{
		assert(count == 3 && !table_1.is_empty);
		assert(has!S1 && has!S2 && !has!S3);
	}
	with (table_2)
	{
		assert(count == 3 && !is_empty);
		assert(!has!S1 && !has!S2 && has!S3);
	}

	table_3 = table_1 + table_2;
	with (table_3)
	{
		assert(count!S1 == 1 && count!S2 == 2 && count!S3 == 3);
	}
	table_3.remove(S2(2), S2(3));
	table_3.remove!(S1, S3);
	with (table_3)
	{
		assert(!has!S1 && !has!S2 && !has!S3);
		assert(is_empty && count == 0);
		assert(count!S1 == 0 && count!S2 == 0 && count!S3 == 0);
	}

	S3[] s_list;
	// deprecated: require dual-context
	//table.query!(function(elem) => elem.a == 5)(s_list);
	(table_1 + table_2).query(s_list, (S3 elem) => elem.a == 5);
	assert(s_list.length == 1);

}

TypedTable!(NoDuplicates!(LhsTypes, RhsTypes)) join(LhsTypes, RhsTypes,)(
	in TypedTable!(LhsTypes) lhs, in TypedTable!(RhsTypes) rhs,
) pure nothrow @safe
{
	scope TypedTable!(NoDuplicates!(LhsTypes, RhsTypes)) result;
	foreach (Type; NoDuplicates!(LhsTypes, RhsTypes))
	{
		static if (lhs.has_key!Type)
		{
			result.index!Type ~= lhs.index!Type;
		}
		static if (rhs.has_key!Type)
		{
			result.index!Type ~= rhs.index!Type;
		}
	}
	return result;
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

	assert(
		join(
			TypedTable!(S1)(S1(1), S1(2)),
			TypedTable!(S2)(S2(3), S2(4))
	) == TypedTable!(S1,S2)(S1(1), S1(2), S2(3), S2(4))
	);

}
