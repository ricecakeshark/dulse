module kelp_core.file.directory;

import kelp_core.file;
import std.file;

struct Directory
{
	string path;

	this(string path)
	in (path.exists)
	in (path.isDir)
	{
		this.path = path;
		return;
	}

	@property FileHandler[] entries()
	{
		FileHandler[] file_list;
		foreach (entry; path.dirEntries(SpanMode.shallow))
		{
			if (entry.isFile == false)
			{
				continue;
			}
			file_list ~= FileHandler(entry);
		}
		return file_list;
	}
}

unittest
{
	import std.stdio;

	auto dir = Directory(".");

	foreach (entry; dir.entries)
	{
		writeln(entry.path);
	}
}
