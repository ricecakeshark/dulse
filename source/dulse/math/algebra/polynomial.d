module dulse.math.algebra.polynomial;

import dulse.math.algebra;
import std.algorithm : sort;
import std.array : Appender, appender;

struct Polynomial(Type)
{
	Monomial!Type[] monomial_list;

	@property ref inout(Monomial!Type[]) monomial() inout pure nothrow @nogc @safe
	{
		return monomial_list;
	}

	ref inout(Monomial!Type) opIndex(in size_t index) inout pure nothrow @nogc @safe
	in
	{
		assert(index < this.monomial_list.length);
	}
	do
	{
		return this.monomial_list[index];
	}

	@property real degree() const pure nothrow @nogc @safe
	{
		scope real degree_max = real.min_normal;
		foreach (monomial; monomial_list)
		{
			if (degree_max < monomial.degree)
			{
				degree_max = monomial.degree;
			}
		}
		return degree_max;
	}

	ref typeof(this) normalize() pure @safe
	{
		monomial_list.sort!((a, b) => compare(a, b) > 0);
		foreach (mono; monomial_list)
		{
			mono.normalize();
		}
		return this;
	}

	Type apply(Type[string] applier) const pure nothrow @nogc @safe
	{
		scope Type sum = 0.0;
		foreach (monomial; monomial_list)
		{
			sum += monomial.apply(applier);
		}
		return sum;
	}

	string to_string()
	{
		scope Appender!string buffer;
		if (monomial_list.length <= 0)
		{
			return "";
		}
		buffer = appender!string(monomial_list[0].to_string);
		foreach (index; 1 .. monomial_list.length)
		{
			buffer ~= " + ";
			buffer ~= monomial_list[index].to_string;
		}
		return buffer[];
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
// helper
Polynomial!Type polynomial(Type)(Monomial!Type[] monomial_list...) pure nothrow @safe
{
	return Polynomial!Type(monomial_list.dup);
}

unittest
{
	Polynomial!real nomial;
	nomial = polynomial(
		monomial(3.3L, Power("x", 1.0L)),
		monomial(1.1L, Power("x", 3.0L)),
		monomial(2.2L, Power("x", 2.0L)),
	);
	nomial.normalize();
	assert(nomial[0] == monomial(1.1L, Power("x", 3.0L)));
	assert(nomial[1] == monomial(2.2L, Power("x", 2.0L)));
	assert(nomial[2] == monomial(3.3L, Power("x", 1.0L)));
}
