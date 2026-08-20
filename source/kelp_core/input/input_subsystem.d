module kelp_core.input.input_subsystem;

import kelp_core.core;
import kelp_core.input;
import kelp_core.logger;
import std.conv;
import std.sumtype;

alias Poller = Event[]delegate();

class InputSubsystem : Subsystem
{
	MonoPool!(Event) event_pool;
	protected Event[]delegate() poll_dlg;
	public Keyboard keyboard;
	public Mouse mouse;
	public Gamepad gamepad;
	private LoggerSubsystem logger;

	this(Core core)
	{
		super(core);
		this.keyboard = new Keyboard();
		this.mouse = new Mouse();
		this.gamepad = new Gamepad();
		return;
	}

	typeof(this) initialize()
	{
		this.keyboard.initialize();
		this.mouse.initialize();
		this.gamepad.initialize();
		core.subsystem.query(logger);
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
			this.event_pool.append(poll_dlg());
		}

		this.keyboard.process();
		this.mouse.process();
		this.gamepad.process();

		foreach (event; event_pool.all)
		{
			switch (event.type.major)
			{
			case EventTypeMajor.quit:
				core.continuable = false;
				//core.bus.send(new QuitMessage());
				break;
			case EventTypeMajor.keyboard:
				this.keyboard.apply(event);
				break;
			case EventTypeMajor.mouse:
				this.mouse.apply(event);
				break;
			case EventTypeMajor.gamepad:
				this.gamepad.apply(event);
				break;
			default:
				break;
			}
		}
		event_pool.clear();
		return this;
	}

	typeof(this) register_poller(Event[]delegate() poll_dlg)
	{
		this.poll_dlg = poll_dlg;
		return this;
	}
}
