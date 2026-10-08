module dulse.object.component.component;

import dulse.object;

interface IComponentStore
{
	@property bool has(Entity entity) pure nothrow @nogc @safe;

	@property size_t count() pure nothrow @nogc @safe;

	@property Entity[] entities() pure nothrow @nogc;

	@property TypeInfo type() pure nothrow @nogc @safe;

	typeof(this) clear() pure nothrow @nogc @safe;

	typeof(this) attach(in Entity[] entity_list...) pure nothrow @safe;

	typeof(this) detach(in Entity[]...) pure nothrow @safe;
}
