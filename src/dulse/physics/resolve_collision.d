module dulse.physics.resolve_collision;

import dulse.math;
import dulse.physics;
import std.algorithm;
import std.math : isNaN;

void resolve_collision(
	ref Body lhs,
	ref Body rhs,
	CollideManifold manifold,
) pure nothrow @nogc @safe
in
{
	assert(!lhs.pos.contain_nan);
	assert(!lhs.vel.contain_nan);
	assert(!rhs.pos.contain_nan);
	assert(!rhs.vel.contain_nan);
	assert(!manifold.normal.contain_nan);
	assert(!manifold.point.contain_nan);
}
do
{
	float restitute_coefficient = 1.0;
	float vel_along_normal = inner_product(rhs.vel - lhs.vel, manifold.normal);
	if (vel_along_normal < 0.0f)
	{
		return;
	}

	float temp_restitute = -(1.0 + restitute_coefficient)
		* vel_along_normal / (
			lhs.inverse_mass + rhs.inverse_mass);
	//assert(temp_restitute != 0);
	lhs.velocity -= temp_restitute * lhs.inverse_mass * manifold.normal;
	rhs.velocity += temp_restitute * rhs.inverse_mass * manifold.normal;
	return;
}

void resolve_collision(
	ref Body lhs,
) pure nothrow @nogc @safe
{
	float dist;
	float outside;
	Vec3 inward;
	float vn;
	dist = distance(lhs.pos, Vec3(0f, 0f, 0f));
	if (dist <= 0.1f)
	{
		return;
	}
	outside = dist + lhs.shape!Sphere.radius - 2.5f;
	if (outside <= 0f)
	{
		return;
	}

	inward = -(lhs.pos / dist);
	vn = inner_product(lhs.vel, inward);

	lhs.pos += inward * outside;
	if (vn < 0.0f)
	{
		lhs.velocity -= (1.0 + lhs.restitution) * vn * inward;
	}

	return;
}

void correct_position(
	ref Body lhs,
	ref Body rhs,
	CollideManifold manifold,
) pure nothrow @nogc @safe
in
{

	assert(!manifold.penetration.isNaN);
	assert(!lhs.inverse_mass.isNaN);
	assert(!rhs.inverse_mass.isNaN);
}
do
{

	scope float inverse_mass_sum = lhs.inverse_mass + rhs.inverse_mass;
	if (inverse_mass_sum == 0.0)
	{
		return;
	}
	scope float correction_mag = max(manifold.penetration, 0.0f) / inverse_mass_sum * 0.8;
	assert(!correction_mag.isNaN);
	scope Vec3 correction;
	correction = manifold.normal * correction_mag;
	assert(!correction.contain_nan);
	lhs.position -= correction * lhs.inverse_mass;
	rhs.position += correction * rhs.inverse_mass;
	return;
}

unittest
{
	import std.math;

	auto sphere_a = Body(Shape(Sphere(2.0)), Vec3(0f, 0f, 0f), 2.0f);
	auto sphere_b = Body(Shape(Sphere(2.0)), Vec3(3f, 0f, 0f), 3.0f);
	sphere_a.vel = Vec3(+1f, 0f, 0f);
	sphere_b.vel = Vec3(-1f, 0f, 0f);
	auto manifold = detect_collision(sphere_a, sphere_b);
	assert(manifold.hit == true);
	assert(manifold.penetration.isClose(1.0f));
	resolve_collision(sphere_a, sphere_b, manifold);
	/+
	import std.stdio;

	writeln("sphere_a: ", sphere_a);
	writeln("sphere_b: ", sphere_b);
	+/
}
