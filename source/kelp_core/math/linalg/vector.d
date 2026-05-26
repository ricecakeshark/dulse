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

	this(Type[Length] init_value_list...) pure nothrow @nogc @safe
	{
		this.data = init_value_list;
		return;
	}

	this(Type init_value) pure nothrow @nogc @safe
	{
		this.data = init_value;
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

	typeof(this) unit() const pure nothrow @nogc @safe
	{
		Vector!(Length) return_vec;
		static foreach (i; 0 .. Length)
		{
			return_vec.data[i] = this[i] / this.norm();
		}
		return return_vec;
	}

	typeof(this) opUnary(string op : "+")() const pure nothrow @nogc @safe
	{
		return Vector!(Length, Type)(this.data[].map!(x => +x)
				.staticArray!(Type[Length]));
	}

	typeof(this) opUnary(string op : "-")() const pure nothrow @nogc @safe
	{
		return Vector!(Length, Type)(this.data[].map!(x => -x)
				.staticArray!(Type[Length]));
	}
	// Vector * 2.0
	typeof(this) opBinary(string op : "*")(in Type scalar) inout pure nothrow @nogc @safe
	{
		return multiply(this, scalar);
	}
	// Vector / 2.0
	typeof(this) opBinary(string op : "/")(in Type scalar) inout pure nothrow @nogc @safe
	{
		return devide(this, scalar);
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
		in Vector!(Length2, Type2) rhs) inout pure nothrow @nogc @safe
	if (Length2 == Length)
	{
		return add(this, rhs);
	}
	// Vector(Length) - Vector(Length)
	typeof(this) opBinary(string op : "-", size_t Length2, Type2)(
		in Vector!(Length2, Type2) rhs) inout pure nothrow @nogc @safe
	if (Length2 == Length)
	{
		return subtract(this, rhs);
	}
	// return Vector * Vector
	typeof(this) opBinary(string op : "*", size_t Length2, Type2)(
		in Vector!(Length2, Type2) rhs
	) inout pure nothrow @nogc @safe
	if (Length2 == Length)
	{
		return cross_product(this, rhs);
	}
	// return Matrix * Vector
	typeof(this) opBinaryRight(string op : "*", M:
		Matrix!(Row, Col, MatT), size_t Row, size_t Col, MatT)(M mat) inout pure nothrow @nogc @safe
	{
		return kelp_core.math.linalg.multiply.multiply!(Matrix!(Row, Col, MatT), Vector!(Length, Type))(mat, this);
	}

	bool opEquals(V : Vector!(RhsLength, RhsType), size_t RhsLength, RhsType)(in V rhs) const pure nothrow @nogc @safe
	if (RhsLength == Length)
	{
		//return zip(this.data[], rhs.data[]).all!(elm => isClose(elm[0], elm[1], 1e-5, 1e-5));
		return approxEqual(this, rhs);
	}

	ref inout(Type) opIndex(in size_t index) inout pure nothrow @nogc @safe
	in (index < Length)
	{
		return this.data[index];
	}

	static if (1 <= Length)
	{
		ref inout(Type) x() inout pure nothrow @nogc @safe
		in (0 < Length)
		{
			return this.data[0];
		}
	}

	static if (2 <= Length)
	{
		ref inout(Type) y() inout pure nothrow @nogc @safe
		in (1 < Length)
		{
			return this.data[1];
		}
	}

	static if (3 <= Length)
	{
		ref inout(Type) z() inout pure nothrow @nogc @safe
		in (2 < Length)
		{
			return this.data[2];
		}
	}

	static if (4 <= Length)
	{
		ref inout(Type) w() inout pure nothrow @nogc @safe
		in (3 < Length)
		{
			return this.data[3];
		}
	}

	size_t toHash() const pure nothrow @nogc @safe
	{
		return hashOf(this.data[]);
	}

	CastType opCast(CastType : Type[Length])() inout pure nothrow @nogc @safe
	{
		return this.data;
	}

	string opCast(R : string)() const pure @safe
	{
		return to_string();
	}

	string to_string() const pure @safe
	{
		import std.format;

		string result_str;
		foreach (count; 0 .. Length)
		{
			result_str ~= format(" %2d [%2.2f]\n", count, this[count]);
		}
		return result_str;
	}

	R opCast(R : Matrix!(Length, Length, Type))() inout pure nothrow @nogc @safe
	{
		R temp_matrix = Matrix!(Length, Length, Type);
		foreach (count; 0 .. Length)
		{
			temp_matrix.data[count][count] = this.data[count];
		}
		return temp_matrix;
	}

	Vector!(DstLength, Type) extend(size_t DstLength)() const pure nothrow @nogc @safe
	{
		Vector!(DstLength, Type) ret_vec;
		foreach (index; 0 .. Length)
		{
			ret_vec.data[index] = this[index];
		}
		return ret_vec;
	}

	Matrix!(Length, Length, Type) to_matrix_scale()() inout pure nothrow @nogc @safe
	{
		Matrix!(Length, Length, Type) temp_matrix;
		temp_matrix.indentify();
		foreach (count; 0 .. Length)
		{
			temp_matrix.data[count][count] = this.data[count];
		}
		return temp_matrix;
	}

	Matrix!(Length, Length, Type) to_matrix_transport()() inout pure nothrow @nogc @safe
	{
		Matrix!(Length, Length, Type) temp_matrix;
		temp_matrix = matrix_identity();
		foreach (count; 0 .. Length)
		{
			temp_matrix.data[count][$ - 1u] = this.data[count];
		}
		return temp_matrix;
	}
}

bool approxEqual(
V1 : Vector!(Length, LhsType),
V2:
	Vector!(Length, RhsType),
	size_t Length, LhsType, RhsType,
)(
	in V1 lhs, in V2 rhs
) pure nothrow @nogc @safe
{
	static if (is(LhsType == float) && is(RhsType == float))
	{
		return zip(lhs.data[], rhs.data[]).all!(elm => isClose(elm[0], elm[1], 1e-5, 1e-5));
	}
	else
	{
		return zip(lhs.data[], rhs.data[]).all!(elm => isClose(elm[0], elm[1], 1e-10, 1e-10));
	}
}
// vec + vec
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
// vec - vec
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
// vec(x, y)・vec(x, y)
Type1 inner_product(
V1 : Vector!(Length1, Type1), V2:
	Vector!(Length2, Type2),
	size_t Length1 : 2, Type1, size_t Length2 : 2, Type2
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe
{
	return lhs[0] * rhs[0] + lhs[1] * rhs[1];
}
// vec(x, y, z)・vec(x, y, z)
Type1 inner_product(
V1 : Vector!(Length1, Type1), V2:
	Vector!(Length2, Type2),
	size_t Length1 : 3, Type1, size_t Length2 : 3, Type2
)(in V1 lhs, in V2 rhs) pure nothrow @nogc @safe
{
	return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2];
}
// vec(x, y, z) × vec(x, y, z)
Vector!(3) cross_product(
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
	Vec3 vec_test = Vec3(1.0f);
	assert(vec_test.x == 1.0f && vec_test.y == 1.0f && vec_test.z == 1.0f);

	assert(Vec3(2.0, 3.0, 6.0).norm == 7.0);
	assert(Vec4(2.0, 2.0, 2.0, 2.0).unit == Vec4(0.5, 0.5, 0.5, 0.5));
	assert(Vec3(1.0, 2.0, 3.0) * 2.0 == Vec3(2.0, 4.0, 6.0));
	assert(Vec3(1.0, 2.0, 3.0) / 2.0 == Vec3(0.5, 1.0, 1.5));
	assert(Vec3(1.0, 2.0, 3.0) + Vec3(4.0, 5.0, 6.0) == Vec3(5.0, 7.0, 9.0));
	assert(Vec3(1.0, 2.0, 3.0) - Vec3(4.0, 5.0, 6.0) == Vec3(-3.0, -3.0, -3.0));

	assert(inner_product(Vector!(2)(+1.0, +2.0), Vector!(2)(+3.0, +4.0)) == +11.0);
	assert(
		__traits(compiles, inner_product(Vector!(2)(+1.0, +2.0), Vector!(3)(+1.0, +2.0, +3.0))) == false
	);

	assert(
		cross_product(Vec3(1.0, 2.0, 3.0), Vec3(4.0, 5.0, 6.0)) == Vec3(-3.0, +6.0, -3.0)
	);
}
// Vector * 2.0
Vector!(Length, Type) multiply(size_t Length, Type)(
	in Vector!(Length, Type) vec,
	in Type scalar,
) pure nothrow @nogc @safe
{
	Vector!(Length, Type) temp_vec;
	static foreach (count; 0 .. Length)
	{
		temp_vec[count] = vec[count] * scalar;
	}
	return temp_vec;
}
// Vector / 2.0
Vector!(Length, Type) devide(size_t Length, Type)(
	in Vector!(Length, Type) vec,
	in Type scalar,
) pure nothrow @nogc @safe
{
	Vector!(Length, Type) temp_vec;
	static foreach (count; 0 .. Length)
	{
		temp_vec[count] = vec[count] / scalar;
	}
	return temp_vec;
}
