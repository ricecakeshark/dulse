module kelp_core.file.directory;

struct Directory
{
	string path;

	this(string path)
	{
		this.path = path;
		return;
	}
}
