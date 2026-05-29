module kelp_core.physics.manifold;

import kelp_core.math;

struct CollideManifold
{
	bool hit;
	float penetration;
	Vector!(3, float) normal;
	Vector!(3, float) point;
	
	this(bool hit, float penetration)
	{
		this.hit = hit;
		this.penetration = penetration;
		return;
	}
}
