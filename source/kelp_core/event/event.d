module kelp_core.event.event;

//import kelp_api;
import kelp_core.core;
import kelp_core.event;

alias Poller = Event[]delegate();

class EventSubsystem : Subsystem
{
	MonoPool!(Event) pool;
	Event[]delegate() poll_dlg;

	this(Core core)
	{
		super(core);
		return;
	}

	typeof(this) initialize()
	{
		return this;
	}

	typeof(this) finalize()
	{
		return this;
	}

	typeof(this) process()
	{
		if (poll_dlg !is null)
		{
			this.pool.append(poll_dlg());
		}
		foreach (event; pool.all)
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
		return this;
	}

	typeof(this) register_poller(Event[]delegate() poll_dlg)
	{
		this.poll_dlg = poll_dlg;
		return this;
	}
}
