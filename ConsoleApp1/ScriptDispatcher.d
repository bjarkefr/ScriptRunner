module ScriptDispatch.ScriptDispatcher;

import std.path;
import std.string;
import ScriptDispatch.GenericHandler;

class ScriptDispatcher
{
	private ScriptHandler[] handlers;

	public void AddHandler(ScriptHandler handler)
	{
		handlers ~= handler;
	}

	private ScriptHandler GetHandler(string fullpath)
	{
		string ext = extension(fullpath);
		if (ext == null) //Arrrgh... hate this kind of code!?
			ext = ".";

		foreach (handler; handlers)
			if (handler.CanHandle(ext[1..$]))
				return handler;

		throw new ScriptDispatchException(format("Failed to find dispatcher for script extension '%s'", ext));
	}

	public void SanityCheck(string fullpath)
	{
		GetHandler(fullpath).SanityCheck(fullpath);
	}

	public void ValidateHandlerFor(string fullpath)
	{
		GetHandler(fullpath);
	}

	public void Run(string fullpath)
	{
		GetHandler(fullpath).Run(fullpath);
	}
}
