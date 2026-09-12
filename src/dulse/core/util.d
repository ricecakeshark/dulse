module dulse.core.util;

import std.stdio : writeln;

bool check(in bool succeed, in string message) @safe
{
	if (!succeed)
	{
		writeln(message);
	}
	return succeed;
}
