module kelp_core.logger.logger;

import kelp_core.logger;
import std.datetime;
import std.format : format;
import std.stdio;

struct Logger
{
	typeof(this) log(
		string log_text,
		string file = __FILE__,
		size_t line = __LINE__,
		string func = __FUNCTION__,
		string mod = __MODULE__,
	)
	{
		DateTime now = cast(DateTime) Clock.currTime();
		format!("%s %s %s(%d) %s %s")(log_text, mod, file, line, func, now.toISOExtString)
			.writeln();
		return this;
	}
}
