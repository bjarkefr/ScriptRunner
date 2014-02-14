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
	protected string program;
	protected string argTemplate;

	public this(string extension, string program, string argTemplate)
	{
		this.extension = extension;
		this.program = program;
		this.argTemplate = argTemplate;
	}

	public bool CanHandle(string extension)
	{
		return extension == this.extension;
	}

	public void Run(string fullpath)
	{
		string argument = format(argTemplate, fullpath);

		writeln("\nRunning '%s %s':", program, argument); //TODO: Some kind of logging facility?

		if(wait(spawnProcess([program, argument])) != 0) // I'm using spawnProcess rather than execute to avoid redirecting stdin, stdio and stderr.
			throw new ScriptDispatchException(format("Script execution failed for '%s %s'", program, argument));

		writeln();
	}

	public void SanityCheck(string fullpath) {}
}
