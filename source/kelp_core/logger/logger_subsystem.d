module kelp_core.logger.logger_subsystem;

import kelp_core.core;
import kelp_core.logger;

class LoggerSubsystem : Subsystem
{
	Logger logger;

	this(Core core)
	{
		super(core);
		return;
	}

	typeof(this) initialize()
	{
		this.logger = Logger();
		return this;
	}

	typeof(this) finalize()
	{
		return this;
	}

	typeof(this) process()
	{
		return this;
	}

	typeof(this) log(
		string log_text,
		LogLevel level = LogLevel.info,
		LogFlags flags = LogFlags.time | LogFlags.mod,
		LogState state = LogState.here,
	)
	{
		this.logger.log(log_text, level, flags, state);
		return this;
	}
}
