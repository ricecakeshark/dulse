module kelp_core.audio.audio_fragment;

import kelp_core.audio;

struct AudioFragment
{
	AudioChannel channel;
	float[] buffer;

	ulong size() inout pure nothrow @nogc @safe
	{
		return float.sizeof * buffer.length;
	}
}
