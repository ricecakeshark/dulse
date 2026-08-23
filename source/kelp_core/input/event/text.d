module kelp_core.input.event.text;

struct TextEditingEvent
{
	string text;
}

struct TextEditCandidateEvent
{
	string[] candidate_list;
}

struct TextInputEvent
{
	string text;
}
