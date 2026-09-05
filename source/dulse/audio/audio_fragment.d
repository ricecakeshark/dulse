module dulse.audio.audio_fragment;

import dulse.audio;

struct AudioFragment
{
	AudioChannel channel;
	float[] buffer;

	ulong size() inout pure nothrow @nogc @safe
	{
		return float.sizeof * buffer.length;
	}
}
