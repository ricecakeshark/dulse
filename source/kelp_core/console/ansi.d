module kelp_core.console.ansi;

import kelp_core.core.data;
import std.array : join;
import std.conv : to;
import std.format;
import std.array;

enum EscapeSequence : string
{
	begin = "\x1b[",
	end = "m",
}

struct Text
{
	string text;
	ColorU color_fg;
	ColorU color_bg;

	this(string text, ColorU color_fg, ColorU color_bg)
	{
		this.text = text;
		this.color_fg = color_fg;
		this.color_bg = color_bg;
		return;
	}

	string opSlice()
	{
		string buf;
		return TextWriter(buf).text_colored(text, color_fg, color_bg)[];
	}
}

struct TextWriter
{
	RefAppender!string text_ref;

	this(ref string text)
	{
		text_ref = appender(&text);
		return;
	}

	ref typeof(this) text(string text)
	{
		text_ref ~= text;
		return this;
	}

	ref typeof(this) text_colored(
		string text,
		ColorU color_fg,
		ColorU color_bg,
	)
	{
		text_ref ~= cast(string) EscapeSequence.begin;
		this.color_fg(color_fg);
		text_ref.put(";");
		this.color_bg(color_bg);
		text_ref ~= cast(string) EscapeSequence.end;
		text_ref.put(text);
		text_ref ~= cast(string) EscapeSequence.begin;
		text_ref.put("0");
		text_ref ~= cast(string) EscapeSequence.end;
		return this;
	}

	string opSlice()()
	{
		return text_ref[].dup;
	}

protected:
	ref typeof(this) reset()
	{
		text_ref ~= cast(string) EscapeSequence.begin;
		text_ref ~= to!string(SGRCode.reset);
		text_ref ~= cast(string) EscapeSequence.end;
		return this;
	}

	ref typeof(this) color_fg(ColorU color)
	{
		text_ref ~= to!string(cast(int) SGRCode.fg_args);
		text_ref ~= ";";
		text_ref.write_color_24bit(color);
		return this;
	}

	ref typeof(this) color_bg(ColorU color)
	{
		text_ref ~= to!string(cast(int) SGRCode.bg_args);
		text_ref ~= ";";
		text_ref.write_color_24bit(color);
		return this;
	}

}

void write_color_24bit(RefAppender!string text_ref, ColorU color)
{
	text_ref ~= "2;";
	text_ref ~= to!string(color.red);
	text_ref ~= ";";
	text_ref ~= to!string(color.green);
	text_ref ~= ";";
	text_ref ~= to!string(color.blue);
	return;
}

unittest
{
	import std.stdio;

	string text_buf;
	TextWriter(text_buf).text_colored("text", ColorU(0, 100, 200), ColorU(200, 100, 0));
	assert(text_buf == "\x1b[38;2;0;100;200;48;2;200;100;0mtext\x1b[0m");
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
}

enum ColorBitCode
{
	_24bit = 2,
	_6bit = 5,
}
