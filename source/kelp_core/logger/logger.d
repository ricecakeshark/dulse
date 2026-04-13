module kelp_core.logger.logger;

import kelp_core.core;
import kelp_core.logger;
import kelp_core.console;
import std.datetime;
import std.format : format;
import std.stdio;
import std.conv : text;

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
		string file = __FILE__,
		size_t line = __LINE__,
		string func = __FUNCTION__,
		string mod = __MODULE__,
	)
	{
		DateTime now = cast(DateTime) Clock.currTime();
		string level_label;
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

		format("[%s] %s", level_label, log_text).writeln();
		Text(format!"%4s : "("time"))
			.color(color_header, color_body)[].write();
		Text(now.toISOExtString.text())
			.color(color_header, color_body)[].writeln();
		Text(format!"%4s : "("file"))
			.color(color_header, color_body)[].write();
		stdout.flush();
		Text(format!"%s(%d)"(file, line,))
			.color(color_header, color_body)[].writeln();
		/+
		Text(format!"%4s : "("mod"), color_header, ColorU(0, 0, 0))[].write();
		Text(format!"%s"(mod,), color_body, ColorU(0, 0, 0))[].writeln();
		Text(format!"%4s : "("fn"), color_header, ColorU(0, 0, 0))[].write();
		Text(format!"%s"(func,), color_body, ColorU(0, 0, 0))[].writeln();
		+/
		return this;
	}
}

string text_colored_label(LogLevel level)
{
	string label_buf;
	switch (level)
	{
	case LogLevel.info:
		return TextWriter(label_buf)
			.seq(SGRCode.fg_green, SGRCode.bg_default)
			.text("info")
			.reset_color()[];
	case LogLevel.warning:
		return TextWriter(label_buf)
			.seq(SGRCode.fg_red, SGRCode.bg_default)
			.text("warn")
			.reset_color()[];
	case LogLevel.error:
		return TextWriter(label_buf)
			.seq(SGRCode.fg_red, SGRCode.bg_white)
			.text("error")
			.reset_color()[];
	default:
		assert(false);
	}
}
