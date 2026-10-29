module dulse.math.algebra.power;

import dulse.math.algebra;
import std.math : pow;
import std.conv : to;

struct Power
{
	Variable _variable;
	real exponent = 1.0;

	this(Variable variable, real exponent) pure nothrow @nogc @safe
	{
		this._variable = variable;
		this.exponent = exponent;
		return;
	}

	this(string variable, real exponent) pure nothrow @nogc @safe
	{
		this._variable = Variable(variable);
		this.exponent = exponent;
		return;
	}

	@property ref inout(Variable) variable() return inout pure nothrow @nogc @safe
	{
		return this._variable;
	}

	@property ref inout(string) name() return inout pure nothrow @nogc @safe
	{
		return _variable.name;
	}

	@property ref inout(real) degree() return inout pure nothrow @nogc @safe
	{
		return this.exponent;
	}

	string to_string() const pure @safe
	{
		return this.variable.to_string ~ "^" ~ to!string(exponent);
	}

	real apply(Type)(Type[string] parameter) const pure nothrow @nogc @safe
	{
		return this._variable.apply!Type(parameter).pow(exponent);
	}
}

int compare(in Power lhs, in Power rhs) pure nothrow @nogc @safe
{
	if (lhs.name != rhs.name)
	{
		return (lhs.name < rhs.name) ? +1 : -1;
	}
	if (lhs.degree != rhs.degree)
	{
		return (lhs.degree < rhs.degree) ? +1 : -1;
	}
	return 0;
}
