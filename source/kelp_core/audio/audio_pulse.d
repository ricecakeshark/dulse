module kelp_core.audio.audio_pulse;

import kelp_core.audio;
import kelp_core.math.group;
import std.datetime;
import std.math;

class AudioPulse : AudioSource
{
	float frequency_ratio;
	uint sample_rate;
	SysTime last_write_back;
	Duration dur_write_back;
	LoopedFloat!(PI * 2.0) last_phase;

	this(float frequency_ratio, uint sample_rate)
	{
		this.frequency_ratio = frequency_ratio;
		this.sample_rate = sample_rate;
		this.last_write_back = Clock.currTime;
		this.dur_write_back = dur!("msecs")(cast(size_t)(sample_rate * 0.05));
		this.last_phase = 0.0;
		return;
	}

	override void write_back(out float[] back_buffer)
	{
		size_t sample_len = cast(size_t)(sample_rate * 0.05);
		back_buffer.length = sample_len;
		real delta_radian = 2.0 * PI * (this.frequency_ratio / sample_rate);
		foreach (count; 0 .. sample_len)
		{
			back_buffer[count] = sin(last_phase + delta_radian * count);
		}
		this.last_write_back += this.dur_write_back;
		this.last_phase += delta_radian * sample_len;
		return;
	}
}
