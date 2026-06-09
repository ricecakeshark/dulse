module kelp_core.math.algebra.monomial;

import kelp_core.math.algebra;
import std.math : cmp, isClose;
import std.array : Appender, appender;
import std.conv : to;

struct Monomial(Type)
{
	Power[] power_list;
	Type coefficient;

	this(Monomial!Type mono) pure nothrow @nogc @safe
	{
		this.coefficient = mono.coefficient;
		this.power_list = mono.power_list;
		return;
	}

	this(Type coefficient, Power[] power_list...) pure nothrow @nogc @safe
	{
		this.coefficient = coefficient;
		this.power_list = power_list;
		return;
	}

	@property ref inout(Power[]) powers() inout pure nothrow @nogc @safe
	in (power_list !is null)
	{
		return this.power_list;
	}

	@property ref inout(Power) index(in size_t index) inout pure nothrow @nogc @safe
	in (power_list !is null)
	in (index < this.power_list.length)
	{
		return this.power_list[index];
	}

	@property ref inout(Power) opIndex(in size_t index) inout pure nothrow @nogc @safe
	{
		return this.index(index);
	}

	@property ref inout(Power) index(in string variable) inout pure nothrow @nogc @safe
	in (power_list !is null)
	{
		foreach (ref power; this.power_list)
		{
			if (power.name == variable)
			{
				return power;
			}
		}
		assert(false);
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

	bool opEqauls(in Monomial!Type rhs)
	{
		return equal(this, rhs);
	}

	Monomial!Type integrate(string variable) pure nothrow @safe
	{
		scope Monomial!Type ret;
		ret.power_list = this.power_list.dup;
		ret.index(variable).exponent = this.index(variable).exponent + 1.0;
		ret.coefficient = this.coefficient / ret.index(variable).exponent;
		return ret;
	}

	Monomial!Type differentiate(string variable) pure nothrow @safe
	{
		scope Monomial!Type ret;
		if (this.index(variable).exponent.isClose(0.0))
		{
			return Monomial!Type(0.0);
		}
		ret.power_list = this.power_list.dup;
		ret.coefficient = this.coefficient * ret.index(variable).exponent;
		ret.index(variable).exponent = ret.index(variable).exponent - 1.0;
		return ret;
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

bool equal(Type)(in Monomial!Type lhs, in Monomial!Type rhs) pure nothrow @nogc @safe
{
	return (lhs.coefficient == rhs.coefficient) && (lhs.power_list == rhs.power_list);
}

int compare(Type)(in Monomial!Type lhs, in Monomial!Type rhs) pure nothrow @nogc @safe
{
	return (lhs.degree < rhs.degree) ? +1 : -1;
}

unittest
{
	Monomial!real mono;

	mono = monomial(3.0L, Power(Variable("x"), 2.0));

	assert(mono.apply(["x": 2.0L]) == 12.0);
	assert(mono.apply(["x": 3.0L]) == 27.0);

	import std.stdio;

	assert(mono.integrate("x") == Monomial!real(1.0, Power("x", 3.0)));
	assert(mono.differentiate("x") == Monomial!real(6.0, Power("x", 1.0)));

	writeln("f(x) = ", mono.to_string);
	writeln("f(x) dx = ", mono.integrate("x").to_string);
	writeln("f(x) d/dx = ", mono.differentiate("x").to_string);
}
