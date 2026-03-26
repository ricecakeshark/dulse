module kelp_core.logger.logger;

import kelp_core.core;
import kelp_core.logger;
import kelp_core.console;
import std.datetime;
import std.format : format;
import std.stdio;

string[LogLevel] log_label = [
	LogLevel.info: "info",
	LogLevel.warning: "warn",
	LogLevel.error: "error",
];

ColorU color_header = ColorU(0xa0, 0xa0, 0xa0);
ColorU color_body = ColorU(0x80, 0x80, 0x80);

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
		format!("[%-5s] %s")(colored_label(log_level), log_text,).writeln();
		Text(format!"%4s : "("time"), color_header, ColorU(0, 0, 0))[].write();
		Text(format!"%s\n"(now.toISOExtString), color_body, ColorU(0, 0, 0))[].write();
		Text(format!"%4s : "("file"), color_header, ColorU(0, 0, 0))[].write();
		Text(format!"%s(%d)\n"(file, line,), color_body, ColorU(0, 0, 0))[].write();
		Text(format!"%4s : "("mod"), color_header, ColorU(0, 0, 0))[].write();
		Text(format!"%s\n"(mod,), color_body, ColorU(0, 0, 0))[].write();
		Text(format!"%4s : "("fn"), color_header, ColorU(0, 0, 0))[].write();
		Text(format!"%s\n"(func,), color_body, ColorU(0, 0, 0))[].write();
		return this;
	}
}

string colored_label(LogLevel level)
{
	string label_buf;
	switch (level)
	{
	case LogLevel.info:
		return TextWriter(label_buf).text_colored("info", ColorU(0x00, 0xcc, 0x00), ColorU(0x00, 0x00, 0x00))[];
	case LogLevel.warning:
		return TextWriter(label_buf).text_colored("warn", ColorU(0xcc, 0xcc, 0x00), ColorU(0x00, 0x00, 0x00))[];
	case LogLevel.error:
		return TextWriter(label_buf).text_colored("error", ColorU(0xcc, 0x00, 0x00), ColorU(0x00, 0x00, 0x00))[];
	default:
		assert(false);
	}
}
