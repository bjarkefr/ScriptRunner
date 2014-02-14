module DBTools;

import Backend.DBVersionTagger;

import std.stdio;
import std.string;

public class DBTools
{
	private DBVersionTagger tagger;

	public this(DBVersionTagger tagger)
	{
		this.tagger = tagger;
	}

	public void PrintInfo()
	{
		VersionInfo info = tagger.GetInfo(true);
		writeln(format("Current database: version %d, state %s, tag '%s'", info.Version, info.State, info.Tag));
	}

	public void InitializeDB()
	{
		tagger.InitializeDB();
		writeln("Database initialized with version information");
	}

	public void ForceNormalMode(int version_)
	{
		tagger.ForceNormalMode(version_);
		writeln(format("Database sat back into normal mode at version %d", version_));
	}
}
