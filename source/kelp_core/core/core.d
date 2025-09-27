module kelp_core.core.core;

import kelp_core;
import kelp_api;

final class Kelp
{
	SubsystemPool subsystem;

	this()
	{
		this.subsystem = new SubsystemPool();
		this.subsystem.register(new TimerSubsystem());
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
		return;
	}
}
