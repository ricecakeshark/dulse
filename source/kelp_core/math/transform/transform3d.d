module kelp_core.math.transform.transform3d;

import kelp_core.math.linalg;
import std.math : PI_2, tan;

Matrix!(4, 4) createTransformer()
{
	return create_perspective() * create_look_at(
		Vector!(3)([0.0f, 0.0f, +1.0f]),
		Vector!(3)([0.0f, 0.0f, 0.0f]),
		Vector!(3)([0.0f, +1.0f, 0.0f])
	);
}

Matrix!(4, 4) create_look_at(
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
		[vec_x[0], vec_y[0], vec_z[0], -camera_pos[0]],
		[vec_x[1], vec_y[1], vec_z[1], -camera_pos[1]],
		[vec_x[2], vec_y[2], vec_z[2], -camera_pos[2]],
		[0.0f, 0.0f, 0.0f, 1.0f],
	];
	return return_matrix;
}

Matrix!(4, 4) create_perspective(
	in float fovy = PI_2,
	in float aspect = 960.0f / 540.0f,
	in float far = 1.0f,
	in float near = 0.0f,

) pure nothrow @nogc @safe
{
	Matrix!(4, 4) return_matrix;
	float F = 1.0f / tan(fovy / 2.0f);

	return_matrix = [
		[F / aspect, 0.0f, 0.0f, 0.0f],
		[0.0f, F, 0.0f, 0.0f],
		[0.0f, 0.0f, (far + near) / (far - near), (-2.0f * far * near) / (far - near)],
		[0.0f, 0.0f, -1.0f, 0.0f],
	];
	return return_matrix;
}
