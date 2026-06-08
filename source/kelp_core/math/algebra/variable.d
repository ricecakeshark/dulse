module kelp_core.math.algebra.variable;

import std.math;

struct Variable
{
	string variable;

	Type apply(Type)(Type[string] argument)
	{
		if (variable !in argument)
		{
			return NaN(0);
		}
		return argument[variable];
	}
}
