module kelp_core.logger.logger;

import kelp_core.core;
import kelp_core.logger;
import kelp_core.console;
import std.datetime;
import std.format : format;
import std.stdio;
import std.conv : text;
import std.typecons : BitFlags;

string[LogLevel] log_label = [
	LogLevel.info: "info",
	LogLevel.warning: "warn",
	LogLevel.error: "error",
];

SGRCode color_header = SGRCode.fg_black_bright;
SGRCode color_body = SGRCode.bg_default;

struct Logger
{
	typeof(this) log(
		string log_text,
		LogLevel log_level,
		LogFlags log_flags = LogFlags.time,
		string file = __FILE__,
		size_t line = __LINE__,
		string func = __FUNCTION__,
		string mod = __MODULE__,
	)
	{
		DateTime now = cast(DateTime) Clock.currTime();
		string level_label;
		level_label.write_colored_label(log_level);

		// text
		format("[%s] %s", level_label, log_text).writeln();
		// time
		if (log_flags & LogFlags.time)
		{
			Text(format!"%4s : "("time"))
				.color(color_header, color_body)[].write();
			Text(now.toISOExtString.text())
				.color(color_header, color_body)[].writeln();
		}
		// file
		if (log_flags & LogFlags.file)
		{
			Text(format!"%4s : "("file"))
				.color(color_header, color_body)[].write();
			Text(format!"%s(%d)"(file, line,))
				.color(color_header, color_body)[].writeln();
		}
		// func
		if (log_flags & LogFlags.func)
		{
			Text(format!"%4s : "("func"))
				.color(color_header, color_body)[].write();
			Text(format!"%s(%d)"(func, line,))
				.color(color_header, color_body)[].writeln();
		}
		// module
		if (log_flags & LogFlags.mod)
		{
			Text(format!"%4s : "("mod"))
				.color(color_header, color_body)[].write();
			Text(format!"%s(%d)"(mod, line,))
				.color(color_header, color_body)[].writeln();
		}
		return this;
	}
}

void write_colored_label(out string level_label, in LogLevel log_level) pure nothrow 
{
	switch (log_level)
	{
	case LogLevel.error:
		TextWriter(level_label)
			.seq(SGRCode.fg_red)
			.text("error")
			.seq(SGRCode.fg_default);
		break;
	case LogLevel.warning:
		TextWriter(level_label)
			.seq(SGRCode.fg_yellow)
			.text("warn")
			.seq(SGRCode.fg_default);
		break;
	case LogLevel.success:
		TextWriter(level_label)
			.seq(SGRCode.fg_green)
			.text("success")
			.seq(SGRCode.fg_default);
		break;
	case LogLevel.info:
		TextWriter(level_label)
			.seq(SGRCode.fg_cyan)
			.text("info")
			.seq(SGRCode.fg_default);
		break;
	default:
		break;
	}
	return;
}
