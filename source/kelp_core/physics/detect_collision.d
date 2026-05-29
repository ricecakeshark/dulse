module kelp_core.physics.detect_collision;

import kelp_core.math;
import kelp_core.physics;
import std.exception;
import std.math;

CollideManifold detect_collision(ref Body lhs, ref Body rhs) pure @safe
{
	CollideManifold manifold;
	scope Vec3 delta = rhs.pos - lhs.pos;
	scope float dist = distance(lhs.pos, rhs.pos);
	enforce(!dist.isNaN);
	scope float penetrate = (lhs.shape!Sphere.radius + rhs.shape!Sphere.radius) - dist;
	enforce(!penetrate.isNaN);
	if (penetrate > 0)
	{
		manifold.hit = true;
		manifold.normal = delta.unit;
		manifold.point = (lhs.pos + rhs.pos) / 2.0;
		manifold.penetration = penetrate;
	}
	else
	{
		manifold.hit = false;
	}
	return manifold;
}

unittest
{
	import std.math;

	Body sphere_a, sphere_b, sphere_c, sphere_d;
	sphere_a = Body(Shape(Sphere(2.0)), Vec3(0.0f, 0.0f, 0.0f));
	sphere_b = Body(Shape(Sphere(3.0)), Vec3(5.0f, 0.0f, 0.0f));
	sphere_c = Body(Shape(Sphere(3.0 + 0.25)), Vec3(0.0f, 5.0f, 0.0f));
	sphere_d = Body(Shape(Sphere(5.0 + 0.5)), Vec3(2.0f, 3.0f, 6.0f));

	assert(detect_collision(sphere_a, sphere_b).hit == false);
	assert(detect_collision(sphere_a, sphere_c).hit == true);
	assert(detect_collision(sphere_a, sphere_c).penetration.isClose(0.25f, 1e-5, 1e-5));
	assert(detect_collision(sphere_a, sphere_d).hit == true);
	assert(detect_collision(sphere_a, sphere_d).penetration.isClose(0.5f, 1e-5, 1e-5));
}
