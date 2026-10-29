module dulse.core.data.color;

import dulse.math.linalg;

import std.array : staticArray;
import std.math : isNaN;

//alias Float16 = CustomFloat!(10,5,CustomFloatFlags.ieee);

alias Color = ColorF;

struct ColorF
{
	public float red, green, blue, alpha;

	invariant
	{
		assert(this.red.isNaN == false);
		assert(this.blue.isNaN == false);
		assert(this.green.isNaN == false);
		assert(this.alpha.isNaN == false);
	}

	this(float r, float g, float b, float a = 1.0f)
	{
		this.red = r;
		this.green = g;
		this.blue = b;
		this.alpha = a;
		return;
	}

	this(float rgb)
	{
		this.red = rgb;
		this.green = rgb;
		this.blue = rgb;
		this.alpha = 1.0f;
		return;
	}

	this(float[4] rgba)
	{
		this.red = rgba[0];
		this.green = rgba[1];
		this.blue = rgba[2];
		this.alpha = rgba[3];
		return;
	}

	this(Vec4 vec)
	{
		this.red = vec[0];
		this.green = vec[1];
		this.blue = vec[2];
		this.alpha = vec[3];
		return;
	}

	inout(float[4]) elements() inout pure nothrow @nogc @safe
	{
		return [this.red, this.green, this.blue, this.alpha];
	}

	ColorU opCast(T : ColorU)() const
	{
		return ColorU(
			this.red.to_ubyte_color(),
			this.green.to_ubyte_color(),
			this.blue.to_ubyte_color(),
			this.alpha.to_ubyte_color(),
		);
	}

	Vec4 to_vec() pure nothrow @nogc @safe
	{
		return Vec4(this.red, this.green, this.blue, this.alpha);
	}
}

struct ColorU
{
	public ubyte red, green, blue, alpha;

	this(ubyte r, ubyte g, ubyte b, ubyte a = 0xff)
	{
		this.red = r;
		this.green = g;
		this.blue = b;
		this.alpha = a;
		return;
	}

	this(ubyte[4] rgba)
	{
		this.red = rgba[0];
		this.green = rgba[1];
		this.blue = rgba[2];
		this.alpha = rgba[3];
		return;
	}

	inout(ubyte[4]) elements() inout pure nothrow @nogc @safe
	{
		return [this.red, this.green, this.blue, this.alpha];
	}

	ColorU opCast(T : ColorF)() const
	{
		return ColorU(
			this.red.to_float_color(),
			this.green.to_float_color(),
			this.blue.to_float_color(),
			this.alpha.to_float_color(),
		);
	}
}

unittest
{
	ColorF color_f = ColorF(1.0f, 0.5f, 0.0f);
	ColorU color_u = cast(ColorU) color_f;
	assert(color_u.red == 255u);
	assert(color_u.green == 127u);
	assert(color_u.blue == 0u);
}

pure ubyte to_ubyte_color(float color) nothrow @nogc @safe
{
	return cast(ubyte)(color * 255.9f);
}

pure float to_float_color(ubyte color) nothrow @nogc @safe
{
	return (cast(float) color / 255.9f);
}
