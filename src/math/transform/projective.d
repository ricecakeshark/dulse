module dulse.math.transform.projective;

import dulse.math.linalg;
import dulse.math.transform;
import std.math;

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
	return_matrix = return_matrix * matrix_translate(camera_pos);
	return return_matrix;
}

alias transformer_perspective = transformer_perspective_rh_zo;
// Perspective Projection
Matrix!(4, 4) transformer_perspective_rh_zo(
	in float fovy = PI_2,
	in float aspect = 960.0f / 540.0f,
	in float near = 0.1f,
	in float far = 100.0f,
) pure nothrow @nogc @safe
in
{
	assert(isFinite(fovy) && fovy > 0.0f && fovy < PI);
	assert(isFinite(aspect) && aspect >= 0.1f && aspect <= 100.0f);
	assert(isFinite(near) && isFinite(far) && 0 < near && near < far);
}
do
{
	return matrix_scaling_xy(fovy, aspect) * perspective_depth_rh_zo(near, far);
}

Matrix!(4, 4) transformer_perspective_lh_zo(
	in float fovy = PI_2,
	in float aspect = 960.0f / 540.0f,
	in float near = 0.1f,
	in float far = 100.0f,
) pure nothrow @nogc @safe
in
{
	assert(isFinite(fovy) && fovy > 0.0f && fovy < PI);
	assert(isFinite(aspect) && aspect >= 0.1f && aspect <= 100.0f);
	assert(isFinite(near) && isFinite(far) && 0 < near && near < far);
}
do
{
	return matrix_scaling_xy(fovy, aspect) * perspective_depth_lh_zo(near, far);
}
// Orthogonal Projection
Matrix!(4, 4) transformer_ortho(
	in float fovy = PI_2,
	in float aspect = 1920f / 1080f,
	in float zn = 0.0f,
	in float zf = 1.0f,
)
in
{
	assert(isFinite(fovy) && fovy > 0.0f && fovy < PI);
	assert(isFinite(aspect) && aspect >= 0.1f && aspect <= 100.0f);
	assert(zf.isFinite && zn.isFinite && zn < zf);
}
do
{
	return matrix_scaling_xy(fovy, aspect) * matrix_ortho_zw(zn, zf);
}

Matrix!(4, 4) transformer_ortho_wh(
	in float w,
	in float h,
	in float zn = 0.0f,
	in float zf = 1.0f,
)
in
{
	assert(w.isFinite && w > 0.0f);
	assert(h.isFinite && h > 0.0f);
	assert(zf.isFinite && zn.isFinite && zn < zf);
}
do
{
	return matrix_scaling_xy_wh(w, h) * matrix_ortho_zw(zn, zf);
}

Matrix!(4, 4, float) matrix_scaling_xy(
	in float fovy,
	in float aspect = 960.0f / 540.0f,
) pure nothrow @nogc @safe
in
{
	assert(isFinite(fovy) && fovy > 0.0f && fovy < PI);
	assert(isFinite(aspect) && aspect >= 1.0f && aspect <= 4.0f);
}
do
{
	scope float F = 1.0f / tan(fovy * 0.5f);
	return Matrix!(4, 4, float)([
		[F / aspect, 0f, 0f, 0f,],
		[0f, F, 0f, 0f,],
		[0f, 0f, 1f, 0f],
		[0f, 0f, 0f, 1f],
	]);
}

Matrix!(4, 4) matrix_scaling_xy_wh(
	in float w,
	in float h,
)
in (w.isFinite && w > 0.0f)
in (h.isFinite && h > 0.0f)
{
	return Matrix!(4, 4)([
		[2f / w, 0f, 0f, 0f],
		[0f, -2f / h, 0f, 0f],
		[0f, 0f, 1f, 0f],
		[0f, 0f, 0f, 1f],
	]);
}

Matrix!(4, 4, float) perspective_depth_rh_zo(
	in float near = 0.1f,
	in float far = 100.0f,
) pure nothrow @nogc @safe
in (isFinite(near) && isFinite(far) && 0 < near && near < far)
{
	return Matrix!(4, 4, float)([
		[1f, 0f, 0f, 0f,],
		[0f, 1f, 0f, 0f,],
		[0f, 0f, far / (near - far), -1f],
		[0f, 0f, near * far / (near - far), 0f],
	]);
}

Matrix!(4, 4, float) perspective_depth_rh_no(
	in float near = 0.1f,
	in float far = 100.0f,
) pure nothrow @nogc @safe
in (isFinite(near) && isFinite(far) && 0 < near && near < far)
{
	return Matrix!(4, 4, float)([
		[1f, 0f, 0f, 0f,],
		[0f, 1f, 0f, 0f,],
		[0f, 0f, (near + far) / (near - far), -1f],
		[0f, 0f, 2f * far * near / (near - far), 0f],
	]);
}

Matrix!(4, 4, float) perspective_depth_lh_zo(
	in float near = 0.1f,
	in float far = 100.0f,
) pure nothrow @nogc @safe
in (isFinite(near) && isFinite(far) && 0 < near && near < far)
{
	return Matrix!(4, 4, float)([
		[1f, 0f, 0f, 0f,],
		[0f, 1f, 0f, 0f,],
		[0f, 0f, far / (far - near), +1f],
		[0f, 0f, -far * near / (far - near), 0f],
	]);
}

Matrix!(4, 4) matrix_ortho_zw(
	in float zn = 0.0f,
	in float zf = 1.0f,
)
in (zf.isFinite && zn.isFinite && zn < zf)
{
	return Matrix!(4, 4)([
		[1f, 0f, 0f, 0f],
		[0f, 1f, 0f, 0f],
		[0f, 0f, 1f / (zf - zn), 0f],
		[0f, 0f, -zn / (zf - zn), 1f],
	]);
}
