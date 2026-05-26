module kelp_core.math.linalg.rotation_vector;

import kelp_core.math.linalg;
import std.math;

struct RotationVector(Type)
{
	Vector!(3, Type) rot_vec;

	this(Type[3] xyz...)
	{
		this.rot_vec = Vector!(3, Type)(xyz);
		return;
	}

	this(Vector!(3, Type) vec...)
	{
		this.rot_vec = vec;
		return;
	}

	Vector!(3, Type) opBinary(string op : "*")(in Vector!(3, Type) rhs) const
	{
		return rotate(rhs, this);
	}

	Matrix!(3, 3) to_matrix()
	{
		scope float theta = rot_vec.norm;
		scope Vector!(3, Type) axis = rot_vec.unit;
		scope float c_th = cos(theta);
		scope float s_th = sin(theta);
		return Matrix!(3, 3)([
			[
				c_th + axis.x * axis.x * (1.0f - c_th),
				axis.x * axis.y * (1.0f - c_th) - axis.z * s_th,
				axis.x * axis.z * (1.0f - c_th) + axis.y * s_th
			],
			[
				axis.y * axis.x * (1f - c_th) + axis.z * s_th,
				c_th + axis.y * axis.y * (1f - c_th),
				axis.y * axis.z * (1f - c_th) - axis.z * s_th,
			],
			[
				axis.z * axis.x * (1f - c_th) - axis.y * s_th,
				axis.z * axis.y * (1f - c_th) + axis.x * s_th,
				c_th + axis.z * axis.z * (1f - c_th),
			]
		]);
	}

	alias rot_vec this;
}

Vector!(3, Type) rotate(Type)(
	in Vector!(3, Type) pos_vec,
	in RotationVector!Type rot_vec,
) pure nothrow @nogc @safe
{
	float theta = rot_vec.norm;
	if (theta == 0.0)
	{
		return pos_vec;
	}
	Vector!(3, Type) axis = rot_vec.unit;

	return pos_vec * cos(theta)
		+ axis * inner_product(axis, pos_vec) * (1.0f - cos(theta))
		+ cross_product(axis, pos_vec) * sin(theta);
}

Vector!(3, Type) multiply(Type)(
	Vector!(3, Type) pos_vec,
	RotationVector!Type rot_vec,
) pure nothrow @nogc @safe
{
	return rotate(pos_vec, rot_vec);
}

unittest
{

	RotationVector!float rotate_vec;
	Vec3 vec;
	rotate_vec = RotationVector!float(Vec3(0.0f, 0.0f, PI / 2.0f));
	vec = Vec3(1.0f, 0.0f, 0.0f);
	assert(vec.rotate(rotate_vec) == Vec3(0f, 1f, 0f));
}
