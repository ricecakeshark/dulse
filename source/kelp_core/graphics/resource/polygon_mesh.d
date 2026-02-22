module source.kelp_core.graphics.resource.polygon_mesh;

import kelp_core.graphics.resource;

alias GfxMesh = PolygonMesh;

struct PolygonMesh(V, I)
{
	GfxGeometry!(V, I)[] geometry_list;

}
