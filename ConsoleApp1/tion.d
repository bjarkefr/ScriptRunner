module Configuration.Configuration;

import std.stdio;
import std.getopt;
import std.c.process;

public class ConfigurationException : Exception
{
	this (string message) { super(message); }
}

public interface DBConfiguration
{
	public string Name();
}

//TODO: Inject configuration parsers for each backend, and delegate parsing and writing of help text to each parser... Each parser will then create its corresponding DBConfiguration
public class Configuration
{
	enum DBBackend { none, mongo, mysql };

	public DBBackend Backend;

	enum ModeType { PrintVersion, RunScripts, InitializeDB, ResetDB };

	public int ResetVersion;

	public ModeType Mode;

	public string ScriptsFolder = ".";

	public string Tag = "<None>";

	public DBConfiguration DBConf;

	this(BackendRegistry registry, string[] args)
	{
		bool help = false, mr = false, mi = false, mf = false;

		DBBackend Backend = DBBackend.none;
		ResetVersion = 0;

		getopt(args, std.getopt.config.caseSensitive | std.getopt.config.passThrough,
			   "help|h", &help,
			   "db_backend|b", &Backend,
			   "mode_run|r", &mr,
			   "mode_init|i", &mi,
			   "mode_force_reset|f", &mf,
			   "reset_version|v", &ResetVersion,
			   "tag", &Tag,
			   "scripts_folder|f", &ScriptsFolder);

		if(Backend == DBBackend.none && help)
		{
			// Generic help
			writeln("Usage: ..."); //TODO: Fixme?
			exit(0);
		}

		int modes = mr ? 1 : 0 + mi ? 1 : 0 + mf ? 1 : 0;
		if(modes > 1)
			throw new ConfigurationException("You can only select one mode.");

		if(mr)
			Mode = ModeType.RunScripts;
		else if(mi)
			Mode = ModeType.InitializeDB;
		else if(mr)
			Mode = ModeType.ResetDB;
		else
			Mode = ModeType.PrintVersion;

		switch(Backend)
		{
			case DBBackend.mongo:
				DBConf = new MongoConfiguration(args);
				break;
			case DBBackend.mysql:
				DBConf = new MySQLConfiguration(args);
				break;
			default:
				throw new ConfigurationException("No database backend selected!?");
		}
	}
}
