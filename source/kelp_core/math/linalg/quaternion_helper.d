module kelp_core.math.linalg.quaternion_helper;

import kelp_core.math.linalg;

import std.math;
/+
Quaternion!Type quaternion_rotate(Type)(Vec3 axis, float angle) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		axis.unit.x * sin(angle / 2),
		axis.unit.y * sin(angle / 2),
		axis.unit.z * sin(angle / 2),
		cos(angle / 2),
	);
}

Quaternion!Type quaternion_rotate_x(Type)(float angle) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		1.0 * sin(angle / 2),
		0.0,
		0.0,
		cos(angle / 2),
	);
}

Quaternion!Type quaternion_rotate_y(Type)(float angle) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		0.0,
		1.0 * sin(angle / 2),
		0.0,
		cos(angle / 2),
	);
}

Quaternion!Type quaternion_rotate_z(Type)(float angle) pure nothrow @nogc @safe
{
	return Quaternion!Type(
		0.0,
		0.0,
		1.0 * sin(angle / 2),
		cos(angle / 2),
	);
}

Vector!(3, Type) to_vec3(Type)(Quaternion!Type quat) pure nothrow @nogc @safe
{
	return Vector!(3, Type)(quat.xyz);
}

Vector!(4, Type) to_vec4(Type)(Quaternion!Type quat) pure nothrow @nogc @safe
{
	return Vector!(4, Type)(quat.xyzw);
}
+/