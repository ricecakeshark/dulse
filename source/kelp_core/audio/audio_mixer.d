module kelp_core.audio.audio_mixer;

import kelp_core.audio;
import std.array;
import std.algorithm;

class AudioMixer
{
	AudioSource[] source_list;

	this()
	{
		return;
	}

	typeof(this) register(AudioSource register_audio)
	in (register_audio !is null)
	{
		assert(this.source_list.all!(elm => elm !is register_audio));
		this.source_list ~= register_audio;
		return this;
	}

	typeof(this) unregister(AudioSource unregister_audio)
	{
		this.source_list = this.source_list.remove!(audio => audio !is unregister_audio).array();
		return this;
	}

	typeof(this) write_back(out AudioFragment back_buffer)
	in (this.source_list.length >= 1)
	{
		this.source_list[0].write_back(back_buffer);
		return this;
	}
}
