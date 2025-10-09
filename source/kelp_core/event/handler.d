module kelp_core.event.handler;

import kelp_core.event;
import std.algorithm;

struct Handler
{
	Event capture_event;
	void delegate() dlg;

	this(Event capture_event, void delegate() dlg)
	{
		this.capture_event = capture_event;
		this.dlg = dlg;
		return;
	}

	void call(Event[] call_event)
	{
		if (call_event.canFind(capture_event))
		{
			dlg();
		}
		return;
	}
}
