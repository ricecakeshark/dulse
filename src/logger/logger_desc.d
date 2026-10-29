module dulse.logger.logger_desc;

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

struct LogState
{
	string file;
	size_t line;
	string func;
	string mod;

	static typeof(this) here(
		string file = __FILE__,
		size_t line = __LINE__,
		string func = __FUNCTION__,
		string mod = __MODULE__,
	) pure nothrow @nogc @safe
	{
		return LogState(file, line, func, mod);
	}
}
