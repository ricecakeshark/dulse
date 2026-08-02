module kelp_core.core.container.interfaced_table;

import std.array : array;
import std.algorithm;
import std.exception;

struct InterfacedTable(I)
{
	I[][TypeInfo] element_table;

	size_t count() const pure nothrow @nogc @safe
	{
		return element_table.byValue
			.joiner()
			.count();
	}

	size_t count(Type)() const pure nothrow @nogc @safe
	{
		auto ref list = (typeid(Type) in element_table);
		if (list is null)
		{
			return 0;
		}
		return (*list).count();
	}

	size_t count(Type)(Type target) const pure nothrow @nogc @safe
	{
		auto ref list = (typeid(Type) in element_table);
		if (list is null)
		{
			return 0;
		}
		return (*list).count!(elem => elem is target);

	}
	/+
	// it work but maybe double searching
	size_t count(Type)(Type target) const pure @safe
	{
		return (typeid(Type) in element_table) !is null ?
			element_table[typeid(Type)]
			.count!(elem => elem is target) : 0;
	}
	+/

	bool has(Type)() const pure nothrow @nogc @safe
	{
		return (typeid(Type) in this.element_table) !is null;
	}

	bool has(Type)(Type element) const pure nothrow @nogc @safe
	{
		auto ref list = typeid(Type) in this.element_table;
		return (list) !is null ?
			(*list).any!(elem => elem is element) : false;
	}

	typeof(this) append(Type)(Type element) pure nothrow @safe
	in ((cast(I) element) !is null)
	{
		this.element_table[typeid(Type)] ~= element;
		return this;
	}

	typeof(this) remove(Type)(Type element)
	in ((cast(I) element) !is null)
	{
		auto ref list = (*enforce(typeid(Type) in this.element_table));
		list = std.algorithm.mutation.remove!(elem => elem is element)(list);
		return this;
	}

	typeof(this) query(alias pred)(out I[] out_buf)
	{
		out_buf = this.element_table.byValue
			.joiner()
			.filter!(elem => pred(elem))
			.array();
		return this;
	}

	typeof(this) query(
		scope bool delegate(I) pred,
		out I[] out_buf
	)
	{
		out_buf = this.element_table.byValue
			.joiner()
			.filter!(pred)
			.array();
		return this;
	}

}

unittest
{

	interface IC
	{
		@property int a();
	}

	class C(Derived) : IC
	{
		int _a;

		@property int a()
		{
			return _a;
		}
	}

	class C1 : C!(C1)
	{
		//int a = 1;
	}

	class C2 : C!(C2)
	{
		//int a = 2;
	}

	C1 c1 = new C1;
	C2 c2_1 = new C2;
	C2 c2_2 = new C2;

	InterfacedTable!IC table;
	assert(table.count == 0);
	assert(table.count!C1 == 0 && table.count!C2 == 0);
	assert(table.count(c1) == 0 && table.count(c2_1) == 0 && table.count(c2_2) == 0);
	assert(!table.has!C1 && !table.has!C2);
	assert(!table.has(c1) && !table.has(c2_1) && !table.has(c2_2));
	table.append(c1);
	table.append(c2_1);
	table.append(c2_2);

	assert(table.count == 3);
	assert(table.count!C1 == 1);
	assert(table.count(c1) == 1);
	assert(table.count!C2 == 2);
	assert(table.count(c2_1) == 1 && table.count(c2_2) == 1);
	assert(table.has!C1 && table.has!C2);
	assert(table.has(c1) && table.has(c2_1) && table.has(c2_2));
	table.remove(c1);
	assert(table.count == 2);
	assert(table.count!C1 == 0);
	//assert(!table.has!C1);
	assert(!table.has(c1));
	IC[] list;
	table.query((elem) => elem.a == 0, list);
	table.query!((IC elem) => elem.a == 0)(list);
	//table = InterfacedTable!IC();
}
