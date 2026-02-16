module kelp_core.file.file;

import std.digest;
import std.digest.murmurhash;
import std.file;
import std.exception;
import std.range;
import std.stdio;

//import std.string;

static MurmurHash3!(128, 64) hasher_murmur;

struct FileHandler
{
	string path;
	ubyte[16] hash;
	std.stdio.File handle_substance;
	std.stdio.File handle_temporary;

	this(string path)
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

	typeof(this) open(string path)
	{
		enforce(path.exists);
		enforce(path.isFile);
		this.handle_substance.open(path, "r");
		//this.handle_temporary.open(path ~ ".temp", "r");
		this.path = path;
		this.get_digest();
		return this;
	}

	typeof(this) get_digest()
	{
		auto temp_file = std.stdio.File(this.path);
		hasher_murmur.start();
		foreach (chunk; temp_file.byChunk(4096))
		{
			hasher_murmur.put(chunk);
		}
		this.hash = hasher_murmur.finish();
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
