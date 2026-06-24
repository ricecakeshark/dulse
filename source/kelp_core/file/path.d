module kelp_core.file.path;

import std.array : split;
import std.file : isDir, isFile;

struct Path
{
	string full_path;
	string[] path;

	this(string path)
	{
		this.full_path = path;
		this.path = path.split("/");
		return;
	}

	@property bool is_file() @safe
	{
		return this.full_path.isFile();
	}

	@property bool is_dir() @safe
	{
		return this.full_path.isDir();
	}
}
