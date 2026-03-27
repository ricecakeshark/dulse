module kelp_core.graphics.loader.loader_obj;

import kelp_core.core;
import kelp_core.file;
import kelp_core.graphics;
import kelp_core.math;

import std.algorithm;
import std.array;
import std.stdio;
import std.format;
import std.random;

void load_obj(
	FileHandler file,
	out GfxGeometry!(VertexPC, uint) geometry
)
{
	string buf;

	foreach (line; file.handle_substance.byLine())
	{

		if (line.startsWith("v "))
		{
			VertexPC temp_vertex;
			temp_vertex = VertexPC.init;
			line.formattedRead!"%s %f %f %f"(
				buf, temp_vertex.pos.data[0], temp_vertex.pos.data[1], temp_vertex
					.pos.data[2]);
			temp_vertex.color = ColorF(uniform(0.1,0.9), uniform(0.1,0.9), uniform(0.1,0.9));
			geometry._vertex_list ~= temp_vertex;
			continue;
		}
		if (line.startsWith("f "))
		{
			scope uint[] index_buf;
			index_buf = [];
			foreach (element; line.split()[1 .. $])
			{
				scope int[3] read_buf;

				element.formattedRead!"%d/%d/%d"(read_buf[0], read_buf[1], read_buf[2]);
				index_buf ~= cast(uint) read_buf[0] - 1;
			}
			geometry._index_list ~= [index_buf[0], index_buf[1], index_buf[2]].dup;
			geometry._index_list ~= [index_buf[2], index_buf[3], index_buf[0]].dup;
			continue;
		}
	}
}
