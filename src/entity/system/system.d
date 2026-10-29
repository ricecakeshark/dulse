module dulse.entity.system.system;

import dulse.entity;

interface IObjectSystem
{
	void initialize(ObjectManager) @safe;
	void finalize(ObjectManager) @safe;
	void process(ObjectManager) @safe;
}
