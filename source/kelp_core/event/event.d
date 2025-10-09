module kelp_core.event.event;

//import kelp_api;
import kelp_core.core;
import kelp_core.event;

class EventSubsystem : Subsystem
{
	protected MessageBus bus;
	Pool!(Event) event_pool;
	Event[]delegate() poll_dlg;
	//Handler[] handler_list;

	this(MessageBus bus)
	{
		this.bus = bus;
		return;
	}

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
		foreach (event; event_pool.all)
		{
			switch (event)
			{
			case Event.quit:
				this.bus.send(new QuitRequest());
				break;
			default:
				break;
			}
		}
		return;
	}

	typeof(this) register_poller(Event[]delegate() poll_dlg)
	{
		this.poll_dlg = poll_dlg;
		return this;
	}
}
