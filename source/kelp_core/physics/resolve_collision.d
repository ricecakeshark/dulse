module kelp_core.physics.resolve_collision;

import kelp_core.math;
import kelp_core.physics;
import std.algorithm;

void resolve_collision(
	ref Body lhs,
	ref Body rhs,
	CollideManifold manifold,
) pure nothrow @nogc @safe
{
	float restitute_coefficient = 1.0;
	float temp_restitute = -(1.0 + restitute_coefficient)
		* inner_product(
			rhs.vel - lhs.vel, manifold.normal)
		/ (lhs.inverse_mass + rhs.inverse_mass);
	//assert(temp_restitute != 0);
	lhs.velocity -= temp_restitute * lhs.inverse_mass * manifold.normal;
	rhs.velocity += temp_restitute * rhs.inverse_mass * manifold.normal;
	return;
}

void correct_position(
	ref Body lhs,
	ref Body rhs,
	CollideManifold manifold,
) pure nothrow @nogc @safe
{

	scope float inverse_mass_sum = lhs.inverse_mass + rhs.inverse_mass;
	if (inverse_mass_sum == 0.0)
	{
		return;
	}
	scope float correction_mag = max(manifold.penetration, 0.0f) / inverse_mass_sum * 0.8;
	scope Vec3 correction = manifold.normal * correction_mag;
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

	import std.stdio;

	writeln("sphere_a: ", sphere_a);
	writeln("sphere_b: ", sphere_b);
}