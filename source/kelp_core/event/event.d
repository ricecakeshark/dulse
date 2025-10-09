module kelp_core.event.event;

import kelp_api;
import kelp_core.core.structure.pool;
import kelp_core.event.desc;

class EventSubsystem : Subsystem
{
	Pool!(Event) event_pool;
	Event[]delegate() poll_dlg;

	void initialize()
	{
		return;
	}

	void finalize()
	{
		return;
	}

	void process()
	{
		if (poll_dlg !is null)
		{
			poll_dlg();
		}
		return;
	}
}
