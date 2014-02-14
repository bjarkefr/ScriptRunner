module BackendImpl.MySQL.MySQLConfiguration;

import Configuration.ConfigurationFactory;
import Backend.DBVersionTagger;
import ScriptDispatch.ScriptDispatcher;
import BackendImpl.MySQL.MySQLVersionTagger;

import std.getopt;
import std.stdio;
import std.c.process;

public class MySQLConfigurationFactory : ConfigurationFactory
{
	public override string Name() { return "mysql"; }

	public override DBConfiguration GetConfig(string args[], bool help)
	{
		return new MySQLConfiguration(args, help);
	}
}

public class MySQLConfiguration : DBConfiguration
{
	public string ConnectionString;
	public string VersionTable = "_Version";

	this(string[] args, bool help)
	{
		ConnectionString = null;

		getopt(args, std.getopt.config.caseSensitive,
			   "connection|c", &ConnectionString,
			   "version_table", &VersionTable);

		if(help)
		{
			writeln("    -connection|-c <str> specify the mysql connection string");
			writeln("    -version_table <name> specify name of the verioning table");
			exit(0);
		}

		if(ConnectionString == null)
			throw new ConfigurationException("Missing 'connection'-string parameter");
	}

	public DBVersionTagger GetDBVersionTagger()
	{
		return new MySQLVersionTagger(ConnectionString, VersionTable);
	}

	public ScriptDispatcher GetScriptDispatcher()
	{
		return null;
	}
}
