module dulse.core.container.ct_list;

import std.meta;

struct CtList(TypeList...)
{
	alias list = AliasSeq!(TypeList);

	enum count = TypeList.length;

	enum size_t size = size_of();

	alias reverse = Reverse!TypeList;

	template sort(alias Compare = Comp2)
	{
		alias sort = staticSort!(Compare, TypeList);
	}

protected:
	static size_t size_of() pure nothrow @nogc @safe
	{
		scope size_t _size = 0;
		static foreach (Type; TypeList)
		{
			_size += Type.sizeof;
		}
		return _size;
	}
}

enum Comp2(T1, T2) = cast(int)(T1.sizeof - T2.sizeof);

unittest
{
	static assert(CtList!(int, float, short).count == 3);
	static assert(CtList!(int, float, short).size == 10);
	static assert(is(CtList!(int, float).reverse == AliasSeq!(float, int)));
	static assert(is(CtList!(int, byte, short).sort!() == AliasSeq!(byte, short, int,)));
}
