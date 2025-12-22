module kelp_core.data.color;

import std.numeric;

//alias Float16 = CustomFloat!(10,5,CustomFloatFlags.ieee);

alias Color = ColorF;

struct ColorF
{
	float r;
	float g;
	float b;
	float a;

	this(float r, float g, float b, float a = 1.0f)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}
}

struct ColorU
{
	ubyte r;
	ubyte g;
	ubyte b;
	ubyte a;
}
