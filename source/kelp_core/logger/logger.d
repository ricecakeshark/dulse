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
	LogLevel.error: "success",
];

SGRCode color_header = SGRCode.fg_black_bright;
SGRCode color_body = SGRCode.bg_default;

struct Logger
{
	typeof(this) log(
		string log_text,
		LogLevel log_level = LogLevel.info,
		LogFlags log_flags = LogFlags.time,
		LogState state = LogState.here,
	)
	{
		// text
		format("[%s] %s", colored_label(log_level), log_text).writeln();
		// time
		if (log_flags & LogFlags.time)
		{
			Text()
				.seq(color_header, color_body)
				.text(format!"%4s : "("time"))[]
				.write();
			Text()
				.seq(color_header, color_body)
				.text(Clock.currTime().toISOExtString)[]
				.writeln();
		}

		// file
		if (log_flags & LogFlags.file)
		{
			Text()
				.seq(color_header, color_body)
				.text(format!"%4s : "("file"))[]
				.write();
			Text()
				.seq(color_header, color_body)
				.text(format!"%s(%d)"(state.file, state.line,))[]
				.writeln();
		}

		// func
		if (log_flags & LogFlags.func)
		{
			Text()
				.seq(color_header, color_body)
				.text(format!"%4s : "("func"))[]
				.write();
			Text()
				.seq(color_header, color_body)
				.text(format!"%s(%d)"(state.func, state.line,))[]
				.writeln();
		}
		// module
		if (log_flags & LogFlags.mod)
		{
			Text()
				.seq(color_header, color_body)
				.text(format!"%4s : "("mod"))[]
				.write();
			Text()
				.seq(color_header, color_body)
				.text(format!"%s(%d)"(state.mod, state.line,))[]
				.writeln();
		}
		Text("").reset[].write();
		return this;
	}
}

string colored_label(in LogLevel log_level)
{
	final switch (log_level)
	{
	case LogLevel.error:
		return Text("")
			.seq(SGRCode.fg_red, SGRCode.bg_default)
			.text("error")
			.seq(SGRCode.reset)[];
	case LogLevel.warning:
		return Text("")
			.seq(SGRCode.fg_yellow)
			.text("warn")
			.seq(SGRCode.fg_default)[];
	case LogLevel.success:
		return Text("")
			.seq(SGRCode.fg_green)
			.text("success")
			.seq(SGRCode.fg_default)[];
	case LogLevel.info:
		return Text("")
			.seq(SGRCode.fg_cyan)
			.text("info")
			.seq(SGRCode.reset)[];
	case LogLevel.none:
		return Text("")
			.seq(SGRCode.fg_white)
			.text("log")
			.seq(SGRCode.fg_default)[];
	}
	assert(false, "unexpect log flag");
}
