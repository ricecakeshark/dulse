module dulse.audio.audio_source;

import dulse.audio;
import std.datetime;

interface AudioSource
{
	void write_back(out AudioFragment);
}
