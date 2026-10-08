module dulse.object.resource.resource;

class ResourceBox(Type) : IResourceBox
{
	Type resource;

	this(Type resource)
	{
		this.resource = resource;
		return;
	}

	ref Type get() pure nothrow @nogc @safe
	{
		return resource;
	}
}

interface IResourceBox
{

}
