module dulse.input.state.text;

import dulse.input.event.event;
import dulse.input.event.text;

struct InputTextState
{
	string editing;
	string input;
	string[] edit_candidate;

	ref typeof(this) apply(in Event[] event_list...) return pure nothrow @safe
	{
		foreach (event; event_list)
		{
			this.apply(event);
		}
		return this;
	}

	ref typeof(this) apply(in Event event) return pure nothrow @safe
	{
		switch (event.type.minor)
		{
		case EventTypeMinor.text_editing:
			this.apply(event.get!TextEditingEvent());
			break;
		case EventTypeMinor.text_candidate:
			this.apply(event.get!TextEditCandidateEvent());
			break;
		case EventTypeMinor.text_input:
			this.apply(event.get!TextInputEvent());
			break;
		default:
			break;
		}
		return this;
	}

private:
	ref typeof(this) apply(in TextEditingEvent event) return pure nothrow @nogc @safe
	{
		this.editing = event.text;
		return this;
	}

	ref typeof(this) apply(in TextEditCandidateEvent event) return pure nothrow @safe
	{
		this.edit_candidate = event.candidate_list.dup;
		return this;
	}

	ref typeof(this) apply(in TextInputEvent event) return pure nothrow @nogc @safe
	{
		this.input = event.text;
		return this;
	}
}
