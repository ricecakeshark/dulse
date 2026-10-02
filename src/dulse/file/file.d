module dulse.file.file;

import std.datetime : SysTime;
import std.digest.murmurhash;
import std.exception : enforce;
import std.file : exists, getSize, isFile, isDir, timeLastModified;
import std.path : baseName, dirName, isValidFilename, isValidPath;
import std.stdio : chunks, File, LockType;
import std.typecons : nullable, Nullable;

static MurmurHash3!(128, 64) hasher_murmur;

struct FileHandler
{
	protected string _path;
	protected Nullable!(ubyte[16]) _hash;
	File handle_substance;
	//File handle_temporary;

	bool last_result = true;

	this(in string path)
	in (path.isValidPath)
	{
		this._open(path);
		return;
	}

	@property bool is_open() const pure nothrow @safe
	{
		return this.handle_substance.isOpen();
	}

	@property bool exsist() const nothrow @nogc @safe
	{
		return this._path.exists;
	}

	@property ulong size() @safe
	{
		return (this.is_open) ? this.handle_substance.size : getSize(this._path);
	}

	@property ubyte[16] hash_raw() pure nothrow @nogc @safe
	{
		return this._hash.get;
	}

	@property char[16 * 2] hash_hex() pure nothrow @nogc @safe
	{
		return this._hash.get.toHexString();
	}

	@property string path() pure nothrow @nogc @safe
	{
		return this._path;
	}

	@property string dir_name() pure nothrow @nogc @safe
	{
		return this._path.dirName();
	}

	@property string name() pure nothrow @nogc @safe
	{
		return this._path.baseName();
	}

	@property SysTime last_modified()
	{
		return timeLastModified(this._path);
	}

	@property ubyte[] data_raw()
	{
		scope ubyte[] buffer;
		get_data_dirty(buffer);
		return buffer;
	}

	ref typeof(this) open(in string path)
	{
		this._open(path);
		return this;
	}

	ref typeof(this) try_lock()
	{
		last_result = this.handle_substance.tryLock(LockType.readWrite);
		return this;
	}

	ref typeof(this) unlock()
	{
		this.handle_substance.unlock();
		return this;
	}

protected:
	void _open(in string path)
	{
		if (!(path.isValidPath && path.exists && path.isFile))
		{
			debug import std.stdio;

			debug stderr.writeln("canceled to open file", path);
			return;
		}
		this.handle_substance.open(path, "r");
		this._path = path;
		this._hash = get_digest().nullable;
		return;
	}

	ubyte[16] get_digest()
	{
		scope File temp_file = File(this._path);
		hasher_murmur.start();
		foreach (chunk; temp_file.byChunk(4096))
		{
			hasher_murmur.put(chunk);
		}
		return hasher_murmur.finish();
	}

	void get_data_dirty(out ubyte[] data)
	{
		foreach (ubyte[] chunk; chunks(this.handle_substance, 4096))
		{
			data ~= chunk;
		}
		return;
	}
}

enum OpenModeFlags
{
	read = 1u << 0,
	write = 1u << 1,
	append = 1u << 2,
}

/+unittest
{
	import std.stdio : writefln;

	FileHandler file;
	file.open(__FILE__);
}+/
