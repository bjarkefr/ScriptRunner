module ScriptRepository.FSScriptRepository;

import std.path;
import std.ascii;
import std.conv;
import std.string;
import std.algorithm;
import std.file;
import std.typecons;
import std.array;
import std.stdio;

class InvalidFilenameException : Exception
{
	public this(string message) { super(message); }
}

class ScriptRepositorySanityException : Exception
{
	public this(string message) { super(message); }
}

class FSScriptRepository
{
	private string folder;

	public this(string folder)
	{
		this.folder = folder;
	}

	private int GetFileVersion(string fullPath)
	{
		string name = baseName(fullPath);

		int length = 0;
		while (length != name.length && isDigit(name[length]))
			++length;

		if (length == 0 || length == name.length)
			throw new InvalidFilenameException(format("Script '%s' has no version information in its filename.", name));

		try
		{
			return to!int(name[0 .. length]);
		}
		catch(ConvException)
		{
			throw new InvalidFilenameException(format("Script '%s' has invalid version number.", name));
		}
	}

	private Tuple!(int, string)[] ReadScripts()
	{
		auto scripts = array(map!(file => tuple(GetFileVersion(file.name), file.name))(dirEntries(folder, SpanMode.shallow)));
		sort!((scriptA, scriptB) => scriptA[0] < scriptB[0]) (scripts);

		int startVersion = 0;
		if (scripts.length > 0)
			startVersion = scripts[0][0] - 1;

		SanityCheckScripts(scripts, startVersion);

		return scripts;
	}

	private void SanityCheckScripts(Tuple!(int, string)[] scripts, int startVersion)
	{
		foreach(script; scripts)
		{
			if (script[0] == startVersion)
				throw new ScriptRepositorySanityException(format("More than one script with version %d.", startVersion));

			if (script[0] != startVersion + 1)
				throw new ScriptRepositorySanityException(format("Script with version %d is missing.", startVersion + 1));

			startVersion = script[0];
		}
	}

	public string[] GetOrderedAfter(int startVersion, out int latestVersion)
	{
		Tuple!(int, string)[] allScripts = ReadScripts();

		int oldestVersion = 0;
		latestVersion = 0;

		if(allScripts.length > 0)
		{
			oldestVersion = allScripts[0][0];
			latestVersion = allScripts[$-1][0];
		}

		if(startVersion + 1 < oldestVersion)
			throw new ScriptRepositorySanityException(format("Requested script version %d is older than earliest available version %d!", startVersion + 1, oldestVersion));

		if(startVersion > latestVersion)
			throw new ScriptRepositorySanityException(format("Requested script version %d is newer than the latest available version %d!", startVersion, latestVersion));

		auto relevantScripts = filter!(script => script[0] > startVersion) (allScripts);

		return array(map!(script => script[1]) (relevantScripts));
	}
}