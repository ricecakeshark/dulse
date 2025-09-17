module kelp_core.data.color;

import std.numeric;

alias Float16 = CustomFloat!(10,5,CustomFloatFlags.ieee);

struct Color
{
	Float16 r;
	Float16 g;
	Float16 b;
	Float16 a;
}
