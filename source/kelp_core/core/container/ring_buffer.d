module kelp_core.core.container.ring_buffer;

struct RingBuffer(Type, ubyte Length)
{
	Type[Length] data;
	private int index_first;
	private int index_last;
	private ubyte data_count;

	this(Type def_value)
	{
		data[0 .. $] = def_value;
		index_first = 0;
		index_last = 0;
		return;
	}

	bool is_empty() const pure nothrow @nogc @safe
	{
		return (data_count == false);
	}

	bool is_full() const pure nothrow @nogc @safe
	{
		return (data_count == Length);
	}

	ubyte count() const pure nothrow @nogc @safe
	{
		return data_count;
	}

	typeof(this) append(Type[] append_list) pure nothrow @safe
	in
	{
		assert(append_list.length <= Length);
	}
	do
	{
		int index_first_next;
		int first_half_length;
		if (index_first + append_list.length > Length)
		{
			index_first_next = cast(int)(index_first + append_list.length - Length);
			first_half_length = Length - index_first;
			// append
			data[index_first .. Length] = append_list[0 .. first_half_length];
			data[0 .. index_first_next] = append_list[first_half_length .. $];
		}
		else
		{
			index_first_next = cast(int)(index_first + append_list.length);
			// append
			data[index_first .. index_first_next] = append_list[0 .. $];
		}
		data_count += append_list.length;
		data_count = (data_count >= Length) ? Length : data_count;
		index_first = index_first_next;
		//this.data[(index_first - append_list.length) .. index_first] = append_list;
		return this;
	}

	typeof(this) remove(in size_t count) pure nothrow @safe
	{
		return this;
	}

	inout(Type) opIndex(size_t index) inout pure nothrow @nogc @safe
	in
	{
		assert(index < Length);
	}
	do
	{
		if (index_first + index < Length)
		{
			return this.data[index_first + index];
		}
		else
		{
			return this.data[index_first + index - Length];
		}
	}

	inout(Type[]) opSlice(size_t index_1, size_t index_2) inout pure nothrow @safe
	in
	{
		assert(index_1 < Length);
		assert(index_2 <= Length);
		assert(index_1 < index_2);
	}
	do
	{
		Type[] result_array;
		if (index_2 - index_1 < Length - index_first)
		{
			return data[index_1 + index_first .. index_2 + index_first];
		}
		else
		{
			return data[index_1 + index_first .. Length] ~ data[0 .. (
					index_2 - (Length - index_first))];
		}
	}
}

unittest
{
	import std.format;

	RingBuffer!(size_t, 5) ring;

	assert(ring.is_empty);
	assert(ring.count == 0);
	ring.append([1, 2, 3, 4, 5]);
	assert(ring.is_full);
	assert(ring.count == 5);
	assert(ring[0 .. 5] == [1, 2, 3, 4, 5]);
	ring.append([6, 7, 8]);
	assert(ring.count == 5);
	assert(ring[0 .. 5] == [4, 5, 6, 7, 8], format("%s", ring[0 .. 5]));
}
