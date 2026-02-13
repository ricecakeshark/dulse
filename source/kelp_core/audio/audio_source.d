module kelp_core.audio.audio_source;

import kelp_core.audio;
import std.datetime;

interface AudioSource
{
	void write_back(out AudioFragment);
}
