module kelp_core.math.linalg.vector;

import std.array;
import std.algorithm, std.math;
import std.range : zip;

alias Vec3 = Vector!(3);
alias Vec4 = Vector!(4);

struct Vector(size_t Length, Type = float)
{
	Type[Length] data;

	this(Type[Length] init_value...) const pure nothrow @nogc @safe
	{
		this.data = init_value;
		return;
	}

	@property Type norm() const pure nothrow @nogc @safe
	{
		return this.data[].map!(x => x.pow(2)).sum().sqrt();
	}

	typeof(this) unit() const pure nothrow @safe
	{
		return Vector!(Length)(
			this.data[].map!(x => x / this.norm)()
				.staticArray!(Length)()
		);
	}

	typeof(this) opUnary(string op : "+")() const pure nothrow @nogc @safe
	{
		return Vector!(Length)(this.data[].map!(x => +x).staticArray());
	}

	typeof(this) opUnary(string op : "-")() const pure nothrow @nogc @safe
	{
		return Vector!(Length)(this.data[].map!(x => -x).staticArray());
	}
	// Vector * 2.0
	typeof(this) opBinary(string op : "*")(const(Type) scalar) const pure nothrow @nogc @safe
	{
		Vector!(Length, Type) temp_vec = Vector!(Length, Type)(this.data);
		static foreach (count; 0 .. Length)
		{
			temp_vec.data[count] *= scalar;
		}
		return temp_vec;
	}
	/+
	typeof(this) opBinary(string op : "*")(const(Type) scalar) const pure nothrow @safe
	{
		return Vector!(Length)(
			this.data[].map!(x => x * scalar)
				.staticArray!(Type[Length])
		);
	}
	+/
	// Vector / 2.0
	typeof(this) opBinary(string op : "/")(const(Type) scalar) const pure nothrow @nogc @safe
	{
		Vector!(Length, Type) temp_vec = Vector!(Length, Type)(this.data);
		static foreach (count; 0 .. Length)
		{
			temp_vec.data[count] /= scalar;
		}
		return temp_vec;
	}
	/+
	typeof(this) opBinary(string op : "/")(const double scalar) const pure nothrow @nogc @safe
	{
		return Vector!(Length)(
			this.data[].map!(x => x / scalar)
				.staticArray!(Type[Length])
		);
	}+/
	// Vector(Length) + Vector(Length)
	typeof(this) opBinary(string op : "+")(typeof(this) rhs) const pure nothrow @nogc @safe
	{
		return Vector!(Length)(
			zip(this.data[], rhs.data[])
				.map!(elm => elm[0] + elm[1])
				.staticArray!(Type[Length])
		);
	}
	// Vector(Length) - Vector(Length)
	typeof(this) opBinary(string op : "-")(typeof(this) rhs) const pure nothrow @nogc @safe
	{
		return Vector!(Length)(
			zip(this.data[], rhs.data[])
				.map!(elm => elm[0] - elm[1])
				.staticArray!(Type[Length])
		);
	}

	bool opEquals(const typeof(this) rhs) const pure nothrow @nogc @safe
	{
		return zip(this.data[], rhs.data[]).all!(elm => isClose(elm[0], elm[1], 1e-10, 1e-10));
	}

	inout(Type) opIndex(size_t index) inout pure nothrow @nogc @safe
	in (index < Length)
	{
		return this.data[index];
	}

	size_t toHash() const pure nothrow @nogc @safe
	{
		return sum(this.data[]).hashOf();
	}
}

unittest
{
	assert(Vec3(2.0, 3.0, 6.0).norm == 7.0);
	assert(Vec4(2.0, 2.0, 2.0, 2.0).unit == Vec4(0.5, 0.5, 0.5, 0.5));
	assert(Vec3(1.0, 2.0, 3.0) * 2.0 == Vec3(2.0, 4.0, 6.0));
	assert(Vec3(1.0, 2.0, 3.0) / 2.0 == Vec3(0.5, 1.0, 1.5));
	assert(Vec3(1.0, 2.0, 3.0) + Vec3(4.0, 5.0, 6.0) == Vec3(5.0, 7.0, 9.0));
	assert(Vec3(1.0, 2.0, 3.0) - Vec3(4.0, 5.0, 6.0) == Vec3(-3.0, -3.0, -3.0));
}
