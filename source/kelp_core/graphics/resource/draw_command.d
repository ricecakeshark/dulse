module kelp_core.graphics.resource.draw_command;

struct DrawCommand
{
	protected DrawCommandIndexedIndirect[] draw_command_indexed;
	protected DrawCommandIndirect[] draw_command;

	// size
	@property size_t size() const pure nothrow @nogc
	{
		return (DrawCommandIndexedIndirect.sizeof * draw_command_indexed.length)
			+ (DrawCommandIndirect.sizeof * draw_command.length);
	}

	@property size_t size_command_indexed() const pure nothrow @nogc @safe
	{
		return (DrawCommandIndexedIndirect.sizeof * draw_command_indexed.length);
	}

	@property size_t size_command() const pure nothrow @nogc @safe
	{
		return (DrawCommandIndirect.sizeof * draw_command.length);
	}
	// offset
	@property size_t offset_command_indexed() const pure nothrow @nogc @safe
	{
		return 0u;
	}

	@property size_t offset_command() const pure nothrow @nogc @safe
	{
		return this.size_command_indexed;
	}
	// command
	@property size_t count_command_indexed() const pure nothrow @nogc @safe
	{
		return this.draw_command_indexed.length;
	}

	@property size_t count_command() const pure nothrow @nogc @safe
	{
		return this.draw_command.length;
	}
	// data
	@property ref DrawCommandIndexedIndirect[] command_indexed() pure nothrow @nogc
	{
		return this.draw_command_indexed;
	}

	@property ref DrawCommandIndirect[] command() pure nothrow @nogc
	{
		return this.draw_command;
	}
	// getter setter
	typeof(this) set(
		DrawCommandIndexedIndirect[] command_indexed,
		DrawCommandIndirect[] command,
	) pure nothrow
	{
		this.command_indexed = command_indexed;
		this.command = command;
		return this;
	}
}

struct DrawCommandIndexedIndirect
{
	uint num_indices;
	uint num_instances;
	uint first_index;
	int vertex_offset;
	uint first_instance;
}

struct DrawCommandIndirect
{
	uint num_vertices;
	uint num_instances;
	uint first_vertex;
	uint first_instance;
}
