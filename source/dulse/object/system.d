module dulse.object.system;

import dulse.object;

interface IObjectSystem
{
	void initialize(ObjectManager);
	void finalize(ObjectManager);
	void process(ObjectManager);
}


