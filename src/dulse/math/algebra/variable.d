module dulse.math.algebra.variable;

import std.math : NaN;

struct Variable
{
	string variable;

	ref inout(string) name() return inout pure nothrow @nogc @safe
	{
		return this.variable;
	}

	string to_string() const pure nothrow @nogc @safe
	{
		return this.variable;
	}

	Type apply(Type)(Type[string] argument) const pure nothrow @nogc @safe
	{
		if (variable !in argument)
		{
			return NaN(0);
		}
		return argument[variable];
	}
}
