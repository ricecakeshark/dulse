module kelp_core.input.handler;

import kelp_core.input;
import std.algorithm : canFind;

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
