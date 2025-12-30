module kelp_core.event.event;

//import kelp_api;
import kelp_core.core;
import kelp_core.event;

alias Poller = Event[]delegate();

class EventSubsystem : Subsystem
{
	protected Core core;
	MonoPool!(Event) event_pool;
	Event[]delegate() poll_dlg;
	//Handler[] handler_list;

	this(Core core)
	{
		this.core = core;
		this.event_pool = new MonoPool!(Event);
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
			this.event_pool.append(poll_dlg());
		}
		foreach (event; event_pool.all)
		{
			switch (event.type)
			{
			case EventType.quit:
				core.continuable = false;
				//core.bus.send(new QuitMessage());
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
