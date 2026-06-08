module kelp_core.math.algebra.power;

import kelp_core.math.algebra;
import std.math;

struct Power
{
	Variable variable;
	real exponent = 1.0;

	real apply(Type)(Type[string] parameter)
	{
		return variable.apply!Type(parameter).pow(exponent);
	}
}
