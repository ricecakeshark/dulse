module kelp_core.timer.timer;

import kelp_core.core;

//import kelp_api;
import std.datetime;
import core.thread;

class TimerSubsystem : Subsystem
{
	protected Core core;
	int target_frame_rate = 60;
	int min_sleep_dur = 5;
	int max_sleep_dur = 1000;

	private SysTime begin;
	protected Duration last_dur_active, last_dur_slept;
	private SysTime begin_active, begin_sleep;

	this(Core core)
	{
		super(core);
		return;
	}

	typeof(this) initialize()
	{
		begin = Clock.currTime();
		begin_active = Clock.currTime();
		begin_sleep = Clock.currTime();
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

	@property inout(long) past() inout @safe
	{
		return (Clock.currTime() - begin).total!("msecs");
	}

	@property inout(long) delta() inout pure nothrow @nogc @safe
	{
		return (this.last_dur_active + this.last_dur_slept).total!"msecs";
	}

	typeof(this) setFrameRate(int target_frame_rate)
	{
		this.target_frame_rate = target_frame_rate;
		return this;
	}

	typeof(this) sleep()
	{
		last_dur_active = Clock.currTime() - begin_active;
		begin_sleep = Clock.currTime();
		Thread.sleep(dur!"usecs"(16_000));
		last_dur_slept = Clock.currTime() - begin_sleep;
		begin_active = Clock.currTime();
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
