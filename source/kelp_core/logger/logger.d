module kelp_core.logger.logger;

import kelp_core.core;
import std.logger;

class LoggerSubsystem : Subsystem
{
	MessageBus bus;

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
		return;
	}

	void log(string log_text)
	{
		std.logger.log(log_text);
		return;
	}
}
