module dulse.core.container.pool;

interface Pool(This, TItem)
{
	@property size_t count() const pure nothrow @nogc @safe;
	@property inout(TItem[]) all() inout pure nothrow @nogc @safe;
	bool have(TItem)() const pure nothrow @nogc @safe;
	//bool have_any(const TItem[]) const pure nothrow @nogc @safe;
	//bool have_all(const TItem[]) const  pure nothrow @nogc @safe;
	This clear() pure nothrow @safe;
	This append(TItem...)(TItem) pure nothrow @safe;
	This remove(TItem...)(TItem) pure nothrow @safe;
}
