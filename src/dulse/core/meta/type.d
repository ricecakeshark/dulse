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

template type_is_not(alias symbol, Type)
{
	enum bool type_is_not = !is(typeof(symbol) == Type);
}
