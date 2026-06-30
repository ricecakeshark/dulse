module kelp_core.time.time_measure;

import kelp_core.time;
import std.datetime;
import std.typecons : Nullable, nullable;

struct TimeMeasure
{
	NTime _begin_time, _end_time;

	@property bool measuring()
	{
		return (this._begin_time.is_valid && this._end_time.is_null);
	}

	@property NTime begin() const pure nothrow @nogc @safe
	{
		return (!this._begin_time.is_null)
			? this._begin_time : NTime.init;
	}

	@property NTime end() const pure nothrow @nogc @safe
	{
		return (!this._end_time.is_null)
			? this._end_time : NTime.init;
	}

	@property Duration peek() const pure nothrow @nogc @safe
	{
		return this._end_time - this._begin_time;
	}

	ref typeof(this) start()
	{
		if (this._end_time.is_valid)
		{
			this._end_time = NTime.init;
			return this;
		}
		this._begin_time = NTime.current;
		return this;
	}

	ref typeof(this) stop()
	{
		if (this._begin_time.is_null)
		{
			this._end_time = NTime.init;
			return this;
		}
		this._end_time = NTime.current;
		return this;
	}
}

unittest
{
	import std.datetime;

	TimeMeasure measure;
	measure = TimeMeasure(
		NTime.init,
		NTime.init,
	);
	assert(!measure.measuring);
	measure = TimeMeasure(
		NTime(cast(SysTime) Date.fromISOString("20180101")),
		NTime.init,
	);
	assert(measure.measuring);
	measure = TimeMeasure(
		NTime(cast(SysTime) Date.fromISOString("20180101")),
		NTime(cast(SysTime) Date.fromISOString("20180201")),
	);
	assert(!measure.measuring);
	assert(measure.peek.total!"hnsecs" > 0);

}
