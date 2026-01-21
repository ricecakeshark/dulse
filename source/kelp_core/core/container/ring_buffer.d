module kelp_core.core.container.ring_buffer;

import std.algorithm : reverse;

// Queue (FIFO)
struct RingQueue(Type, ubyte Length)
{
	RingBuffer!(Type, Length) buffer;
	//Type[Length] buffer;
	int index_first, index_last;
	ubyte data_count;

	this(Type init_value)
	{
		this.index_first = Length;
		this.index_last = Length;
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

	size_t opDollar() const pure nothrow @nogc @safe
	{
		return cast(size_t) this.index_last;
	}

	inout(Type) opIndex(size_t index) inout pure nothrow @nogc @safe
	{
		return this.buffer[index];
	}

	typeof(this) append(Type[] append_list...)
	{
		this.buffer.append_first(append_list);
		return this;
	}
}
// Stack (LIFO)
struct RingStack(Type, ubyte Length)
{
	Type[Length] buffer;
	int index_first, index_last;
	ubyte data_count;

	this(ubyte init_index)
	{
		this.index_first = init_index;
		this.index_last = init_index;
		return;
	}

	typeof(this) append(Type[] append_list...)
	{
		this.buffer.append_last(append_list);
		return this;
	}
}

struct RingBuffer(Type, ubyte Length)
{
	Type[Length] data;
	int index_first, index_last;
	size_t _count;

	this(Type init_value)
	{
		this.data[] = init_value;
		index_first = 0;
		index_last = 0;
		return;
	}

	bool is_empty() const pure nothrow @nogc @safe
	{
		return (this._count == 0);
	}

	bool is_full() const pure nothrow @nogc @safe
	{
		return (this._count == Length);
	}

	inout(size_t) count() inout pure nothrow @nogc @safe
	{
		return this._count;
	}

	inout(size_t) opDollar() inout pure nothrow @nogc @safe
	{
		return cast(size_t) this._count;
	}

	inout(Type) opIndex(in size_t index_refer) inout pure nothrow @nogc @safe
	in
	{
		assert(index_refer < Length);
		assert(index_refer < this._count);
	}
	do
	{
		if (index_first + index_refer < Length)
		{
			return this.data[index_first + index_refer];
		}
		else
		{
			return this.data[index_first + index_refer - Length];
		}
	}

	inout(Type[]) opSlice(in size_t index_1, in size_t index_2) inout pure @safe
	in
	{
		import std.format;

		assert(index_1 < Length);
		assert(index_2 <= Length);
		assert(index_1 <= index_2, format("%s,%s", index_1, index_2));
	}
	do
	{
		size_t refer_first, refer_len;
		refer_first = (index_first + index_1) % Length;
		refer_len = index_2 - index_1;
		if (refer_first + refer_len > Length)
		{
			return data[refer_first .. Length] ~ data[0 .. (refer_first + refer_len - Length)];
		}
		else
		{
			return data[refer_first .. refer_first + refer_len];
		}
	}

	typeof(this) clear() pure nothrow @safe
	{
		this.data[] = Type.init;
		index_first = 0;
		index_last = 0;
		return this;
	}

	typeof(this) append_first(Type[] append_list...) pure nothrow @safe
	in
	{

	}
	do
	{
		int append_first, append_last, appned_length;
		append_first = this.index_first - cast(int) append_list.length;
		append_last = this.index_first;

		if (append_first >= 0)
		{
			// single
			this.data[append_first .. append_last] = append_list[];
			index_first = append_first;
		}
		else
		{
			// split
			append_first += Length;
			this.data[0 .. append_last] = append_list[$ - (index_first) .. $];
			this.data[append_first .. $] = append_list[0 .. $ - (index_first)];
			index_first = index_first + cast(int) Length - cast(int) append_list.length;
		}
		_count = (_count + append_list.length > Length) ? Length : _count + append_list.length;

		return this;
	}

	typeof(this) append_last(Type[] append_list...) pure nothrow @safe
	in
	{

	}
	do
	{
		int append_first, append_last;
		append_first = this.index_last;
		append_last = (this.index_last + cast(int) append_list.length);

		if (append_last <= Length)
		{
			this.data[append_first .. append_last] = append_list[];
		}
		else
		{
			append_last = append_last - Length;
			// split
			this.data[append_first .. $] = append_list[0 .. (Length - append_first)];
			this.data[0 .. append_last] = append_list[(Length - append_first) .. $];
		}
		if (_count + append_list.length > Length)
		{
			_count = Length;
			index_first = append_last;
		}
		else
		{
			_count += append_list.length;
		}
		/+if(append_first <= index_first && index_first<append_last)
		{
			index_first = append_last;
		}+/
		index_last = append_last;

		return this;
	}
}

unittest
{
	import std.format;

	RingBuffer!(int, 5) ring;
	ring.clear();
	assert(ring.is_empty);
	assert(ring.count == 0);
	ring.append_first([1, 2, 3]);
	assert(ring[0 .. $] == [1, 2, 3]);
	assert(ring.count == 3);
	ring.append_first([4, 5]);
	assert(ring[0 .. $] == [4, 5, 1, 2, 3], format("%s", ring[0 .. $]));
	assert(ring.is_full);
	assert(ring.count == 5);
	ring.append_first([6, 7, 8]);
	assert(ring[0 .. $] == [6, 7, 8, 4, 5], format("%s", ring[0 .. $]));
	assert(ring.count == 5);

	RingBuffer!(int, 5) ring_2;
	ring_2.append_last([1, 2, 3]);
	assert(ring_2[0 .. $] == [1, 2, 3], format("%s", ring_2[0 .. $]));
	ring_2.append_last([4, 5]);
	assert(ring_2[0 .. $] == [1, 2, 3, 4, 5], format("%s", ring_2[0 .. $]));

}
