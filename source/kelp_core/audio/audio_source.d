module kelp_core.audio.audio_source;

import std.datetime;

interface AudioSource
{
	void write_back(out float[]);
}
