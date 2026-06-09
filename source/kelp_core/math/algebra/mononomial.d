module kelp_core.math.algebra.monomial;

import kelp_core.math.algebra;
import std.math : cmp;
import std.array : Appender, appender;
import std.conv : to;

struct Monomial(Type)
{
	Power[] power_list;
	Type coefficient;

	this(Type coefficient, Power[] power_list...) pure nothrow @nogc @safe
	{
		this.coefficient = coefficient;
		this.power_list = power_list;
		return;
	}

	@property ref inout(Power[]) powers() inout pure nothrow @nogc @safe
	{
		return this.power_list;
	}

	@property real degree() const pure nothrow @nogc @safe
	{
		scope real degree_max = real.min_normal;
		foreach (power; power_list)
		{
			if (degree_max < power.degree)
			{
				degree_max = power.degree;
			}
		}
		return degree_max;
	}

	Type apply(Type[string] applier) const pure nothrow @nogc @safe
	{
		scope Type product;
		product = coefficient;
		foreach (power; power_list)
		{
			product = product * power.apply(applier);
		}
		return product;
	}

	string to_string() const pure @safe
	{
		Appender!string buffer;
		if (power_list.length <= 0)
		{
			return "0";
		}
		buffer = appender!string(coefficient.to!string());
		foreach (index; 0 .. power_list.length)
		{
			buffer ~= "*";
			buffer ~= power_list[index].to_string;
		}
		return buffer[];
	}
}
// helper
Monomial!Type monomial(Type)(Type coefficient, Power[] power_list...) pure nothrow @nogc @safe
{
	return Monomial!Type(coefficient, power_list);
}

int compare(Type)(Monomial!Type lhs, Monomial!Type rhs) pure nothrow @nogc @safe
{
	return (lhs.degree < rhs.degree) ? +1 : -1;
}

unittest
{
	Monomial!real mono;

	mono = monomial(2.0L, Power(Variable("x"), 2.0));

	assert(mono.apply(["x": 2.0L]) == 8.0);
	assert(mono.apply(["x": 3.0L]) == 18.0);
}
