module kelp_core.core.core;

import kelp_core;

//import kelp_api;

final class Core
{
	SubsystemPool subsystem;
	protected MessageBus bus;
	bool continuable = true;

	this()
	{
		this.bus = new MessageBus();
		this.subsystem = new SubsystemPool();
		subsystem.append(new LoggerSubsystem(this));
		subsystem.append(new TimerSubsystem(this));
		subsystem.append(new EventSubsystem(this));
		subsystem.append(new DeviceSubsystem(this));
		return;
	}

	void initialize()
	{
		this.subsystem.initialize();
		//this.subsystem.apply((item) { item.initialize(); });
		return;
	}

	void finalize()
	{
		this.subsystem.finalize();
		//this.subsystem.apply((item) { item.finalize(); });
		return;
	}

	void process()
	{
		this.subsystem.process();
		//this.subsystem.apply((item) { item.process(); });
		if (this.bus.pool.have!(QuitMessage))
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
