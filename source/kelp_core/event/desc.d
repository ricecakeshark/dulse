module kelp_core.event.desc;

struct Event
{
	EventType type;
}

enum EventType : int
{
	none = 0,
	quit,
}
