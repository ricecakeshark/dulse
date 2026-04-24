module kelp_core.file.directory;

import kelp_core.file;
import std.file;
import std.path : isValidPath;

struct Directory
{
	string path;

	this(string path)
	in
	{
		assert(path.isValidPath);
		assert(path.exists);
		assert(path.isDir);
	}
	do
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

/+unittest
{
	import std.stdio;

	auto dir = Directory(".");

	foreach (entry; dir.entries)
	{
		writeln(entry.path);
	}
}+/
