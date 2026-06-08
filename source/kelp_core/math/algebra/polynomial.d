module kelp_core.math.algebra.polynomial;

import kelp_core.math.algebra;

struct Polynomial(Type)
{
	Mononomial!Type[] mononomial_list;

	Type apply(Type[string] applier)
	{
		scope Type sum;
		foreach (mononomial; mononomial_list)
		{
			sum += mononomial.apply(applier);
		}
		return sum;
	}

	/+
	void normalize()
	{
		// x^2*2 + x^2*3 = x^2*5
		// x^2*0 => 0
		// x^0*Y^2*2 => Y^2*2
		// sort
		return;
	}
	+/
}
