module kelp_core.input.desc;

struct Event
{
	EventType type;
}

enum EventType : int
{
	none = 0,
	quit,
}
