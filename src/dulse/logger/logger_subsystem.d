module dulse.logger.logger_subsystem;

import dulse.core;
import dulse.logger;

class LoggerSubsystem : Subsystem!LoggerSubsystem
{
	Logger logger;

	this(Core core)
	{
		super(core);
		return;
	}

	override typeof(this) initialize()
	{
		this.logger = Logger();
		return this;
	}

	override typeof(this) finalize()
	{
		return this;
	}

	override typeof(this) process()
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
