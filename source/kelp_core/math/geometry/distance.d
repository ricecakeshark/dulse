module kelp_core.math.geometry.distance;

import kelp_core.math;
import std.math;

Type distance(Type)(
	in Vector!(2, Type) lhs, in Vector!(2, Type) rhs
) pure nothrow @nogc @safe
in
{
	assert(!lhs.contain_nan);
	assert(!rhs.contain_nan);
}
do
{
	return ((lhs.x - rhs.x).pow(2)
			+ (lhs.y - rhs.y).pow(2)).sqrt();
}

Type distance(Type)(
	in Vector!(3, Type) lhs, in Vector!(3, Type) rhs
) pure nothrow @nogc @safe
in
{
	assert(!lhs.contain_nan);
	assert(!rhs.contain_nan);
}
do
{
	return ((lhs.x - rhs.x).pow(2)
			+ (lhs.y - rhs.y).pow(2)
			+ (lhs.z - rhs.z).pow(2)).sqrt();
}
