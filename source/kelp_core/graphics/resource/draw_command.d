module kelp_core.graphics.resource.draw_command;

struct DrawCommand
{
	protected DrawCommandIndexedIndirect[] draw_command_indexed;
	protected DrawCommandIndirect[] draw_command;

	size_t size() const pure nothrow @nogc
	{
		return (DrawCommandIndexedIndirect.sizeof * draw_command_indexed.length)
			+ (
				DrawCommandIndirect.sizeof * draw_command.length);
	}

	size_t size(size_t index) const pure nothrow @nogc
	in (index >= 0 && index < 2)
	{
		final switch (index)
		{
		case 0:
			return (DrawCommandIndexedIndirect.sizeof * draw_command_indexed.length);
		case 1:
			return (DrawCommandIndirect.sizeof * draw_command.length);
		}
	}

	size_t offset(size_t index)
	in (index >= 0 && index <= 2)
	{
		final switch (index)
		{
		case 0:
			return 0;
		case 1:
			return this.size(0);
		case 2:
			return this.size(0) + this.size(1);
		}
	}

	size_t count(size_t index)
	in (index >= 0 && index < 2)
	{
		final switch (index)
		{
		case 0:
			return this.draw_command_indexed.length;
		case 1:
			return this.draw_command.length;
		}
	}

	ref DrawCommandIndexedIndirect[] command_indexed() pure nothrow @nogc
	{
		return this.draw_command_indexed;
	}

	ref DrawCommandIndirect[] command() pure nothrow @nogc
	{
		return this.draw_command;
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
