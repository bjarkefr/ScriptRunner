module ScriptDispatch.GenericHandler;

import std.string;
import std.process;
import std.stdio;

public class ScriptDispatchException : Exception
{
	this(string message) { super(message); }
}

public interface ScriptHandler
{
	bool CanHandle(string extension);
	void Run(string fullpath);
	void SanityCheck(string fullpath);
}

public class GenericHandler : ScriptHandler
{
	protected string extension;
	protected string command;

	public this(string extension, string command)
	{
		this.extension = extension;
		this.command = command;
	}

	public bool CanHandle(string extension)
	{
		return extension == this.extension;
	}

	public void Run(string fullpath)
	{
		string fullCommand = command ~ ' ' ~ fullpath;

		writeln(format("\nRunning '%s':", fullCommand)); //TODO: Some kind of logging facility?

		if(wait(spawnShell(fullCommand)) != 0) // I'm using spawnProcess rather than execute to avoid redirecting stdin, stdio and stderr.
			throw new ScriptDispatchException(format("Script execution failed for '%s'", fullCommand));

		writeln();
	}

	public void SanityCheck(string fullpath) {}
}
