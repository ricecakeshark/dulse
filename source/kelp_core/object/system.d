module kelp_core.object.system;

import kelp_core.object;

interface IObjectSystem(Entity)
{
	void initialize(ObjectManager!Entity);
	void process(ObjectManager!Entity);
}


