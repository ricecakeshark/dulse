module kelp_core.logger.logger;

import kelp_core.core;
import std.logger;

class LoggerSubsystem : Subsystem
{
	protected Core core;

	this(Core core)
	{
		this.core = core;
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
