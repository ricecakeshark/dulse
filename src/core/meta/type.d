module dulse.core.meta.type;

import std.meta;
import std.traits : isType;

template contain_type(Type, TypeList...)
{
	enum bool contain_type = staticIndexOf!(Type, TypeList) != -1;
}

template filter_by_type(Type, list...)
{
	alias filter_by_type = Filter!(ApplyRight!(same_type, Type), list);
}

alias to_array(Type) = Type[];
//enum Type[] to_array(Type, Sequence...) = [Sequence];

template type_contained(alias lhs, Rhs...)
{
	enum bool type_contained = anySatisfy!(
			ApplyRight!(same_type, type_of!lhs), Rhs,
		);
}

Type[] array_of(Type,alias alias_list)() pure nothrow
{
	return [alias_list.seq];
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

template same_type(alias lhs, alias rhs)
{
	enum bool same_type = _same_type!(lhs, rhs);
}

static bool _same_type(alias lhs, alias rhs)()
{
	static if (is(type_of!lhs == type_of!rhs))
	{
		return true;
	}
	return false;
}

template not_same_type(alias lhs, alias rhs)
{
	enum bool not_same_type = !is(type_of!lhs == type_of!rhs);
}

unittest
{
	struct S
	{
		int a;
	}

	struct T
	{
		int a;
	}

	static assert(is(type_of!1.0f == float));
	static assert(!is(type_of!1.0f == type_of!3.14L));
	static assert(is(type_of!int == int));

	static assert(same_type!(int, int));
	static assert(!same_type!(int, float));
	static assert(!same_type!(int, int[]));
	static assert(same_type!(411, int));
	static assert(same_type!(12, 42));

	static assert(contain_type!(float, int, long, float, double));
	static assert(!contain_type!(bool, int, long, float, double));
	static assert(filter_by_type!(float, 1u, 2, 3.0f, 4.0) == AliasSeq!(3.0f));
	static assert(filter_by_type!(S, S(1), T(2), S(3), T(4)) == AliasSeq!(S(1), S(3)));

	static assert(
		is(Filter!(ApplyRight!(contain_type, int, uint), byte, ubyte, short, ushort, int, uint) == AliasSeq!(int, uint))
	);
}
