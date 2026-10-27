module dulse.core.meta.type;

import std.meta;

template contain_type(Type, TypeList...)
{
	enum bool contain_type = staticIndexOf!(Type, TypeList) != -1;
}

template filter_by_type(Type, list...)
{
	alias filter_by_type = Filter!(ApplyRight!(type_is, Type), list);
}

alias to_array(Type) = Type[];

template type_is(alias symbol, Type)
{
	enum bool type_is = is(typeof(symbol) == Type);
}

template type_is(alias symbol, TypeSeq...)
{
	enum bool type_is = _type_is!(symbol, TypeSeq);
}

static bool _type_is(alias symbol, TypeSeq...)()
{
	static foreach (Type; TypeSeq)
	{
		static if (is(symbol == Type))
		{
			return true;
		}
	}
	return false;
}

template type_is_not(alias symbol, Type)
{
	enum bool type_is_not = !is(typeof(symbol) == Type);
}

unittest
{
	static assert(filter_by_type!(float, 1u, 2, 3.0f, 4.0L) == AliasSeq!(3.0f));
	static assert(type_is!(bool, bool, int));
	static assert(!type_is!(bool, int, float));
}
