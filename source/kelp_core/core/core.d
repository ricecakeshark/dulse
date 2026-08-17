module kelp_core.core.core;

import kelp_core;

final class Core
{
	SubsystemPool subsystem;
	protected MessageBus bus;
	bool continuable = true;

	this()
	{
		this.bus = new MessageBus();
		this.subsystem = new SubsystemPool();
		subsystem.append(
			new LoggerSubsystem(this),
			new TimerSubsystem(this),
			new InputSubsystem(this),
			new ObjectSubsystem(this),
		);
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
