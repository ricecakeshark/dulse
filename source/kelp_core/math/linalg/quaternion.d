module kelp_core.math.linalg.quaternion;

import kelp_core.math.linalg;
import std.math;
import std.conv : text;

struct Quaternion(Type = float)
{
	Type[4] data;

	this(in Type[3] xyzw...) pure nothrow @nogc @safe
	{
		static foreach (index; 0 .. 3)
		{
			this.opIndex(index) = xyz[index];
		}
		this.opIndex(3) = 1.0f;
		return;
	}

	this(in Vector!(3, Type) vec) pure nothrow @nogc @safe
	{
		static foreach (index; 0 .. 3)
		{
			this.opIndex(index) = vec[index];
		}
		this.opIndex(3) = 0.0f;
		return;
	}

	this(in Type[4] xyzw...) pure nothrow @nogc @safe
	{
		static foreach (index; 0 .. 4)
		{
			this.opIndex(index) = xyzw[index];
		}
		return;
	}

	this(in Vector!(3, Type) axis, in Type angle) pure nothrow @nogc @safe
	{
		if (axis.norm == Type(0.0))
		{
			this.identify();
			return;
		}
		static foreach (index; 0 .. 3)
		{
			this.opIndex(index) = axis.unit[index] * sin(angle / 2);
		}
		this.opIndex(3) = cos(angle / 2);
		return;
	}

	@property ref inout(Type) x() inout pure nothrow @nogc @safe
	{
		return this.data[0];
	}

	@property ref inout(Type) y() inout pure nothrow @nogc @safe
	{
		return this.data[1];
	}

	@property ref inout(Type) z() inout pure nothrow @nogc @safe
	{
		return this.data[2];
	}

	@property ref inout(Type) w() inout pure nothrow @nogc @safe
	{
		return this.data[3];
	}

	@property ref inout(Type[3]) xyz() inout pure nothrow @nogc @safe
	{
		return this.data[0 .. 3];
	}

	@property ref inout(Type[4]) xyzw() inout pure nothrow @nogc @safe
	{
		return this.data;
	}

	@property Type norm() const pure nothrow @nogc @safe
	{
		return sqrt(this[0].pow(2) + this[1].pow(2) + this[2].pow(2) + this[3].pow(2));
	}

	@property Quaternion!Type unit() const pure nothrow @nogc @safe
	{
		return devide(this, this.norm);
	}

	@property Quaternion!Type conjugate() const pure nothrow @nogc @safe
	{
		return Quaternion!Type(-this.x, -this.y, -this.z, +this.w);
	}

	@property Quaternion!Type inverse() const pure nothrow @nogc @safe
	{
		return this.conjugate / (this.norm * this.norm);
	}

	bool opEquals(RhsType)(in Quaternion!RhsType rhs) const pure nothrow @nogc @safe
	{
		return equal(this, rhs);
	}

	ref inout(Type) opIndex(size_t index) inout pure nothrow @nogc @safe
	{
		return this.data[index];
	}

	typeof(this) opUnary(string op)() const pure nothrow @nogc @safe
	{
		static if (op == "+")
		{
			return Quaternion!Type(+this.x, +this.y, +this.z, +this.w);
		}
		else static if (op == "-")
		{
			return Quaternion!Type(-this.x, -this.y, -this.z, -this.w);
		}
	}

	typeof(this) opBinary(string op : "+")(in Quaternion!Type rhs) const pure nothrow @nogc @safe
	{
		return add(this, rhs);
	}

	typeof(this) opBinary(string op : "-")(in Quaternion!Type rhs) const pure nothrow @nogc @safe
	{
		return subtract(this, rhs);
	}

	typeof(this) opBinary(string op : "*")(in Quaternion!Type rhs) const pure nothrow @nogc @safe
	{
		return multiply(this, rhs);
	}

	typeof(this) opBinary(string op : "*")(in Type rhs) const pure nothrow @nogc @safe
	{
		return multiply(this, rhs);
	}
	// 
	typeof(this) opBinary(string op : "*")(in Vector!(4, Type) vec) const pure nothrow @nogc @safe
	{
		return vec.rotate_by(this);
	}

	typeof(this) opBinary(string op : "/")(in Type rhs) const pure nothrow @nogc @safe
	{
		return devide(this, rhs);
	}

	size_t toHash() const pure nothrow @nogc @safe
	{
		return hashOf(this.data);
	}

	static Quaternion!Type identity(Type)() const pure nothrow @nogc @safe
	{
		return Quaternion!Type(0.0f, 0.0f, 0.0f, 1.0f);
	}

	typeof(this) identify() pure nothrow @nogc @safe
	{
		this.x = 0.0f;
		this.y = 0.0f;
		this.z = 0.0f;
		this.w = 1.0f;
		return this;
	}

	Vector!(3, Type) opCast(T : Vector!(3, Type))() const pure nothrow @nogc @safe
	{
		return this.to_vec();
	}

	Vector!(3, Type) to_vec() const pure nothrow @nogc @safe
	{
		return Vector!(3, Type)(this.x, this.y, this.z);
	}

	Matrix!(3, 3, Type) to_matrix() const pure nothrow @nogc @safe
	{
		return Matrix!(3, 3, Type)(
			[
			[
				this.x * this.x - this.y * this.y - this.z * this.z + this.w * this.w,
				Type(2.0) * (this.x * this.y - this.z * this.w),
				Type(2.0) * (this.x * this.z + this.y * this.w),
			],
			[
				Type(2.0) * (this.x * this.y + this.z * this.w),
				-this.x * this.x + this.y * this.y - this.z * this.z + this.w * this.w,
				Type(2.0) * (this.y * this.z - this.x * this.w),
			],
			[
				Type(2.0) * (this.x * this.z - this.y * this.w),
				Type(2.0) * (this.y * this.z + this.x * this.w),
				-this.x * this.x - this.y * this.y + this.z * this.z + this.w * this.w,

			

		]]
		);
	}

	string to_string() const pure @safe
	{
		return text("(x,y,z,w): (", this.x, ", ", this.y, ", ", this.z, ", ", this.w, ")");
	}

	string to_string_raw() const pure @safe
	{
		return text("float[4]: (", this, ")");
	}
}

bool equal(
Q1 : Quaternion!LhsType,
Q2:
	Quaternion!RhsType,
	LhsType,
	RhsType,
)(
	in Q1 quat_lhs,
	in Q2 quat_rhs,
) pure nothrow @nogc @safe
{
	static if (is(LhsType == float) && is(RhsType == float))
	{
		return isClose(quat_lhs.x, quat_rhs.x, 1e-5, 1e-5)
			&& isClose(quat_lhs.y, quat_rhs.y, 1e-5, 1e-5)
			&& isClose(quat_lhs.z, quat_rhs.z, 1e-5, 1e-5)
			&& isClose(quat_lhs.w, quat_rhs.w, 1e-5, 1e-5);
	}
	else
	{
		return isClose(quat_lhs.x, quat_rhs.x, 1e-10, 1e-10)
			&& isClose(quat_lhs.y, quat_rhs.y, 1e-10, 1e-10)
			&& isClose(quat_lhs.z, quat_rhs.z, 1e-10, 1e-10)
			&& isClose(quat_lhs.w, quat_rhs.w, 1e-10, 1e-10);
	}
}

// Quat + Quat
Quaternion!Type add(Type)(
	in Quaternion!Type lhs,
	in Quaternion!Type rhs,
) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		lhs[0] + rhs[0],
		lhs[1] + rhs[1],
		lhs[2] + rhs[2],
		lhs[3] + rhs[3],
	);
}
// Quat - Quat
Quaternion!Type subtract(Type)(
	in Quaternion!Type lhs,
	in Quaternion!Type rhs,
) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		lhs[0] - rhs[0],
		lhs[1] - rhs[1],
		lhs[2] - rhs[2],
		lhs[3] - rhs[3],
	);
}
// Quat * Quat
Quaternion!Type multiply(Type)(
	in Quaternion!Type lhs,
	in Quaternion!Type rhs,
) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		+(lhs.w * rhs.x) + (lhs.x * rhs.w) + (lhs.y * rhs.z) - (lhs.z * rhs.y),
		+(lhs.w * rhs.y) - (lhs.x * rhs.z) + (lhs.y * rhs.w) + (lhs.z * rhs.x),
		+(lhs.w * rhs.z) + (lhs.x * rhs.y) - (lhs.y * rhs.x) + (lhs.z * rhs.w),
		+(lhs.w * rhs.w) - (lhs.x * rhs.x) - (lhs.y * rhs.y) - (lhs.z * rhs.z),
	);
}

unittest
{
	Quaternion!float quat_i = Quaternion!float(1f, 0f, 0f, 0f);
	Quaternion!float quat_j = Quaternion!float(0f, 1f, 0f, 0f);
	Quaternion!float quat_k = Quaternion!float(0f, 0f, 1f, 0f);
	Quaternion!float quat_w = Quaternion!float(0f, 0f, 0f, 1f);
	// i^2 == j^2 == k^2 == -1f
	assert(quat_i * quat_i == -quat_w);
	assert(quat_j * quat_j == -quat_w);
	assert(quat_k * quat_k == -quat_w);
	// (quat_a * w_1) == (w_1 * quat_a)  == quat_a 
	assert(quat_i * quat_w == quat_i && quat_w * quat_i == quat_i);
	assert(quat_j * quat_w == quat_j && quat_w * quat_j == quat_j);
	assert(quat_k * quat_w == quat_k && quat_w * quat_k == quat_k);
	// i*j*k == -1f
	assert(quat_i * quat_j * quat_k == Quaternion!float(0f, 0f, 0f, -1f));
	// i * j == k  j * k == i  k * i == j
	assert(quat_i * quat_j == quat_k);
	assert(quat_j * quat_k == quat_i);
	assert(quat_k * quat_i == quat_j);
	// reverse
	assert(quat_j * quat_i == -quat_k);
	assert(quat_k * quat_j == -quat_i);
	assert(quat_i * quat_k == -quat_j);
}
// Quat * 2.0
Quaternion!Type multiply(Type)(
	in Quaternion!Type lhs,
	in Type rhs,
) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		lhs.x * rhs,
		lhs.y * rhs,
		lhs.z * rhs,
		lhs.w * rhs,
	);
}
// Quat / 2.0
Quaternion!Type devide(Type)(
	in Quaternion!Type lhs,
	in Type rhs,
) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		lhs.x / rhs,
		lhs.y / rhs,
		lhs.z / rhs,
		lhs.w / rhs,
	);
}

Vector!(3, Type) rotate_by(Type)(
	in Vector!(3, Type) vec,
	in Quaternion!Type quat,
) pure nothrow @nogc @safe
{
	return (quat * Quaternion!Type(vec) * quat.conjugate)
		.to_vec();
}

unittest
{
	Quaternion!float quat_x, quat_y, quat_z;
	Vector!(3, float) vec_x, vec_y, vec_z;
	quat_x = Quaternion!float(Vec3(1.0f, 0.0f, 0.0f), PI / 2);
	quat_y = Quaternion!float(Vec3(0.0f, 1.0f, 0.0f), PI / 2);
	quat_z = Quaternion!float(Vec3(0.0f, 0.0f, 1.0f), PI / 2);

	vec_x = Vec3(1.0f, 0.0f, 0.0f);
	vec_y = Vec3(0.0f, 1.0f, 0.0f);
	vec_z = Vec3(0.0f, 0.0f, 1.0f);

	assert(vec_x.rotate_by(quat_x) == vec_x);
	assert(vec_x.rotate_by(quat_y) == -vec_z);
	assert(vec_x.rotate_by(quat_z) == vec_y);
}
