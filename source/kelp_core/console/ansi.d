module kelp_core.console.ansi;

import kelp_core.core.data;
import std.algorithm;
import std.array : join;
import std.conv : to, text;
import std.format;
import std.array;
import std.typecons;

enum EscapeSequence : string
{
	begin = "\x1b[",
	end = "m",
}

struct Text
{
	string text;
	string color_fg;
	string color_bg;

	this(string text) pure nothrow
	{
		this.text = text;
		return;
	}

	ref typeof(this) color(SGRCode color_fg, SGRCode color_bg) pure nothrow
	{
		this.color_fg = (cast(uint) color_fg).text();
		this.color_bg = (cast(uint) color_bg).text();
		return this;
	}

	string opSlice() pure nothrow
	{
		string buf;
		return TextWriter(buf)
			.seq(this.color_fg, this.color_bg)
			.text(this.text)
			.seq(SGRCode.reset)[].dup;
	}
}

struct TextWriter
{
	RefAppender!string text_ref;

	this(ref string text) pure nothrow
	{
		text_ref = appender(&text);
		return;
	}

	string opSlice()() pure nothrow
	{
		return text_ref[].dup;
	}

	ref typeof(this) text(string text) pure nothrow
	{
		text_ref ~= text;
		return this;
	}

	ref typeof(this) reset() pure nothrow
	{
		text_ref ~= cast(string) EscapeSequence.begin;
		text_ref ~= "0";
		text_ref ~= cast(string) EscapeSequence.end;
		return this;
	}

	ref typeof(this) seq(string[] sequence_list...) pure nothrow
	{
		text_ref ~= cast(string) EscapeSequence.begin;
		text_ref ~= sequence_list.join(";");
		text_ref ~= cast(string) EscapeSequence.end;
		return this;
	}

	ref typeof(this) seq(SGRCode[] sgr_list...) pure nothrow
	{
		text_ref ~= cast(string) EscapeSequence.begin;
		text_ref ~= sgr_list.map!(sequence => (cast(uint) sequence)
				.to!string())
			.array()
			.join(";");
		text_ref ~= cast(string) EscapeSequence.end;
		return this;
	}

	ref typeof(this) reset_color() pure nothrow
	{
		text_ref ~= cast(string) EscapeSequence.begin;
		text_ref ~= (cast(uint)SGRCode.fg_default).to!string();
		text_ref ~= ";";
		text_ref ~= (cast(uint)SGRCode.bg_default).to!string();
		text_ref ~= cast(string) EscapeSequence.end;
		return this;
	}
}

unittest
{
	import std.stdio;
	// fix later
	//assert(Text("text", ColorU(0, 100, 200), ColorU(200, 100, 0))[] == "\x1b[38;2;0;100;200;48;2;200;100;0mtext\x1b[39;49m");
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
