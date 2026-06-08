module kelp_core.math.algebra.mononomial;

import kelp_core.math.algebra;

struct Mononomial(Type)
{
	Power[] power_list;
	Type coefficient;

	this(Type coefficient, Power[] power_list...)
	{
		this.coefficient = coefficient;
		this.power_list = power_list;
		return;
	}

	Type apply(Type[string] applier)
	{
		scope Type product;
		product = coefficient;
		foreach (power; power_list)
		{
			product = product * power.apply(applier);
		}
		return product;
	}
}

Mononomial!Type mononomial(Type)(Type coefficient, Power[] power_list...)
{
	return Mononomial!Type(coefficient, power_list);
}

unittest
{
	Mononomial!real mono;

	mono = mononomial(2.0L, Power(Variable("x"), 2.0));

	assert(mono.apply(["x": 2.0L]) == 8.0);
	assert(mono.apply(["x": 3.0L]) == 18.0);
}
