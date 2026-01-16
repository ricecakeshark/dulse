module kelp_core.graphics.resource.vertex;

import kelp_core.core.data.color;
import kelp_core.math.linalg.vector;

struct Vertex(Pos, Col)
{
	Pos position;
	Col color;
}

unittest
{
	Vertex!(Vector!(3), ColorF) vertex;
	assert(__traits(isPOD, typeof(vertex)));
}
