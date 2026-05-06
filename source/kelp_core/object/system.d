module kelp_core.object.system;

import kelp_core.object;

interface IObjectSystem
{
	void initialize(ObjectManager);
	void finalize(ObjectManager);
	void process(ObjectManager);
}


