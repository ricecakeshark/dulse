module kelp_core.time.time;

import std.datetime : Clock, Duration, SysTime;
import std.format : format;
import std.typecons : Nullable, nullable;

struct NTime
{
	Nullable!SysTime _time;

	this(SysTime sys_time) pure nothrow @nogc @safe
	{
		this._time = nullable(sys_time);
		return;
	}

	this(Nullable!SysTime time) pure nothrow @nogc @safe
	{
		this._time = time;
		return;
	}

	static typeof(this) current() @safe
	{
		return NTime(Clock.currTime);
	}

	static typeof(this) nat() pure nothrow @nogc @safe
	{
		return NTime(Nullable!SysTime.init);
	}

	@property bool is_valid() const pure nothrow @nogc @safe
	{
		return !this._time.isNull;
	}

	@property bool is_null() const pure nothrow @nogc @safe
	{
		return this._time.isNull;
	}

	int year() const nothrow @safe
	in (this.is_valid)
	{
		return this._time.get.year;
	}

	int month() const nothrow @safe
	in (this.is_valid)
	{
		return this._time.get.month;
	}

	int day() const nothrow @safe
	in (this.is_valid)
	{
		return this._time.get.day;
	}

	Time opBinary(string op : "+")(const NTime rhs) const
	in (this.is_valid && rhs.is_valid)
	{
		return NTime(this._time.get + rhs._time.get);
	}

	Duration opBinary(string op : "-")(const NTime rhs) const
	{
		if (this.is_null || rhs.is_null)
		{
			return Duration.init;
		}
		return this._time.get - rhs._time.get;
	}

	string to_string()
	{
		if (this._time.isNull)
		{
			return "null";
		}
		return format!("%4d")(this.year);
	}
}

unittest
{
	import std.datetime;
	import std.stdio;

	NTime time;
	time = NTime.nat;
	assert(time.is_null);
	time = NTime.current;
	assert(!time.is_null);
	time = NTime(cast(SysTime) Date.fromISOString("20180101"));
	assert(time.year == 2018);
	assert(time.month == 1);
	assert(time.day == 1);
	time = NTime.current;
	writeln(NTime.current);
	writeln(NTime.current - time);
	assert((NTime.current - time).total!"hnsecs" > 0);
}
