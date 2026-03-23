module kelp_core.core.data.ansi_sgr;

import kelp_core.core.data;
import std.array;
import std.conv;
import std.format;

enum EscapeSequence : string
{
	begin = "\x1b[",
	end = "m",
}

struct AnsiText
{
	string text;
	ColorU color_fg;
	ColorU color_bg;

	this(
		string text,
		ColorU color_fg = ColorU(0xff, 0xff, 0xff),
		ColorU color_bg = ColorU(0x00, 0x00, 0x00)
	)
	{
		this.text = text;
		this.color_fg = color_fg;
		this.color_bg = color_bg;
		return;
	}

	string output() pure nothrow
	{
		return format_SGR(color_fg_24bit(color_fg), color_bg_24bit(color_bg))
			~ text
			~ format_SGR(
				"0");
	}
}
// write text with SGR
ref Appender!string write_text_colored(
	ref Appender!string buf,
	string text,
	ColorU color_fg,
	ColorU color_bg,
)
{
	buf.put!string(EscapeSequence.begin);
	buf ~= color_fg_24bit(color_fg) ~ ";";
	buf ~= color_bg_24bit(color_bg);
	buf ~= cast(string) EscapeSequence.end;
	buf ~= text;
	buf ~= EscapeSequence.begin ~ "0" ~ EscapeSequence.end;
	return buf;
}

string format_SGR(string[] sgr_list...) pure nothrow @safe
{
	return EscapeSequence.begin ~ sgr_list.join(";") ~ EscapeSequence.end;
}

string color_fg_24bit(ColorU color) pure nothrow
{
	return "38" ~ ";" ~ sequence_color_24bit(color);
}

string color_bg_24bit(ColorU color) pure nothrow
{
	return "48;" ~ sequence_color_24bit(color);
}

string sequence_color_24bit(ColorU color) pure nothrow
{
	return "2;" ~ to!string(color.red) ~ ";" ~ to!string(color.green) ~ ";" ~ to!string(color.blue);
}
// Select Graphic Rendition Code
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

unittest
{
	import std.stdio;
	import std.encoding;

	Appender!string buf;
	buf.write_text_colored("text", ColorU(200, 100, 0), ColorU(0, 100, 200));
	writeln(buf[]);
	assert(buf[] == "\x1b[38;2;200;100;0;48;2;0;100;200mtext\x1b[0m");
}
