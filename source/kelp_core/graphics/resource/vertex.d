module kelp_core.graphics.resource.vertex;

import kelp_core.core.data.color;
import kelp_core.math.linalg.vector;

struct Vertex(Pos, Col)
{
	Pos position;
	Col color;
}

struct VertexPC
{
	Vec3 pos;
	ColorU color;
}

struct VertexPT
{
	Vec3 pos;
	Vec2 uv;
}

struct VertexPCT
{
	Vec3 pos;
	ColorF color;
	Vec2 uv;
}

unittest
{
	Vertex!(Vector!(3), ColorF) vertex;
	assert(__traits(isPOD, typeof(vertex)));
}
