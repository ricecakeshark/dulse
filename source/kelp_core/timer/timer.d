module kelp_core.timer.timer;

import std.datetime;
import std.datetime.stopwatch;
import core.thread;

class Timer
{
	int target_frame_rate = 60;
	int min_sleep_dur = 5;
	int max_sleep_dur = 1000;

	StopWatch sw;

	this()
	{
		this.sw = StopWatch(AutoStart.yes);
		return;
	}

	typeof(this) setFrameRate(int target_frame_rate)
	{
		this.target_frame_rate = target_frame_rate;
		return this;
	}

	typeof(this) sleep()
	{
		Duration past_dur;
		long past_time;

		sw.stop();
		past_dur = sw.peek();
		past_time = past_dur.total!("msecs");
		if (past_time < (1_000 / target_frame_rate) - min_sleep_dur && past_time > 0)
		{
			sleep((1_000 / target_frame_rate) - past_time);
		}
		else
		{
			if (past_dur.total!("msecs") < 0)
			{
				sleep(1_000 / target_frame_rate);
			}
			else
			{
				sleep(5);
			}
		}
		sw.reset();
		sw.start();
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
