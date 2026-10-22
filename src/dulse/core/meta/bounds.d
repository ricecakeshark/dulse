module dulse.core.meta.bounds;

size_t[] bounds(TypeList...)()
{
	scope size_t[] bounds_list = [0];
	static foreach (count; 1 .. TypeList.length)
	{
		static if (
			!is(TypeList[count - 1] == TypeList[count])
			)
		{
			bounds_list ~= count;
		}
	}
	bounds_list ~= TypeList.length;
	return bounds_list;
}

unittest
{
	assert(
		bounds!(int, int, string, string, float, float) == [0u, 2, 4, 6u]
	);
	import std.algorithm;
}
