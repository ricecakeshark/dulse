module kelp_core.file.file;

import std.datetime : SysTime;
import std.digest;
import std.digest.murmurhash;
import std.exception : enforce;
import std.file : exists, isFile, isDir, timeLastModified;
import std.path : baseName, dirName, isValidFilename, isValidPath;
import std.stdio : File, LockType;

//import std.string;

static MurmurHash3!(128, 64) hasher_murmur;

struct FileHandler
{
	string _path;
	ubyte[16] hash;
	File handle_substance;
	File handle_temporary;
	bool last_result = true;

	this(string path)
	in
	{
		assert(path.isValidPath);
		assert(path.isFile);
	}
	do
	{
		this.open(path);
		return;
	}

	@property bool is_open() const pure nothrow @safe
	{
		return this.handle_substance.isOpen();
	}

	@property ulong size() @safe
	{
		return this.handle_substance.size;
	}

	@property ubyte[16] hash_raw() pure nothrow @nogc @safe
	{
		return this.hash;
	}

	@property char[16 * 2] hash_hex() pure nothrow @nogc @safe
	{
		return this.hash.toHexString();
	}

	@property string path() pure nothrow @nogc @safe
	{
		return this.path;
	}

	@property string dir_name() pure nothrow @nogc @safe
	{
		return this.path.dirName();
	}

	@property string file_name() pure nothrow @nogc @safe
	{
		return this.path.baseName();
	}

	@property SysTime last_modified()
	{
		return timeLastModified(this.path);
	}

	typeof(this) open(string path)
	{
		enforce(path.exists);
		enforce(path.isFile);
		this.handle_substance.open(path, "r");
		//this.handle_temporary.open(path ~ ".temp", "r");
		this._path = path;
		this.get_digest();
		return this;
	}

	typeof(this) get_digest()
	{
		auto temp_file = File(this._path);
		hasher_murmur.start();
		foreach (chunk; temp_file.byChunk(4096))
		{
			hasher_murmur.put(chunk);
		}
		this.hash = hasher_murmur.finish();
		return this;
	}

	typeof(this) try_lock()
	{
		last_result = this.handle_substance.tryLock(LockType.readWrite);
		return this;
	}

	typeof(this) unlock()
	{
		this.handle_substance.unlock();
		return this;
	}
}

enum OpenModeFlags
{
	read = 1u << 0,
	write = 1u << 1,
	append = 1u << 2,
}

unittest
{
	import std.stdio : writefln;

	FileHandler file;
	file.open(__FILE__);
}
