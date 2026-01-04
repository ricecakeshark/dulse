module kelp_core.core.data.color;

import std.numeric;
import std.algorithm : all, map;
import std.array : staticArray;

//alias Float16 = CustomFloat!(10,5,CustomFloatFlags.ieee);

alias Color = ColorF;

struct ColorF
{
	private float[4] rgba;

	invariant
	{
		assert(this.rgba[].all!(color => color >= 0.0f));
		assert(this.rgba[].all!(color => color <= 1.0f));
	}

	this(float r, float g, float b, float a = 1.0f)
	{
		this.rgba[0] = r;
		this.rgba[1] = g;
		this.rgba[2] = b;
		this.rgba[3] = a;
		return;
	}

	@property ref float red() pure nothrow @nogc
	{
		return this.rgba[0];
	}

	@property ref float green() pure nothrow @nogc
	{
		return this.rgba[1];
	}

	@property ref float blue() pure nothrow @nogc
	{
		return this.rgba[2];
	}

	@property ref float alpha() pure nothrow @nogc
	{
		return this.rgba[3];
	}

	ColorU opCast(T : ColorU)() const
	{
		return ColorU(this.rgba[]
				.map!(color => color * 255.9f)
				.map!(color => cast(ubyte) color)
				.staticArray!(ubyte[4])());
	}
}

struct ColorU
{
	ubyte[4] rgba;

	this(ubyte[3] rgb...)
	{
		this.rgba = rgb~0x00u;
		return;
	}

	this(ubyte[4] rgba...)
	{
		this.rgba = rgba;
		return;
	}

	@property ref ubyte red() pure nothrow @nogc
	{
		return this.rgba[0];
	}

	@property ref ubyte green() pure nothrow @nogc
	{
		return this.rgba[1];
	}

	@property ref ubyte blue() pure nothrow @nogc
	{
		return this.rgba[2];
	}

	@property ref ubyte alpha() pure nothrow @nogc
	{
		return this.rgba[3];
	}

	ColorF opCast(T : ColorF)() const
	{
		return ColorF(this.rgba[]
				.map!(color => color / 255.9f)
				.map!(color => cast(float) color)
				.staticArray!(float[4])());
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
