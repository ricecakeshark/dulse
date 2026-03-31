module kelp_core.graphics.loader.loader_obj;

import kelp_core.core;
import kelp_core.file;
import kelp_core.graphics;
import kelp_core.math;

import std.algorithm;
import std.array;
import std.stdio;
import std.format;
import std.exception;

void load_obj(
	FileHandler file,
	out GfxGeometry!(VertexPNU, uint) geometry
)
{
	scope string buf;
	scope Vec3[] temp_vertex_list;
	scope Vec3[] temp_normal_list;
	scope Vec2[] temp_uv_list;

	foreach (line; file.handle_substance.byLine())
	{

		if (line.startsWith("v "))
		{
			scope Vec3 temp_vertex;
			line.formattedRead!"%s %f %f %f"(
				buf,
				temp_vertex.data[0],
				temp_vertex.data[1],
				temp_vertex.data[2]);
			temp_vertex_list ~= temp_vertex;
			continue;
		}
		else if (line.startsWith("vn "))
		{
			scope Vec3 temp_normal;
			line.formattedRead!"%s %f %f %f"(
				buf,
				temp_normal.data[0],
				temp_normal.data[1],
				temp_normal.data[2],
			);
			temp_normal_list ~= temp_normal;
			continue;
		}
		else if (line.startsWith("vt "))
		{
			scope Vec2 temp_uv;
			line.formattedRead!"%s %f %f"(
				buf,
				temp_uv.data[0],
				temp_uv.data[1],
			);
			temp_uv_list ~= temp_uv;
			continue;
		}
		else if (line.startsWith("f "))
		{
			scope VertexPNU[] vertex_rectangle;

			foreach (element; line.split()[1 .. $])
			{
				scope VertexPNU temp_vertex;
				temp_vertex = VertexPNU.init;

				scope int v, v_uv, v_n;
				element.formattedRead!"%d/%d/%d"(v, v_uv, v_n);
				enforce(v >= 1 && v - 1 < temp_vertex_list.length);
				enforce(v_uv >= 1 && v_uv - 1 < temp_uv_list.length);
				enforce(v_n >= 1 && v_n - 1 < temp_normal_list.length);
				temp_vertex.pos = temp_vertex_list[v - 1];
				temp_vertex.normal = temp_normal_list[v_n - 1];
				temp_vertex.uv = temp_uv_list[v_uv - 1];
				vertex_rectangle ~= temp_vertex;
			}

			if (vertex_rectangle.length == 3)
			{
				geometry._index_list ~= 0u + cast(uint) geometry.count_vertex;
				geometry._index_list ~= 1u + cast(uint) geometry.count_vertex;
				geometry._index_list ~= 2u + cast(uint) geometry.count_vertex;
				geometry._vertex_list ~= vertex_rectangle.dup;
			}
			else if (vertex_rectangle.length == 4)
			{
				geometry._index_list ~= 0u + cast(uint) geometry.count_vertex;
				geometry._index_list ~= 1u + cast(uint) geometry.count_vertex;
				geometry._index_list ~= 2u + cast(uint) geometry.count_vertex;
				geometry._index_list ~= 2u + cast(uint) geometry.count_vertex;
				geometry._index_list ~= 3u + cast(uint) geometry.count_vertex;
				geometry._index_list ~= 0u + cast(uint) geometry.count_vertex;
				geometry._vertex_list ~= vertex_rectangle.dup;
			}
			else
			{
				enforce(false, "");
			}
			continue;
		}
	}
}
