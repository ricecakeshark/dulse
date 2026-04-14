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
	time = (1u << 0),
	file = (1u << 1),
	mod = (1u << 2),
	func = (1u << 3),
}
