module kelp_core.console.ansi;

import kelp_core.core.data;
import std.array : join;
import std.conv : to;
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
	Nullable!ColorU color_fg;
	Nullable!ColorU color_bg;

	this(string text)
	{
		this.text = text;
		this.color_fg.nullify;
		this.color_bg.nullify;
		return;
	}

	this(string text, ColorU color_fg, ColorU color_bg)
	{
		this.text = text;
		this.color_fg = color_fg.nullable;
		this.color_bg = color_bg.nullable;
		return;
	}

	string opSlice()
	{
		string buf;
		return TextWriter(buf).text_colored(text, color_fg, color_bg)[].dup;
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
		Nullable!ColorU color_fg,
		Nullable!ColorU color_bg,
	)
	{
		text_ref ~= set_color(color_fg, color_bg);
		text_ref.put(text);
		text_ref ~= reset_color();
		return this;
	}

	string opSlice()()
	{
		return text_ref[].dup;
	}

protected:
	string reset()
	{
		return cast(string) EscapeSequence.begin
			~ to!string(
				cast(int) SGRCode.reset)
			~ cast(string) EscapeSequence.end;
	}

	string set_color(Nullable!ColorU color_fg, Nullable!ColorU color_bg)
	{
		return format!"%s%s%s"(
			cast(string) EscapeSequence.begin,
			format!"%s;%s"(
				this.color_fg(color_fg),
				this.color_bg(color_bg),
		),
		cast(string) EscapeSequence.end,
		);
	}

	string reset_color()
	{
		return format!"%s%s%s"(
			cast(string) EscapeSequence.begin,
			format!"%d;%d"(cast(int) SGRCode.fg_default,
				cast(int) SGRCode.bg_default),
			cast(string) EscapeSequence.end,
		);
	}

	string color_fg(Nullable!ColorU color_fg) pure
	{
		if (color_fg.isNull)
		{
			return "39";
		}
		return to!string(cast(int) SGRCode.fg_args)
			~ ";"
			~ color_24bit(color_fg.get);
	}

	string color_bg(Nullable!ColorU color_bg) pure
	{
		if (color_bg.isNull)
		{
			return "49";
		}
		return to!string(cast(int) SGRCode.bg_args)
			~ ";"
			~ color_24bit(color_bg.get);
	}

}

string color_24bit(ColorU color) pure
{
	return format!"2;%d;%d;%d"(color.red, color.green, color.blue,);
}

unittest
{
	import std.stdio;

	assert(Text("text", ColorU(0, 100, 200), ColorU(200, 100, 0))[] == "\x1b[38;2;0;100;200;48;2;200;100;0mtext\x1b[39;49m");
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
