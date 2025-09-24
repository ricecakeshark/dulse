module kelp_core.timer.timer;

import core.thread;

void sleep(int wait_dur)
{
	Thread.sleep(dur!("msecs")(wait_dur));
	return;
}

void sleep(Duration wait_dur)
{
	Thread.sleep(wait_dur);
	return;
}
