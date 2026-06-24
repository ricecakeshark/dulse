module source.kelp_core.math.algebra.expression;

import kelp_core.math.algebra;
import std.regex;
import std.stdio;
import std.sumtype;

auto number_regex = ctRegex!(`^[0-9]+\.([0-9]+)?`);

alias Expression = SumType!(Constant, Variable, Add, Mul, Pow);
alias Atom = SumType!(Constant, Variable);

struct Add
{
	Atom[] number_list;
}

struct Mul
{
	Atom[] number_list;
}

struct Pow
{
	Atom[] number_list;
}

struct Constant
{
	real value;
}

struct Variable
{
	string variable;
}

Polynomial!real expression(string expr)
{
	Polynomial!real poly;
	string[] str;

	foreach (count; 0 .. 100)
	{
		auto result = expr.match(number_regex);
		if (result.hit)
		{
			str ~= result.hit;
		}
	}
	return poly;
}
/+
unittest
{
	string expr = "1.1+2.2+3.3";
	string[] expr_list;
	string temp_expr;
	temp_expr = expr;

	foreach (count; 0 .. 100)
	{
		if (expr == "")
		{
			break;
		}
		auto result = temp_expr.matchFirst(number_regex);
		if (result.empty)
		{
			assert(false,"not match");
		}
		if (!result.empty)
		{
			expr_list ~= result.hit;
			temp_expr = result.post;
				writeln(temp_expr);
	writeln(expr_list);
		}
	}

	writeln(temp_expr);
	writeln(expr_list);
}
+/
