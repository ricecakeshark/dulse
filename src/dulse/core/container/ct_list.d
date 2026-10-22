module dulse.core.container.ct_list;

import std.meta;

struct CtList(TypeList...)
{
	alias list = AliasSeq!(TypeList);

	alias reverse = Reverse!TypeList;

	template size()
	{
		enum size_t size = size_of();
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

	template sort(alias Compare = Comp2)
	{
		alias sort = staticSort!(Compare, TypeList);
	}
}

enum Comp2(T1, T2) = cast(int)(T1.sizeof - T2.sizeof);

unittest
{
	static assert(CtList!(int, float, short).size!() == 10);
	static assert(is(CtList!(int, float).reverse == AliasSeq!(float, int)));
	static assert(is(CtList!(int, byte, short).sort!() == AliasSeq!(byte, short, int,)));
}
