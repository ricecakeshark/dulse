module kelp_core.math.linalg.vector;

import std.array;
import std.algorithm, std.math;
import std.range : zip;

alias Vec3 = Vector!(3, float);
alias Vec4 = Vector!(4, float);

struct Vector(size_t Length, Type = float)
{
	Type[Length] data;

	this(Type[Length] init_value...) const pure nothrow @nogc @safe
	{
		this.data = init_value;
		return;
	}

	Type norm() const pure nothrow @nogc @safe
	{
		return this.data[].map!(x => x.pow(2)).sum().sqrt();
	}

	typeof(this) unit() const pure nothrow @safe
	{
		return Vector!(Length)(
			this.data[].map!(x => x / this.norm())
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
	typeof(this) opBinary(string op : "*")(in Type scalar) const pure nothrow @nogc @safe
	{
		Vector!(Length, Type) temp_vec = Vector!(Length, Type)(this.data);
		static foreach (count; 0 .. Length)
		{
			temp_vec.data[count] *= scalar;
		}
		return temp_vec;
	}
	// Vector / 2.0
	typeof(this) opBinary(string op : "/")(in Type scalar) const pure nothrow @nogc @safe
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
	typeof(this) opBinary(string op : "+", size_t Length2, Type2)(in Vector!(Length2, Type2) rhs) const pure nothrow @nogc @safe
			if (Length2 == Length)
	{
		return add(this, rhs);
	}
	// Vector(Length) - Vector(Length)
	typeof(this) opBinary(string op : "-", size_t Length2, Type2)(in Vector!(Length2, Type2) rhs) const pure nothrow @nogc @safe
			if (Length2 == Length)
	{
		return subtract(this, rhs);
	}

	bool opEquals(V : Vector!(RhsLength, RhsType), size_t RhsLength, RhsType)(in V rhs) const pure nothrow @nogc @safe
			if (RhsLength == Length)
	{
		return zip(this.data[], rhs.data[]).all!(elm => isClose(elm[0], elm[1], 1e-10, 1e-10));
	}

	inout(Type) opIndex(in size_t index) inout pure nothrow @nogc @safe
	in (index < Length)
	{
		return this.data[index];
	}

	size_t toHash() const pure nothrow @nogc @safe
	{
		return sum(this.data[]).hashOf();
	}
}

Vector!(Length1, Type1) add(
V1 : Vector!(Length1, Type1), V2:
	Vector!(Length2, Type2),
	size_t Length1, Type1, size_t Length2, Type2
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe if (Length1 == Length2)
{
	return Vector!(Length1, Type1)(
		zip(lhs.data[], rhs.data[])
			.map!(elm => elm[0] + elm[1])
			.staticArray!(Type1[Length1])()
	);
}

Vector!(Length1, Type1) subtract(
V1 : Vector!(Length1, Type1), V2:
	Vector!(Length2, Type2),
	size_t Length1, Type1, size_t Length2, Type2
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe if (Length1 == Length2)
{
	return Vector!(Length1, Type1)(
		zip(lhs.data[], rhs.data[])
			.map!(elm => elm[0] - elm[1])
			.staticArray!(Type1[Length1])()
	);
}

/+Type1 innerProduct(
V1 : Vector!(2, Type1), V2:
	Vector!(2, Type2),
	Type1, Type2
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe
{
	return lhs[0] * rhs[0] + lhs[1] * rhs[1];
}+/

Type1 innerProduct(
V1 : Vector!(Length1, Type1), V2:
	Vector!(Length2, Type2),
	size_t Length1 : 2, Type1, size_t Length2 : 2, Type2
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe
{
	return lhs[0] * rhs[0] + lhs[1] * rhs[1];
}

Type1 innerProduct(
V1 : Vector!(Length1, Type1), V2:
	Vector!(Length2, Type2),
	size_t Length1 : 3, Type1, size_t Length2 : 3, Type2
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe
{
	return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2];
}

Vector!(3) crossProduct(
	V1 : Vector!(Length1, Type1),
	V2 : Vector!(Length2, Type2),
	size_t Length1 : 3, Type1, size_t Length2 : 3, Type2
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe
{
	return Vector!(3)(
		lhs[1] * rhs[2] - lhs[2] * rhs[1],
		lhs[2] * rhs[0] - lhs[0] * rhs[2],
		lhs[0] * rhs[1] - lhs[1] * rhs[0]
	);
}

unittest
{
	assert(Vec3(2.0, 3.0, 6.0).norm == 7.0);
	assert(Vec4(2.0, 2.0, 2.0, 2.0).unit == Vec4(0.5, 0.5, 0.5, 0.5));
	assert(Vec3(1.0, 2.0, 3.0) * 2.0 == Vec3(2.0, 4.0, 6.0));
	assert(Vec3(1.0, 2.0, 3.0) / 2.0 == Vec3(0.5, 1.0, 1.5));
	assert(Vec3(1.0, 2.0, 3.0) + Vec3(4.0, 5.0, 6.0) == Vec3(5.0, 7.0, 9.0));
	assert(Vec3(1.0, 2.0, 3.0) - Vec3(4.0, 5.0, 6.0) == Vec3(-3.0, -3.0, -3.0));

	assert(innerProduct(Vector!(2)(+1.0, +2.0), Vector!(2)(+3.0, +4.0)) == +11.0);
	assert(
		__traits(compiles, innerProduct(Vector!(2)(+1.0, +2.0), Vector!(3)(+1.0, +2.0, +3.0))) == false
	);

	assert(
		crossProduct(Vec3(1.0, 2.0, 3.0), Vec3(4.0, 5.0, 6.0)) == Vec3(-3.0, +6.0, -3.0)
	);

	//import std.stdio;
	//writeln();
}
