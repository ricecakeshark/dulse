module dulse.file.archive;

import dulse.core.container : MonoPool;
import dulse.file;
import std.zip;

struct Archive
{
	protected ZipArchive archive_handle;
	ArchiveMember[] member_list;

	ref typeof(this) add(FileHandler[] file_list...)
	{
		foreach(file;file_list)
		{
			this.add(file);
		}
		return this;
	}

	ref typeof(this) add(FileHandler file)
	{
		scope ArchiveMember member;
		member = new ArchiveMember();
		member.name = file.name;
		member.expandedData(file.data_raw);
		return this;
	}
}
