module kelp_core.math.transform.transform3d;

import kelp_core.math.linalg;
import std.math;

// Row-major (v2 = v * M)
Matrix!(4, 4) transformer_scale(in Vector!(3) vec) pure nothrow @nogc @safe
{
	Matrix!(4, 4) temp;
	temp = matrix_identity!(4, float)();
	static foreach (index; 0 .. 3)
	{
		temp[index, index] = vec[index];
	}
	return temp;
}

Matrix!(4, 4) transformer_scale(Type)(in Type[3] vec...) pure nothrow @nogc @safe
{
	return transformer_scale(Vector!(3)(vec));
}

alias transformer_translate = transformer_translate_row;

Matrix!(4, 4) transformer_translate_row(in Vector!(3) vec) pure nothrow @nogc @safe
{
	Matrix!(4, 4) temp;
	temp = matrix_identity!(4, float)();
	static foreach (index; 0 .. 3)
	{
		temp[3, index] = vec[index];
	}
	return temp;
}

Matrix!(4, 4) transformer_translate_row(Type)(in Type[3] vec...) pure nothrow @nogc @safe
{
	Matrix!(4, 4) temp;
	temp = matrix_identity!(4, float)();
	static foreach (index; 0 .. 3)
	{
		temp[3, index] = vec[index];
	}
	return temp;
}

Matrix!(4, 4) transformer_translate_col(in Vector!(3) vec) pure nothrow @nogc @safe
{
	Matrix!(4, 4) temp;
	temp = matrix_identity!(4, float)();
	static foreach (index; 0 .. 3)
	{
		temp[index, 3] = vec[index];
	}
	return temp;
}

Matrix!(4, 4) transformer_translate_col(Type)(in Type[3] vec) pure nothrow @nogc @safe
{
	return transformer_translate_col(Vector!(3)(vec));
}

Matrix!(4, 4) transformer_rotate_x(in float rad) pure nothrow @nogc @safe
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
	Matrix!(4, 4) mat_scale = transformer_scale(Vector!(3)([1.0f, 2.0f, 3.0f]));
	assert(mat_scale == [
			[1.0f, 0.0f, 0.0f, 0.0f,],
			[0.0f, 2.0f, 0.0f, 0.0f,],
			[0.0f, 0.0f, 3.0f, 0.0f,],
			[0.0f, 0.0f, 0.0f, 1.0f,],
		]
	);

	Matrix!(4, 4) mat_translate = transformer_translate(Vector!(3)([
			1.0f, 2.0f, 3.0f
		]));
	assert(mat_translate == [
			[1.0f, 0.0f, 0.0f, 0.0f,],
			[0.0f, 1.0f, 0.0f, 0.0f,],
			[0.0f, 0.0f, 1.0f, 0.0f,],
			[1.0f, 2.0f, 3.0f, 1.0f,],
		]
	);

	Matrix!(4, 4) mat_rot_x = transformer_rotate_x(PI_2);
	assert(mat_rot_x == [
			[1.0f, 0.0f, 0.0f, 0.0f,],
			[0.0f, 0.0f, -1.0f, 0.0f,],
			[0.0f, +1.0f, 0.0f, 0.0f,],
			[0.0f, 0.0f, 0.0f, 1.0f,],
		]
	);
}

Matrix!(4, 4) transform()
{
	return transformer_perspective() * transformer_look_at(
		Vector!(3)([0.0f, 0.0f, +1.0f]),
		Vector!(3)([0.0f, 0.0f, 0.0f]),
		Vector!(3)([0.0f, +1.0f, 0.0f])
	);
}

Matrix!(4, 4) transformer_look_at(
	in Vector!(3) camera_pos,
	in Vector!(3) target_pos,
	in Vector!(3) camera_bias
) pure nothrow @nogc @safe
{
	Matrix!(4, 4) return_matrix;
	Vector!(3) vec_x, vec_y, vec_z;

	vec_z = (camera_pos - target_pos).unit;
	vec_x = (camera_bias * vec_z).unit;
	vec_y = (vec_z * vec_x).unit;

	return_matrix = [
		[vec_x[0], vec_x[1], vec_x[2], 0.0f],
		[vec_y[0], vec_y[1], vec_y[2], 0.0f],
		[vec_z[0], vec_z[1], vec_z[2], 0.0f],
		[0.0f, 0.0f, 0.0f, 1.0f]
	];
	return_matrix = return_matrix * transformer_translate(camera_pos);
	return return_matrix;
}

alias transformer_perspective = transformer_perspective_rh_zo;
// transfor_RH_
/+Matrix!(4, 4) transformer_perspective_rh_no(
	in float fovy = PI_2,
	in float aspect = 960.0f / 540.0f,
	in float near = 0.1f,
	in float far = 10.0f,
) pure nothrow @nogc @safe
in
{
	assert(isFinite(fovy) && fovy > 0.0f && fovy < PI);
	assert(isFinite(aspect) && aspect >= 1.0f && aspect <= 4.0f);
	assert(isFinite(near) && isFinite(far) && 0 < near);
}
do
{
	Matrix!(4, 4) return_matrix;
	float F = 1.0f / tan(fovy * 0.5f);

	return_matrix = [
		[F / aspect, 0.0f, 0.0f, 0.0f],
		[0.0f, F, 0.0f, 0.0f],
		[
			0.0f, 0.0f, -(far + near) / (far - near), (-2.0f * far * near) / (far - near)
		],
		[0.0f, 0.0f, -1.0f, 0.0f],
	];
	return return_matrix;
}+/

Matrix!(4, 4) transformer_perspective_rh_zo(
	in float fovy = PI_2,
	in float aspect = 960.0f / 540.0f,
	in float near = 0.1f,
	in float far = 100.0f,
) pure nothrow @nogc @safe
in
{
	assert(isFinite(fovy) && fovy > 0.0f && fovy < PI);
	assert(isFinite(aspect) && aspect >= 1.0f && aspect <= 4.0f);
	assert(isFinite(near) && isFinite(far) && 0 < near && near < far);
}
do
{
	Matrix!(4, 4) return_matrix;
	float F = 1.0f / tan(fovy * 0.5f);

	return_matrix = [
		[F / aspect, 0.0f, 0.0f, 0.0f],
		[0.0f, F, 0.0f, 0.0f],
		[
			0.0f, 0.0f, far / (near - far), -1.0f
		],
		[0.0f, 0.0f, (far * near) / (near - far), 0.0f],
	];
	return return_matrix;
}

/+Matrix!(4, 4) transformer_perspective_lh(
	in float fovy = PI_2,
	in float aspect = 960.0f / 540.0f,
	in float near = 0.1f,
	in float far = 10.0f,
) pure nothrow @nogc @safe
in
{
	assert(isFinite(fovy) && fovy > 0.0f && fovy < PI);
	assert(isFinite(aspect) && aspect >= 1.0f && aspect <= 4.0f);
	assert(isFinite(near) && isFinite(far) && 0 < near && near < far);
}
do
{
	Matrix!(4, 4) return_matrix;
	float F = 1.0f / tan(fovy * 0.5f);

	return_matrix = [
		[F / aspect, 0.0f, 0.0f, 0.0f],
		[0.0f, F, 0.0f, 0.0f],
		[
			0.0f, 0.0f, +(far + near) / (far - near), (-2.0f * far * near) / (far - near)
		],
		[0.0f, 0.0f, +1.0f, 0.0f],
	];
	return return_matrix;
}+/

Matrix!(4, 4) transformer_ortho_wh(
	in float w,
	in float h,
	in float zn = 0.0f,
	in float zf = 1.0f,
)
in
{
	assert(!w.isNaN && w > 1.0f);
	assert(!h.isNaN && h > 1.0f);
	assert(!zf.isNaN && !zn.isNaN && zn < zf);
}
do
{
	Matrix!(4, 4) temp;
	temp = Matrix!(4, 4)([
		[2.0f / w, 0.0f, 0.0f, -1.0f],
		[0.0f, -2.0f / h, 0.0f, +1.0f],
		[0.0f, 0.0f, 1.0f / (zf - zn), -zn / (zf - zn)],
		[0.0f, 0.0f, 0.0f, +1.0f],
	]);
	return temp;
}

Matrix!(4, 4, float) to_normal(Matrix!(4, 4, float) matrix)
{
	return cast(Matrix!(4, 4, float))(cast(Matrix!(3, 3, float)) matrix)
		.inverse()
		.transpose();
}
