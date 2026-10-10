module dulse.math.transform.rotation;

import dulse.math.linalg;
import std.math;

Matrix!(Size + (Homogeneous ? 1 : 0), Size + (Homogeneous ? 1 : 0), Type) matrix_rotate(
	bool Homogeneous = true,
	size_t Size, Type,
)(
	Vector!(Size) axis
)
{
	Matrix!(Size + (Homogeneous ? 1 : 0), Size + (Homogeneous ? 1 : 0)) temp;



	return temp;
}

Matrix!(4, 4) transformer_rotate_x(bool Homogeneous = true)(in float rad) pure nothrow @nogc @safe
{
	Matrix!(4, 4) temp;
	temp = matrix_identity!(4, float)();
	temp[1, 1] = cos(rad);
	temp[1, 2] = -sin(rad);
	temp[2, 1] = sin(rad);
	temp[2, 2] = cos(rad);
	return temp;
}

Matrix!(4, 4) transformer_rotate_y(in float rad) pure nothrow @nogc @safe
{
	Matrix!(4, 4) temp;
	temp = matrix_identity!(4, float)();
	temp[2, 2] = cos(rad);
	temp[2, 0] = -sin(rad);
	temp[0, 2] = sin(rad);
	temp[0, 0] = cos(rad);
	return temp;
}

Matrix!(4, 4) transformer_rotate_z(in float rad) pure nothrow @nogc @safe
{
	Matrix!(4, 4) temp;
	temp = matrix_identity!(4, float)();
	temp[0, 0] = cos(rad);
	temp[0, 1] = -sin(rad);
	temp[1, 0] = sin(rad);
	temp[1, 1] = cos(rad);
	return temp;
}

Matrix!(4, 4) transformer_rotate(Type = float)(in Quaternion!Type quat) pure nothrow @nogc @safe
{
	return transformer_rotate_z(quat.z)
		* transformer_rotate_y(quat.y)
		* transformer_rotate_x(quat.x);
}

unittest
{
	Matrix!(4, 4) mat_rot_x = transformer_rotate_x(PI_2);
	assert(mat_rot_x == [
			[1.0f, 0.0f, 0.0f, 0.0f,],
			[0.0f, 0.0f, -1.0f, 0.0f,],
			[0.0f, +1.0f, 0.0f, 0.0f,],
			[0.0f, 0.0f, 0.0f, 1.0f,],
		]
	);
}
