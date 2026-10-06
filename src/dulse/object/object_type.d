module dulse.object.object_type;

import dulse.object;
import std.meta : allSatisfy, staticIndexOf, staticMap;
import std.traits : InterfacesTuple;

template isComponentType(T)
{
	enum bool isComponentType = is(T == struct) && staticIndexOf!(IComponentStore, InterfacesTuple!T) >= 0;
}

template isStructType(T)
{
	enum bool isStructType = is(T == struct);
}

template isSystemType(T)
{
	enum bool isSystemType = is(T == class) && staticIndexOf!(IObjectSystem, InterfacesTuple!T) >= 0;
}
