module kelp_core.math.linalg.quaternion;

import kelp_core.math.linalg;
import std.math;

struct Quaternion(Type = float)
{
	Type[4] data;

	this(in Type[3] xyz...) pure nothrow @nogc @safe
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
		static foreach (index; 0 .. 4)
		{
			this.opIndex(index) = vec[index];
		}
		this.opIndex(3) = 1.0f;
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

	@property ref inout(Type[4]) xyzw() inout pure nothrow @nogc @safe
	{
		return this.data;
	}

	bool opEquals(in typeof(this) rhs) const pure nothrow @nogc @safe
	{
		return isClose(this.x, rhs.x, 1e-5, 1e-5)
			&& isClose(this.y, rhs.y, 1e-5, 1e-5)
			&& isClose(this.z, rhs.z, 1e-5, 1e-5)
			&& isClose(this.w, rhs.w, 1e-5, 1e-5);
	}

	@property Type norm() pure nothrow @nogc @safe
	{
		return sqrt(this[0].pow(2) + this[1].pow(2) + this[2].pow(2) + this[3].pow(2));
	}

	ref inout(Type) opIndex(size_t index) inout pure nothrow @nogc @safe
	{
		return this.data[index];
	}

	typeof(this) opUnary(string op)() pure nothrow @nogc @safe
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

	typeof(this) unit() pure nothrow @nogc @safe
	{
		return this / this.norm;
	}

	typeof(this) opBinary(string op : "+")(in Quaternion!Type rhs)
	{
		return add(this, rhs);
	}

	typeof(this) opBinary(string op : "-")(in Quaternion!Type rhs)
	{
		return subtract(this, rhs);
	}

	typeof(this) opBinary(string op : "*")(in Quaternion!Type rhs)
	{
		return multiply(this, rhs);
	}

	typeof(this) opBinary(string op : "*")(in Type rhs)
	{
		return multiply(this, rhs);
	}

	typeof(this) opBinary(string op : "/")(in Type rhs)
	{
		return devide(this, rhs);
	}

	size_t toHash() const pure nothrow @nogc @safe
	{
		return hashOf(this.data);
	}

}

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

Quaternion!Type multiply(Type)(
	in Quaternion!Type lhs,
	in Quaternion!Type rhs,
) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		+(lhs.w * rhs.x) + (lhs.z * rhs.y) - (lhs.y * rhs.z) + (lhs.x * rhs.w),
		+(lhs.w * rhs.y) - (lhs.z * rhs.x) + (lhs.y * rhs.w) + (lhs.x * rhs.z),
		+(lhs.w * rhs.z) + (lhs.z * rhs.w) + (lhs.y * rhs.x) - (lhs.x * rhs.y),
		+(lhs.w * rhs.w) - (lhs.z * rhs.z) - (lhs.y * rhs.y) - (lhs.x * rhs.x),
	);
}

unittest
{
	Quaternion!float quat_w = Quaternion!float(0f, 0f, 0f, 1f);
	Quaternion!float quat_i = Quaternion!float(0f, 0f, 1f, 0f);
	Quaternion!float quat_j = Quaternion!float(0f, 1f, 0f, 0f);
	Quaternion!float quat_k = Quaternion!float(1f, 0f, 0f, 0f);

	// i^2 == j^2 == k^2 == -1f
	assert(quat_i * quat_i == Quaternion!float(0f, 0f, 0f, -1f));
	assert(quat_j * quat_j == Quaternion!float(0f, 0f, 0f, -1f));
	assert(quat_k * quat_k == Quaternion!float(0f, 0f, 0f, -1f));
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
