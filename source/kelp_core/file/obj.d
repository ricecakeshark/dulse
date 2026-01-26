module kelp_core.file.obj;

import std.array;
import std.stdio;
import std.file;
import std.exception;
import kelp_core.graphics;
import kelp_core.math;

/+struct FileObj
{
	Vec3[] vertices;
	Vec2[] vertices_uv;


	typeof(this) open(string uri)
	{
		enforce(isFile(uri));
		string line;
		while((line = readln()) !is null)
		{
			string[] token_list;
			token_list = line.split();
			switch(token_list[0])
			{
				case "v":
				break;
				default:
				break;
			}
		}

	}
}+/
