module dulse.audio.audio_desc;

import std.math;

immutable real pitch_12 = pow(2.0L, 1.0L / 12.0L);

float pitch(
	in int small_pitch,
	in int big_pitch,
) pure nothrow @nogc @safe
{
	return pow(pitch_12, small_pitch) * pow(2.0f, big_pitch);
}

enum AudioChannel
{
	_1,
	_2,
}
