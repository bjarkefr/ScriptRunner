module ScriptRunner;
import Backend.DBVersionTagger;
import ScriptRepository.FSScriptRepository;
import ScriptDispatch.ScriptDispatcher;

import std.stdio;
import std.string;

public class ScriptRunner
{
	private DBVersionTagger tagger;
	private FSScriptRepository repository;
	private ScriptDispatcher dispatcher;

	public this(DBVersionTagger tagger, FSScriptRepository repository, ScriptDispatcher dispatcher)
	{
		this.tagger = tagger;
		this.repository = repository;
		this.dispatcher = dispatcher;
	}

	public void Go(string tag)
	{
		int targetVersion;
		string[] scripts;
		int startVersion;

		try
		{
			VersionInfo info = tagger.GetInfo();
			startVersion = info.Version;

			writeln(format("Current version of the database is %d, tag '%s'", info.Version, info.Tag));

			scripts = repository.GetOrderedAfter(info.Version, targetVersion);

			foreach(script; scripts)
				dispatcher.ValidateHandlerFor(script);

			if (scripts.length == 0)
			{
				writeln("No new scripts. The database is up to date.");
				writeln(format("Setting database tag '%s'", tag));
				tagger.SetTag(tag);
				return;
			}

			writeln(format("Database will be updated from version %d to version %d", startVersion, targetVersion));
		}
		catch(Exception e)
		{
			writeln("No scripts were run agains the database!");
			throw e;
		}

		for (int newVersion = startVersion + 1; newVersion <= targetVersion; ++newVersion)
		{
			string script = scripts[newVersion - startVersion - 1];
			try
			{
				writeln(format("Sanity checking for script '%s'", script));
				dispatcher.SanityCheck(script);
			}
			catch(Exception e)
			{
				writeln("Exception during sanity check. Update arborted!");
				throw e;
			}
			try
			{
				writeln("Setting database into UPDATE mode:");
				tagger.SetUpdating();
				dispatcher.Run(script);
				tagger.SetDone(newVersion, tag);
				writeln(format("Database sat back into NORMAL mode at version %d", newVersion));
			}
			catch(Exception e)
			{
				writeln("Problem during update of the database...");
				writeln("**** DATABASE IS IN AN UNKNOWN STATE! ****");
				throw e;
			}
		}
	}
}
