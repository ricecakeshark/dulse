module dulse.math.geometry.rectangle;

struct Rect
{
	int x, y;
	int w, h;

	this(int x, int y, int w, int h)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		return;
	}

	this(int w, int h)
	{
		this.w = w;
		this.h = h;
		return;
	}
}
