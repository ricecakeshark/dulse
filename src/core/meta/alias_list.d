module dulse.core.meta.alias_list;

import dulse.core.meta;
import std.meta;
import std.traits;

deprecated alias TypeList = AliasList;

struct AliasList(Sequence...)
{
	alias list = AliasSeq!(Sequence);
	alias seq = AliasSeq!(Sequence);
	enum Type[] array(Type) = [AliasSeq!(Sequence)];

	enum size_t count = Sequence.length;
	// is_type (int, float, struct S)
	enum bool is_type = allSatisfy!(isType, Sequence);
	// is_enumerative (equally not type, 42, S(1)...)
	enum bool is_enum = allSatisfy!(templateNot!isType, Sequence);
	// have plan to split type or enum
	enum bool is_sorted = staticIsSorted!(Comp_size, Sequence);
	// size is defined only if it only is type or enumurative
	enum bool has_size = allSatisfy!(_has_size, Sequence);

	enum size_t size = size_of();

	// append, filter
	alias append(Type) = AliasList!(Sequence, Type);
	alias clear = AliasList!(AliasSeq!());
	alias filter(alias Pred) = AliasList!(Filter!(Pred, Sequence));
	alias filter(Type) = AliasList!(Filter!(isType!Type, Sequence));
	alias remove(Type) = AliasList!(Erase!(Type, Sequence));
	alias remove_all(Type) = AliasList!(EraseAll!(Type, Sequence));
	alias uniq = AliasList!(NoDuplicates!Sequence);

	// search
	alias all(alias F) = allSatisfy!(F, Sequence);
	alias any(alias F) = anySatisfy!(F, Sequence);
	alias index_of(Type) = staticIndexOf!(Type, Sequence);

	// search 
	enum bool all_same = allSatisfy!(allSameType, staticMap!(type_of,Sequence));
	enum bool contain(Type) = staticIndexOf!(Type, Sequence) != -1;
	enum bool contain_all(List...) = allSatisfy!(contain, staticMap!(type_of, List));
	enum bool contain_any(List...) = anySatisfy!(contain, staticMap!(type_of, List));

	// transform
	alias repeat(size_t n) = AliasList!(Repeat!(n, Sequence));
	alias replace(T, U) = AliasList!(ReplaceAll!(T, U, Sequence));
	alias reverse = AliasList!(Reverse!Sequence);
	alias map(alias fun) = AliasList!(staticMap!(fun, Sequence));
	alias sort(alias Compare = Comp_size) = AliasList!(staticSort!(Compare, Sequence));

	size_t opDollar() const pure nothrow @nogc @safe
	{
		return Sequence.length;
	}

protected:

	static size_t size_of() pure nothrow @nogc @safe
	{
		scope size_t _size = 0;
		static foreach (Type; Sequence)
		{
			_size += _size_of!Type;
		}
		return _size;
	}

}

enum Comp_size(alias T1, alias T2) = cast(int)(T1.sizeof - T2.sizeof);

template _has_size(alias some)
{
	enum bool _has_size = __traits(compiles, some.sizeof);
}

template _size_of(alias Any)
{
	static if (__traits(compiles, Any.sizeof))
	{
		enum size_t _size_of = Any.sizeof;
	}
	else static if (__traits(compiles, typeof(Any).sizeof))
	{
		enum size_t _size_of = typeof(Any).sizeof;
	}
	else
	{
		static assert(false, "cannot accept template params.");
	}
}

unittest
{
	{
		alias AL_1 = AliasList!(int, 42);
		alias AL_2 = AliasList!(int, float);
		alias AL_3 = AliasList!(411, 12, 42);

		static assert(!AL_1.is_type && !AL_1.is_enum);
		static assert(AL_2.is_type && !AL_2.is_enum);
		static assert(!AL_3.is_type && AL_3.is_enum);
		static assert(__traits(compiles, AL_1.size));
		static assert(__traits(compiles, AL_2.size));
		static assert(__traits(compiles, AL_3.size));
		static assert(__traits(compiles, AL_3.array!int));
		//AL_3.array!int;
	}

	{
		alias TL_1 = AliasList!(int, byte, short,);
		alias TL_2 = AliasList!(byte, short, int,);
		TL_1 typelist_1;

		static assert(is(TL_1.seq == AliasSeq!(int, byte, short)));
		static assert(is(TL_1 == TL_1));
		static assert(!is(TL_1 == TL_2));
		static assert(TL_1.is_type == true);
		// property
		static assert(TL_1.is_sorted == false && TL_2.is_sorted == true);
		static assert(typelist_1.count == 3);
		static assert(typelist_1.size == 7);
		// filter
		static assert(is(AliasList!(int).append!byte == AliasList!(int, byte)));
		static assert(is(TL_1.clear.seq == AliasSeq!()));
		static assert(TL_1.filter!isIntegral.count == 3);
		static assert(TL_1.filter!isFloatingPoint.count == 0);
		static assert(is(TL_1.remove!byte == AliasList!(int, short)));
		static assert(is(AliasList!(int, int, float, float).uniq == AliasList!(int, float)));
		// search
		static assert(TL_1.all!isBasicType && TL_2.all!isBasicType);
		static assert(TL_1.index_of!int == 0 && TL_2.index_of!int == 2);
		static assert(TL_1.contain!float == false);
		static assert(TL_1.contain_all!(TL_2.seq) && TL_2.contain_all!(TL_1.seq));
		static assert(!TL_1.contain_all!(AliasSeq!(int, float)));
		// transform
		static assert(is(AliasList!(int, float).repeat!2 == AliasList!(int, float, int, float)));
		static assert(is(AliasList!(int, float).replace!(float, real) == AliasList!(int, real)));
		static assert(is(TL_1.reverse.seq == AliasSeq!(short, byte, int)));
		//alias ToArray(Type) = Type[];
		static assert(is(TL_1.map!to_array.seq == AliasSeq!(int[], byte[], short[])));
		static assert(is(TL_1.sort!() == TL_2.sort!()));
	}

}
