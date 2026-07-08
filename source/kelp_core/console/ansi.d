module kelp_core.console.ansi;

import kelp_core.core.data;
import std.algorithm : map;
import std.array : array, join;
import std.conv : to, text;
import std.array : RefAppender, Appender, appender;

import std.stdio;

enum EscapeSequence : string
{
	begin = "\x1b[",
	end = "m",
}

struct TextWriter
{
	RefAppender!string text_writer;

	this(ref string text) pure nothrow
	{
		this.text_writer = RefAppender!string(&text);
		return;
	}

	string opSlice() pure nothrow
	{
		return this.text_writer[].dup;
	}

	typeof(this) text(string text) pure nothrow
	{
		text_writer ~= text;
		return this;
	}

	typeof(this) reset() pure nothrow
	{
		this.write_seq(text_writer, SGRCode.reset);
		return this;
	}

	typeof(this) seq(SGRCode[] sgr_list...) pure nothrow
	{
		write_seq(
			text_writer,
			sgr_list,
		);
		return this;
	}

	typeof(this) reset_color() pure nothrow
	{
		this.write_seq(
			text_writer, SGRCode.fg_default, SGRCode.bg_default,
		);
		return this;
	}

protected:
	typeof(this) write_seq(RefAppender!string text_ref, SGRCode[] code_list...) pure nothrow
	{
		text_ref ~= cast(string) EscapeSequence.begin;
		text_ref ~= code_list.map!(seq => (cast(uint) seq).text).array().join(";");
		text_ref ~= cast(string) EscapeSequence.end;
		return this;
	}
}

struct Text
{
	Appender!string text_buffer;

	this(string text)
	{
		text_buffer = appender(text);
		return;
	}

	string opIndex()
	{
		return text_buffer[].dup;
	}

	typeof(this) reset() pure nothrow
	{
		this.write_seq(text_buffer, SGRCode.reset);
		return this;
	}

	ref typeof(this) text(string[] str_list...)
	{
		this.text_buffer ~= str_list.join();
		return this;
	}

	ref typeof(this) seq(SGRCode[] code_list...)
	{
		this.write_seq(text_buffer, code_list);
		return this;
	}

protected:
	typeof(this) write_seq(ref Appender!string text_writer, SGRCode[] code_list...) pure nothrow
	{
		text_writer ~= cast(string) EscapeSequence.begin;
		text_writer ~= code_list.map!(seq => (cast(uint) seq).text).array().join(";");
		text_writer ~= cast(string) EscapeSequence.end;
		return this;
	}
}

unittest
{
	assert(Text("").reset()[] == "\x1b[0m");
	assert(Text("").seq(SGRCode.fg_default, SGRCode.bg_default)[] == "\x1b[39;49m");
	assert(Text("").seq(SGRCode.fg_black_bright)[] == "\x1b[90m");
	assert(Text("").seq(SGRCode.fg_black_bright).text("test").reset()[] == "\x1b[90mtest\x1b[0m");
}

// SelectGraphicRenditionCode
enum SGRCode
{
	reset = 0,
	// style
	bold = 1,
	faint = 2,
	italic = 3,
	underline = 4,
	slow_blink = 5,
	rapid_blink = 6,
	invert = 7,
	conceal = 8,
	strike = 9,
	// font
	default_font = 10,
	// cancel style
	bold_not = 21,
	faint_not,
	italic_not,
	underline_not,
	blink_not,
	proportional_spacing, // what?
	strike_not = 29,
	// foreground color
	fg_black = 30,
	fg_red = 31,
	fg_green = 32,
	fg_yellow = 33,
	fg_blue = 34,
	fg_purple = 35,
	fg_cyan = 36,
	fg_white = 37,
	fg_args = 38,
	fg_default = 39,
	// background color
	bg_black = 40,
	bg_red = 41,
	bg_green = 42,
	bg_yellow = 43,
	bg_blue = 44,
	bg_purple = 45,
	bg_cyan = 46,
	bg_white = 47,
	bg_args = 48,
	bg_default = 49,

	// foreground color
	fg_black_bright = 90,
	fg_red_bright,
	fg_green_bright,
	fg_yellow_bright,
	fg_blue_bright,
	fg_purple_bright,
	fg_cyan_bright,
	fg_white_bright,
	fg_args_bright,
	fg_default_bright,
	// background color
	bg_black_bright = 100,
	bg_red_bright,
	bg_green_bright,
	bg_yellow_bright,
	bg_blue_bright,
	bg_purple_bright,
	bg_cyan_bright,
	bg_white_bright,
	bg_args_bright,
	bg_default_bright,
}

enum ColorBitCode
{
	_24bit = 2,
	_6bit = 5,
}

enum TerminalColorFg
{
	black = 30,
	red,
	green,
	yellow,
	blue,
	magenta,
	cyan,
	white,
	black_bright = 90,
	red_bright,
	green_bright,
	yellow_bright,
	blue_bright,
	magenta_bright,
	cyan_bright,
	white_bright,
}

enum TerminalColorBg
{
	black = 40,
	red,
	green,
	yellow,
	blue,
	magenta,
	cyan,
	white,
	black_bright = 100,
	red_bright,
	green_bright,
	yellow_bright,
	blue_bright,
	magenta_bright,
	cyan_bright,
	white_bright,
}
