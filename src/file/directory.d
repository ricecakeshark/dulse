module dulse.file.directory;

import dulse.file;
import std.file;
import std.path : isValidPath;
import std.datetime : SysTime;

struct Directory
{
	protected string _path;
	protected SysTime _time_accessed;
	protected SysTime _time_modified;

	this(string path)
	in
	{
		assert(path.isValidPath);
		assert(path.exists);
		assert(path.isDir);
	}
	do
	{
		this._path = path;
		renew_property();
		return;
	}

	@property string path() pure nothrow @nogc @safe
	{
		return this._path;
	}

	@property SysTime time_accesded()
	{
		return this._time_accessed;
	}

	@property SysTime time_modified()
	{
		return this._time_modified;
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

protected:
	void renew_property()
	{
		getTimes(
			this._path,
			this._time_accessed,
			this._time_modified,
		);
		return;
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
