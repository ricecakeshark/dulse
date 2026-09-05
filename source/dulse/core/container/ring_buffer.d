module dulse.core.container.ring_buffer;

import std.algorithm : reverse;

struct RingBuffer(Type, size_t Length)
{
	private Type[Length] data;
	private size_t index_first;
	private size_t _count;

	this(Type init_value)
	{
		this.data[] = init_value;
		this.index_first = 0;
		this._count = 0;
		return;
	}

	invariant
	{
		static assert(Length > 0);
		assert(this.index_first < Length);
		assert(this._count <= Length);
	}

	bool is_empty() const pure nothrow @nogc @safe
	{
		return (this._count == 0);
	}

	bool is_full() const pure nothrow @nogc @safe
	{
		return (this._count == Length);
	}

	size_t index_head() const pure nothrow @nogc @safe
	in (!this.is_empty)
	{
		return this.index_first;
	}

	size_t index_tail() const pure nothrow @nogc @safe
	in (!this.is_empty)
	{
		return (this.index_first + this._count - 1) % Length;
	}

	size_t count() pure nothrow @nogc @safe
	{
		return this._count;
	}

	@property ref inout(Type) head() inout pure nothrow @nogc @safe
	in (!this.is_empty)
	{
		return this.data[this.index_first];
	}

	@property ref inout(Type) tail() inout pure nothrow @nogc @safe
	in (!this.is_empty)
	{
		return this.data[this.index_tail];
	}

	ref inout(Type) index(size_t _index) inout pure nothrow @nogc @safe
	in (_index < this._count)
	{
		return this.data[(this.index_first + _index) % Length];
	}

	size_t opDollar() pure nothrow @nogc @safe
	{
		return this._count;
	}

	ref inout(Type) opIndex(in size_t index) inout pure nothrow @nogc @safe
	in (index < this._count)
	{
		return this.data[(this.index_first + index) % Length];
	}

	Type[] opSlice(
		in size_t index_1, in size_t index_2
	) pure @safe
	in
	{
		import std.format;

		assert(index_1 <= index_2);
		assert(index_2 <= this._count, format("[%s, %s]", index_1, index_2));
	}
	do
	{
		const size_t refer_first = (this.index_first + index_1) % Length;
		const size_t _total_len = index_2 - index_1;
		const size_t refer_len_1 = (_total_len < Length - refer_first)
			? _total_len : Length - refer_first;
		const size_t refer_len_2 = _total_len - refer_len_1;
		return this.data[refer_first .. refer_first + refer_len_1]
			~ this.data[0 .. refer_len_2];
	}

	Type[] opSlice() pure @safe
	{
		return this.opSlice(0, this._count);
	}

	ref typeof(this) clear() return pure nothrow @safe
	{
		this.data[] = Type.init;
		this.index_first = 0;
		this._count = 0;
		return this;
	}

	ref typeof(this) fill() return pure nothrow @safe
	{
		this.data[] = Type.init;
		this.index_first = 0;
		this._count = Length;
		return this;
	}

	ref typeof(this) append(Type[] append_list...) return pure nothrow @safe
	in (append_list.length <= Length)
	{
		if (append_list.length == 0)
		{
			return this;
		}
		//const size_t write_first = this.index_tail;
		const size_t write_first = (this.index_first + this._count) % Length;
		//write_last = actual_index(this.count + append_list.length);
		const size_t write_length_1 = (+append_list.length < Length - write_first)
			? append_list.length : Length - write_first;
		const size_t write_length_2 = append_list.length - write_length_1;
		const size_t _total_count = this._count + append_list.length;
		const size_t _overwrite = _total_count > Length ? _total_count - Length : 0;
		// insert data 
		this.data[write_first .. write_first + write_length_1] = append_list[0 .. write_length_1];
		this.data[0 .. write_length_2] = append_list[write_length_1 .. $];
		// arrange index, count
		this.index_first = (index_first + _overwrite) % Length;
		this._count = (_total_count > Length) ? Length : _total_count;
		return this;
	}

	ref typeof(this) prepend(Type[] append_list...) return pure nothrow @safe
	in (append_list.length <= Length)
	{
		if (append_list.length == 0)
		{
			return this;
		}
		const size_t write_first = (this.index_first + Length - append_list.length) % Length;
		//append_length = append_list.length;
		const size_t write_length_1 = (append_list.length < Length - write_first)
			? append_list.length : Length - write_first;
		const size_t write_length_2 = append_list.length - write_length_1;
		// insert data 
		this.data[write_first .. write_first + write_length_1]
			= append_list[0 .. write_length_1];
		this.data[0 .. write_length_2]
			= append_list[write_length_1 .. $];
		// arrange index, count
		index_first = write_first;
		_count = (this._count + append_list.length > Length)
			? Length : this._count + append_list.length;
		return this;
	}

protected:
	typeof(this.index_first) actual_index(in long _index) const pure nothrow @nogc @safe
	{
		return normalize(this.index_first + _index, Length);
	}
}

long normalize(long value, long limit) pure nothrow @nogc @safe
{
	return (value % limit + limit) % limit;
}

alias RingQueue = RingBuffer;

unittest
{
	import std.format;

	RingBuffer!(int, 5) ring;
	ring.clear();
	assert(ring.count == 0);
	assert(ring.is_empty && !ring.is_full);
	ring.append([1, 2, 3]);
	assert(ring.index_head == 0, format("%s", ring.index_head));
	assert(ring.index_tail == 2, format("%s", ring.index_tail));
	assert(ring.count == 3);
	assert(ring[0 .. $] == [1, 2, 3] /+, format("%s", ring[])+/ );
	assert(!ring.is_empty && !ring.is_full);
	ring.append([4, 5, 6]);
	assert(ring[0 .. $] == [2, 3, 4, 5, 6], format("%s", ring[0 .. $]));
	assert(ring.count == 5);
	assert(!ring.is_empty && ring.is_full);
	ring.append([7, 8,]);
	assert(ring[0 .. $] == [4, 5, 6, 7, 8], format("%s", ring[0 .. $]));

	RingBuffer!(int, 5) ring_2;
	ring_2.prepend([1, 2, 3]);
	assert(ring_2[0 .. $] == [1, 2, 3], format("%s", ring_2[0 .. $]));
	ring_2.prepend([4, 5, 6]);
	assert(ring_2[0 .. $] == [4, 5, 6, 1, 2,], format("%s", ring_2[0 .. $]));
	ring_2.prepend([7, 8,]);
	assert(ring_2[0 .. $] == [7, 8, 4, 5, 6,], format("%s", ring_2[0 .. $]));
}
