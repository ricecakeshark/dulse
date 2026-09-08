module dulse.physics.body;

import dulse.math;
import std.sumtype;

alias Shape = SumType!(Sphere, AxisBox);

struct Body
{
	Shape _shape;
	Vec3 position;
	Vec3 velocity = Vec3(0.0f, 0.0f, 0.0f);
	float inverse_mass;
	float restitution = 1.0;

	this(Shape shape, Vec3 position, float inverse_mass = 1.0) pure nothrow @nogc @safe
	{
		this._shape = shape;
		this.position = position;
		this.velocity = Vec3(0.0f, 0.0f, 0.0f);
		this.inverse_mass = inverse_mass;
		this.restitution = 1.0;
		return;
	}

	this(Shape shape, float inverse_mass) pure nothrow @nogc @safe
	{
		this._shape = shape;
		this.velocity = Vec3(0.0f, 0.0f, 0.0f);
		this.inverse_mass = inverse_mass;
		this.restitution = 1.0;
		return;
	}

	Type shape(Type)() pure nothrow @nogc @safe
	{
		return this._shape.get!Type();
	}

	alias pos = position;
	alias vel = velocity;
}
