module dulse.object.system;

import dulse.object;

interface IObjectSystem
{
	void initialize(ObjectManager) @safe;
	void finalize(ObjectManager) @safe;
	void process(ObjectManager) @safe;
}
