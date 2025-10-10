module kelp_core.core.core;

import kelp_core;
//import kelp_api;

final class Kelp
{
	SubsystemPool subsystem;
	protected MessageBus bus;
	bool continuable = true;

	this()
	{
		this.bus = new MessageBus();
		this.subsystem = new SubsystemPool();
		this.subsystem.append(new TimerSubsystem(this.bus));
		this.subsystem.append(new EventSubsystem(this.bus));
		return;
	}

	void initialize()
	{
		this.subsystem.initialize();
		return;
	}

	void finalize()
	{
		this.subsystem.finalize();
		return;
	}

	void process()
	{
		this.subsystem.process();
		if( this.bus.have!(QuitMessage) )
		{
			this.continuable = false;
		}
		return;
	}

	void quit()
	{
		this.continuable = false;
		return;
	}
}
