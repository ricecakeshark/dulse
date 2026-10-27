module dulse.core.meta.type_list;

import dulse.core.meta;
import std.meta;

struct TypeList(TypeSeq...)
{
	alias list = AliasSeq!(TypeSeq);
	alias seq = AliasSeq!(TypeSeq);

	enum is_sorted = staticIsSorted!(Comp2, TypeSeq);
	enum count = TypeSeq.length;
	enum size_t size = size_of();

	// append, filter
	alias append(Type) = TypeList!(TypeSeq, Type);
	alias clear = TypeList!(AliasSeq!());
	alias filter(alias Pred) = TypeList!(Filter!(Pred, TypeSeq));
	alias remove(Type) = TypeList!(Erase!(Type, TypeSeq));
	alias remove_all(Type) = TypeList!(EraseAll!(Type, TypeSeq));
	alias uniq = TypeList!(NoDuplicates!TypeSeq);

	// search
	alias all(alias F) = allSatisfy!(F, TypeSeq);
	alias any(alias F) = anySatisfy!(F, TypeSeq);
	alias index_of(Type) = staticIndexOf!(Type, TypeSeq);

	// transform
	alias repeat(size_t n) = TypeList!(Repeat!(n, TypeSeq));
	alias replace(T, U) = TypeList!(ReplaceAll!(T, U, TypeSeq));
	alias reverse = TypeList!(Reverse!TypeSeq);
	alias map(alias fun) = TypeList!(staticMap!(fun, TypeSeq));
	alias sort(alias Compare = Comp2) = TypeList!(staticSort!(Compare, TypeSeq));

	// operator
	bool opEquals(RhsList : TypeList!(RhsTypeSeq), RhsTypeSeq...)(in RhsList rhs) const pure nothrow @nogc @safe
	{
		return is(TypeSeq == RhsList.seq);
	}

	size_t opDollar() const pure nothrow @nogc @safe
	{
		return TypeSeq.length;
	}

protected:
	static size_t size_of() pure nothrow @nogc @safe
	{
		scope size_t _size = 0;
		static foreach (Type; TypeSeq)
		{
			_size += Type.sizeof;
		}
		return _size;
	}

	size_t toHash() const nothrow @safe
	{
		return hashOf(typeid(TypeSeq));
	}
}

enum Comp2(T1, T2) = cast(int)(T1.sizeof - T2.sizeof);

unittest
{
	import std.traits;

	alias TL_1 = TypeList!(int, byte, short,);
	alias TL_2 = TypeList!(byte, short, int,);
	TL_1 typelist_1;

	static assert(is(TL_1.seq == AliasSeq!(int, byte, short)));
	static assert(!is(TL_1 == TL_2));
	// property
	static assert(TL_1.is_sorted == false && TL_2.is_sorted == true);
	static assert(typelist_1.count == 3);
	static assert(typelist_1.size == 7);
	// filter
	static assert(is(TypeList!(int).append!byte == TypeList!(int, byte)));
	static assert(is(TL_1.clear.seq == AliasSeq!()));
	static assert(TL_1.filter!isIntegral.count == 3);
	static assert(TL_1.filter!isFloatingPoint.count == 0);
	static assert(is(TL_1.remove!byte == TypeList!(int, short)));
	static assert(is(TypeList!(int,int,float,float).uniq == TypeList!(int,float)));
	// search
	static assert(TL_1.all!isBasicType && TL_2.all!isBasicType);
	static assert(TL_1.index_of!int == 0 && TL_2.index_of!int == 2);
	// transform
	static assert(is(TypeList!(int, float).repeat!2 == TypeList!(int, float, int, float)));
	static assert(is(TypeList!(int, float).replace!(float, real) == TypeList!(int, real)));
	static assert(is(TL_1.reverse.seq == AliasSeq!(short, byte, int)));
	//alias ToArray(Type) = Type[];
	static assert(is(TL_1.map!to_array.seq == AliasSeq!(int[], byte[], short[])));
	static assert(is(TL_1.sort!() == TL_2.sort!()));

}
