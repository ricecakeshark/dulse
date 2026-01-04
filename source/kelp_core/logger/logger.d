module kelp_core.logger.logger;

import kelp_core.core;
import kelp_core.logger;
import std.datetime;
import std.format : format;
import std.stdio;

string[LogLevel] log_label = [
	LogLevel.info: "info",
	LogLevel.warning: "warn",
	LogLevel.error: "error",
];


struct Logger
{
	typeof(this) log(
		string log_text,
		LogLevel log_level,
		string file = __FILE__,
		size_t line = __LINE__,
		string func = __FUNCTION__,
		string mod = __MODULE__,
	)
	{
		DateTime now = cast(DateTime) Clock.currTime();
		format!("%s [%-5s] %s mod:%s %s(%d) %s")(now.toISOExtString, colored_label(log_level), log_text, mod, file, line, func,)
			.writeln();
		return this;
	}
}

string colored_label(LogLevel level)
{
	switch(level)
	{
		case LogLevel.info:
			return AnsiText("info",ColorU(0x00,0xcc,0x00),ColorU(0x00,0x00,0x00)).output;
		case LogLevel.warning:
			return AnsiText("warn",ColorU(0xcc,0xcc,0x00),ColorU(0x00,0x00,0x00)).output;
		case LogLevel.error:
			return AnsiText("error",ColorU(0xcc,0x00,0x00),ColorU(0x00,0x00,0x00)).output;
		default:
			assert(false);
	}
}