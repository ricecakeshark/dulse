module kelp_core.math.algebra.power;

import kelp_core.math.algebra;
import std.math : pow;
import std.conv : to;

struct Power
{
	Variable variable;
	real exponent = 1.0;

	@property double degree() const pure nothrow @nogc @safe
	{
		return exponent;
	}

	string to_string() const pure @safe
	{

		return this.variable.to_string ~ "^" ~ to!string(exponent);
	}

	real apply(Type)(Type[string] parameter) const pure nothrow @nogc @safe
	{
		return variable.apply!Type(parameter).pow(exponent);
	}
}
