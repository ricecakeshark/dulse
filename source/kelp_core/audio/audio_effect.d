module kelp_core.audio.audio_effect;

import kelp_core.audio;

// pre effect

ref AudioPulse pitch_up(
	return ref AudioPulse pulse,
	in float pitch_changes,
) pure nothrow @nogc @safe
{
	pulse.frequency_ratio *= pitch_changes;
	return pulse;
}

// post effect

ref AudioFragment volume(
	return ref AudioFragment fragment,
	in float volume_changes,
) pure nothrow @nogc @safe
{
	foreach (ref buffer_value; fragment.buffer)
	{
		buffer_value *= volume_changes;
	}
	return fragment;
}

ref AudioFragment clip(
	return ref AudioFragment fragment,
	in float clip_border = 1.0f,
) pure nothrow @nogc @safe
{
	foreach (buffer_elm; fragment.buffer)
	{
		if (buffer_elm >= clip_border)
		{
			buffer_elm = clip_border;
		}
	}
	return fragment;
}
