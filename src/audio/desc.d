module dulse.audio.desc;

struct AudioSpec
{
	AudioFormat format;
	int channels;
	int frequency;
	alias freq = frequency;
}

enum AudioFormat
{
	unknown = 0,
	u8,
	s8,
	s16le,
	s16be,
	s32le,
	s32be,
	f32le,
	f32be,
}