module source.kelp_core.time.duration;

import core.time : Duration;
import std.typecons : Nullable, nullable;

struct NDuration
{
	Nullable!Duration _dur;

	this(Nullable!Duration dur) pure nothrow @nogc @safe
	{
		this._dur = dur;
		return;
	}

	this(Duration dur) pure nothrow @nogc @safe
	{
		this._dur = nullable(dur);
		return;
	}

	static typeof(this) nat() pure nothrow @nogc @safe
	{
		return NDuration(Nullable!Duration.init);
	}

	@property bool is_valid() const pure nothrow @nogc @safe
	{
		return !this._dur.isNull;
	}

	@property bool is_null() const pure nothrow @nogc @safe
	{
		return this._dur.isNull;
	}

	long total(string units)() const pure nothrow @nogc @safe
	{
		return this._dur.total!units;
	}
}
