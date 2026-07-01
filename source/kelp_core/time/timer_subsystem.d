module kelp_core.time.time_subsystem;

import kelp_core.core;
import kelp_core.time;
import std.datetime : Duration;
import core.thread;

class TimerSubsystem : Subsystem
{
	protected Core core;

	NTime time_start;
	TimeMeasure measure_active, measure_sleep;
	Duration dur_active, dur_sleep;

	this(Core core)
	{
		super(core);
		return;
	}

	typeof(this) initialize()
	{
		time_start = NTime.current;
		measure_active.start;
		return this;
	}

	typeof(this) finalize()
	{
		return this;
	}

	typeof(this) process()
	{
		this.sleep();
		return this;
	}

	@property inout(long) past(string units = "usecs")() inout @safe
	{
		return (NTime.current - time_start).total!units;
	}

	@property inout(long) delta(string units = "usecs")() inout pure nothrow @nogc @safe
	{
		return (this.dur_active + this.dur_sleep).total!units;
	}

	typeof(this) set_frame_rate(int target_frame_rate)
	{
		//this.target_frame_rate = target_frame_rate;
		return this;
	}

	typeof(this) sleep()
	{
		measure_active.stop;
		dur_active = measure_active.peek;
		measure_sleep.start;
		Thread.sleep(dur!"usecs"(16_000));
		measure_sleep.stop;
		dur_sleep = measure_sleep.peek;
		measure_active.start;
		return this;
	}

	static void sleep(long wait_dur) nothrow @nogc @trusted
	{
		Thread.sleep(dur!("msecs")(wait_dur));
		return;
	}

	static void sleep(Duration wait_dur) nothrow @nogc @trusted
	{
		Thread.sleep(wait_dur);
		return;
	}
}

/+
import std.array : appender;

struct Measure
{
	Appender!(long[]) active_time_list;
	Appender!(long[]) idle_time_list;

	this()
	{
		return;
	}


}
+/
