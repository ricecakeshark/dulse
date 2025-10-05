module kelp_core.timer.timer;

import kelp_api;
import std.datetime;
import core.thread;

class TimerSubsystem : Subsystem
{
	int target_frame_rate = 60;
	int min_sleep_dur = 5;
	int max_sleep_dur = 1000;

	SysTime measure_begin;
	Duration last_past_dur;
	long last_past;

	this()
	{
		return;
	}

	void initialize()
	{
		measure_begin = Clock.currTime();
		return;
	}

	void finalize()
	{
		return;
	}

	void process()
	{
		this.sleep();
		return;
	}

	typeof(this) setFrameRate(int target_frame_rate)
	{
		this.target_frame_rate = target_frame_rate;
		return this;
	}

	typeof(this) sleep()
	{
		last_past_dur = Clock.currTime() - measure_begin;
		last_past = last_past_dur.total!("msecs");

		if (last_past < (1_000 / target_frame_rate) - min_sleep_dur && last_past >= 0)
		{
			sleep((1_000 / target_frame_rate) - last_past);
		}
		else
		{
			if (last_past < 0)
			{
				sleep(1_000 / target_frame_rate);
			}
			else
			{
				sleep(5);
			}
		}
		measure_begin = Clock.currTime();
		return this;
	}

protected:
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