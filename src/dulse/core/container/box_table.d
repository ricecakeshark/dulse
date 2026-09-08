module dulse.core.container.box_table;

import std.array : array;
import std.algorithm : any, canFind, count, filter, joiner, map, std_remove = remove, sum, SwapStrategy;

struct BoxTable
{
	IBox[][TypeInfo] box_table;

	size_t count() const pure nothrow @nogc @safe
	{
		return box_table.byValue
			.joiner()
			.count();
	}

	size_t count(Type)() const pure nothrow @nogc @safe
	{
		auto ref list = (typeid(Type) in this.box_table);
		if (list is null)
		{
			return 0;
		}
		return (*list).count();
	}

	size_t count(Type)(Type target) const pure nothrow @nogc @safe
	{
		auto ref list = (typeid(Type) in this.box_table);
		if (list is null)
		{
			return 0;
		}
		return (*list)
			.count!(elem => (cast(const(Box!Type)) elem).get == target);
	}

	bool has(Type)() const pure nothrow @nogc @safe
	{
		return (typeid(Type) in this.box_table) !is null;
	}

	bool has(Type)(Type element) const pure nothrow @nogc @safe
	in (is(Type))
	{
		auto ref list = typeid(Type) in this.box_table;
		return (list) !is null ?
			(*list)
			.canFind!(elem => (cast(const(Box!Type)) elem).get is element) : false;
	}

	typeof(this) append(TypeList...)() pure nothrow @safe
	{
		foreach (Type; TypeList)
		{
			this.box_table[typeid(Type)] = [];
		}
		return this;
	}

	typeof(this) append(TypeList...)(TypeList element_list) pure nothrow @safe
	{
		foreach (element; element_list)
		{
			this.append(element);
		}
		return this;
	}

	typeof(this) append(Type)(Type element) pure nothrow @safe
	{
		this.box_table[typeid(Type)] ~= new Box!Type(element);
		return this;
	}

	typeof(this) remove(TypeList...)() pure nothrow @safe
	{
		foreach (Type; TypeList)
		{
			this.box_table.remove(typeid(Type));
		}
		return this;
	}

	typeof(this) remove(TypeList...)(TypeList element_list) pure nothrow @safe
	{
		foreach (element; element_list)
		{
			this.remove(element);
		}
		return this;
	}

	typeof(this) remove(Type)(Type element) pure nothrow @safe
	{
		auto ref list = *(typeid(Type) in this.box_table);
		list = list
			.std_remove!(
				elem => (cast(Box!Type) elem).get is element,
				SwapStrategy.unstable,
			);
		return this;
	}

	typeof(this) query(alias pred)(out IBox[] out_buf)
	{
		out_buf = this.box_table.byValue
			.joiner()
			.filter!(elem => pred(elem))
			.array();
		return this;
	}

	typeof(this) query(alias pred)(out IBox[] out_buf)
	{
		out_buf = this.box_table.byValue
			.joiner()
			.filter!(elem => pred(elem))
			.array();
		return this;
	}

	typeof(this) query(
		scope bool delegate(IBox) pred,
		out IBox[] out_buf
	)
	{
		out_buf = this.box_table.byValue
			.joiner()
			.filter!(pred)
			.array();
		return this;
	}

}

interface IBox
{
}

class Box(Type) : IBox
{
	Type boxed;

	this(Type boxing)
	{
		this.boxed = boxing;
		return;
	}

	ref inout(Type) get()() inout pure nothrow @nogc @safe
	{
		return this.boxed;
	}
}

unittest
{
	struct S
	{
		bool s = true;
	}

	struct T
	{
		bool t = true;
	}

	struct U
	{
		bool u = true;
	}

	BoxTable box_table;

	S s;
	T t;
	U u;

	assert(box_table.count == 0);
	assert(box_table.count!S == 0 && box_table.count!T == 0 && box_table.count!U == 0);
	assert(box_table.count(s) == 0 && box_table.count(t) == 0 && box_table.count(u) == 0);
	assert(!box_table.has!S && !box_table.has!T && !box_table.has!U);
	assert(!box_table.has(s) && !box_table.has(t) && !box_table.has(u));

	box_table.append(s, t, u);

	assert(box_table.count == 3);
	assert(box_table.count!S == 1 && box_table.count!T == 1 && box_table.count!U == 1);
	assert(box_table.count(s) == 1 && box_table.count(t) == 1 && box_table.count(u) == 1);
	assert(box_table.has!S && box_table.has!T && box_table.has!U);
	assert(box_table.has(s) && box_table.has(t) && box_table.has(u));

	box_table.remove(s, t);

	assert(box_table.count == 1);
	assert(!box_table.has(s) && !box_table.has(t) && box_table.has(u) == true);

}
