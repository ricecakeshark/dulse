module kelp_core.logger.logger_desc;

enum LogLevel
{
	none = 0u,
	error,
	warning,
	success,
	info,
	
	
}

enum LogFlags : uint
{
	none = 0u,
	full_uri = (1u << 0),
	full_module = (1u << 1),
	full_function = (1u << 2),
}

