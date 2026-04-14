module kelp_core.logger.logger_subsystem;

import kelp_core.core;
import kelp_core.logger;

class LoggerSubsystem : Subsystem
{
	protected Core core;
	Logger logger;

	this(Core core)
	{
		this.core = core;
		return;
	}

	void initialize()
	{
		this.logger = Logger();
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

	void log(
		string log_text,
		LogLevel level = LogLevel.info,
		LogFlags flags = LogFlags.time,
		string file = __FILE__,
		size_t line = __LINE__,
		string func = __FUNCTION__,
		string mod = __MODULE__,
	)
	{
		//std.logger.info(log_text, line, file, func);
		this.logger.log(log_text, level, flags, file, line, func, mod);
		return;
	}
}
