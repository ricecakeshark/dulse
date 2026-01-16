module kelp_core.graphics.resource.geometry;

import kelp_core.graphics.resource;
import kelp_core.math.linalg.vector;

struct Geometry(Pos, Col)
{
	Vertex!(Pos, Col)[] vertex_list;
	Index[] index_list;

	inout(Vertex!(Pos, Col)[]) vertex() inout pure nothrow @nogc @safe
	{
		return this.vertex_list;
	}

	inout(Index[]) index() inout pure nothrow @nogc @safe
	{
		return this.index_list;
	}

	// typeof(this) load() 
}

unittest
{
	import kelp_core : Vector, ColorF;

	Geometry!(Vector!(3), ColorF) geometry;
	assert(__traits(isPOD, typeof(geometry)));
}
