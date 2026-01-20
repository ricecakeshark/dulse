module kelp_core.math.linalg.vector;

import kelp_core.math.linalg;
import std.array;
import std.algorithm, std.math, std.range;
import std.range : zip;

alias Vec1 = Vector!(1, float);
alias Vec2 = Vector!(2, float);
alias Vec3 = Vector!(3, float);
alias Vec4 = Vector!(4, float);

struct Vector(size_t Length, Type = float)
{
	Type[Length] data;

	this(Type[Length] init_value_list...) const pure nothrow @nogc @safe
	{
		this.data = init_value_list;
		return;
	}

	Type[Length] opAssign(in Type[Length] assign_array) pure nothrow @safe
	in
	{
		assert(iota(0, Length).all!(i => assign_array[i].isNaN == false)());
	}
	do
	{
		this.data = assign_array;
		return assign_array;
	}

	Type norm() const pure nothrow @nogc @safe
	{
		return this.data[].map!(x => x.pow(2)).sum().sqrt();
	}

	typeof(this) unit() const pure nothrow @safe
	{
		Vector!(Length) return_vec;
		static foreach (i; 0 .. Length)
		{
			return_vec.data[i] = this[i] / this.norm();
		}
		return return_vec;
		// cannot @nogc
		/+return Vector!(Length)(
			this.data[].map!(x => x / this.norm())
				.staticArray!(Length)()
		);+/
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
	typeof(this) opBinary(string op : "+", size_t Length2, Type2)(
		in Vector!(Length2, Type2) rhs) const pure nothrow @nogc @safe
	if (Length2 == Length)
	{
		return add(this, rhs);
	}
	// Vector(Length) - Vector(Length)
	typeof(this) opBinary(string op : "-", size_t Length2, Type2)(
		in Vector!(Length2, Type2) rhs) const pure nothrow @nogc @safe
	if (Length2 == Length)
	{
		return subtract(this, rhs);
	}
	// return Vector * Vector
	typeof(this) opBinary(string op : "*", size_t Length2, Type2)(
		in Vector!(Length2, Type2) rhs
	) const pure nothrow @nogc @safe
	if (Length2 == Length)
	{
		return crossProduct(this, rhs);
	}
	// return Matrix * Vector
	typeof(this) opBinaryRight(string op : "*", M:
		Matrix!(Row, Col, Type), size_t Row, size_t Col)(in M mat) const pure nothrow @nogc @safe
	{
		return multiply(mat, this);
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

	string opCast(R : string)() const pure @safe
	{
		import std.format;

		string result_str;
		foreach (count; 0 .. Length)
		{
			result_str ~= format(" %2d [%2.2f]\n", count, this[count]);
		}
		return result_str;
	}

	R opCast(R : Matrix!(Length, Length, Type))() const pure nothrow @safe
	{
		R temp_matrix = Matrix!(Length, Length, Type);
		foreach (count; 0 .. Length)
		{
			temp_matrix.data[count][count] = this.data[count];
		}
		return temp_matrix;
	}
}

Vector!(Length1, Type1) add(
V1 : Vector!(Length1, Type1), V2:
	Vector!(Length2, Type2),
	size_t Length1, Type1, size_t Length2, Type2
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe
if (Length1 == Length2)
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
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe
if (Length1 == Length2)
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
V2:
	Vector!(Length2, Type2),
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
