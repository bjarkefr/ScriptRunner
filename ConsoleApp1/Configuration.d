module Configuration.Configuration;

import Configuration.ConfigurationFactory;

import std.stdio;
import std.getopt;
import std.c.process;
import std.array;
import std.string;

//TODO: Inject configuration parsers for each backend, and delegate parsing and writing of help text to each parser... Each parser will then create its corresponding DBConfiguration
public class ConfigurationImpl
{
	enum ModeType { PrintVersion, RunScripts, InitializeDB, ResetDB };

	public int ResetVersion;

	public ModeType Mode = ModeType.PrintVersion;

	public string ScriptsFolder = ".";

	public string Tag = "<None>";

	public DBConfiguration DBConf;

	this(ConfigurationFactoryRepo repo, string[] args)
	{
		bool help = false, mr = false, mi = false, mf = false;

		ResetVersion = 0;
		string backend = null;

		getopt(args, std.getopt.config.caseSensitive | std.getopt.config.passThrough,
			   "help|h", &help,
			   "db_backend|b", &backend,
			   "mode_run|r", &mr,
			   "mode_init|i", &mi,
			   "mode_force_reset|f", &mf,
			   "reset_version|v", &ResetVersion,
			   "tag", &Tag,
			   "scripts_folder|f", &ScriptsFolder);

		if(backend is null && help)
		{
			writeln("script_runner v1.0");
			writeln("  --help|-h print this help text");
			writeln(format("  --db_backend|-b [%s] select specific database backend", join(repo.GetNames(), "|")));
			writeln("    --help|-h when used with -d print backend specific help text");
			writeln("  --mode_run|-r instructs the tool to run versioned scripts");
			writeln("    --tag <str> when used with -r the database is tagged with <str>");
			writeln("	 --scripts_folder|-f specify scripts folder");
			writeln("  --mode_init|-i instructs the tool to (re)initialize the database's versioning information");
			writeln("  --mode_force_reset|-f instructs the tool to set the database versioning info back into normal mode at version 0");
			writeln("    --reser_version|-v specify verion other than 0 for the -f switch");
			writeln("  no mode will print database version information on the console");
			exit(0);
		}

		if (backend is null)
			throw new ConfigurationException("You must specify a backend");

		int modes = mr ? 1 : 0 + mi ? 1 : 0 + mf ? 1 : 0;
		if(modes > 1)
			throw new ConfigurationException("You can only select one mode");

		if(mr)
			Mode = ModeType.RunScripts;
		else if(mi)
			Mode = ModeType.InitializeDB;
		else if(mr)
			Mode = ModeType.ResetDB;
		else
			Mode = ModeType.PrintVersion;

		if (help)
		{
			writeln("script_runner v1.0");
			writeln(format("  %s backend", backend));
		}

		DBConf = repo.GetConfig(backend, args, help);
	}
}
