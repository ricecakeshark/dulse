module dulse.core.meta.type;

import std.meta;
import std.traits : isType;

template contain_type(Type, TypeList...)
{
	enum bool contain_type = staticIndexOf!(Type, TypeList) != -1;
}

template filter_by_type(Type, list...)
{
	alias filter_by_type = Filter!(ApplyRight!(type_is, Type), list);
}

alias to_array(Type) = Type[];

template type_contained(alias lhs, Rhs...)
{
	enum bool type_contained = anySatisfy!(
			ApplyRight!(type_is, type_of!lhs), Rhs,
		);
}

template type_of(alias some)
{
	static if (isType!some)
	{
		alias type_of = some;
	}
	else static if (__traits(compiles, typeof(some)))
	{
		alias type_of = typeof(some);
	}
	else
	{
		static assert(false, "it is not a type or  have type");
	}
}

template type_is(alias lhs, alias rhs)
{
	enum bool type_is = _type_is!(lhs, rhs);
}

static bool _type_is(alias lhs, alias rhs)()
{
	static if (is(type_of!lhs == type_of!rhs))
	{
		return true;
	}
	return false;
}

template type_is_not(alias lhs, alias rhs)
{
	enum bool type_is_not = !is(type_of!lhs == type_of!rhs);
}

unittest
{
	static assert(is(type_of!1.0f == float));
	static assert(!is(type_of!1.0f == type_of!3.14L));
	static assert(is(type_of!int == int));

	static assert(type_is!(int, int));
	static assert(!type_is!(int, float));
	static assert(!type_is!(int, int[]));
	static assert(type_is!(411, int));
	static assert(type_is!(12, 42));

	static assert(contain_type!(float, int, long, float, double));
	static assert(!contain_type!(bool, int, long, float, double));
	static assert(filter_by_type!(float, 1u, 2, 3.0f, 4.0) == AliasSeq!(3.0f));
}
