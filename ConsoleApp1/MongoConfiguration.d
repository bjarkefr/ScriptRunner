module BackendImpl.MongoDB.MongoConfiguration;

import Configuration.ConfigurationFactory;
import Backend.DBVersionTagger;
import ScriptDispatch.ScriptDispatcher;

import BackendImpl.MongoDB.ExternalMongoHandler;
import BackendImpl.MongoDB.MongoVersionTagger;

import std.getopt;
import std.stdio;
import std.c.process;

public class MongoConfigurationFactory : ConfigurationFactory
{
	public override string Name() { return "mongo"; }

	public override DBConfiguration GetConfig(string args[], bool help)
	{
		return new MongoConfiguration(args, help);
	}
}

public class MongoConfiguration : DBConfiguration
{
	private string ConnectionString;
	private string VersionCollection = "_Version";

	this(string[] args, bool help)
	{
		ConnectionString = null;

		getopt(args, std.getopt.config.caseSensitive,
			   "connection|c", &ConnectionString,
			   "version_collection", &VersionCollection);

		if(help)
		{
			writeln("    -connection|-c <str> specify connection string, e.g. mongodb://localhost/database");
			writeln("    -version_collection <name> specify name of the versioning collection");
			exit(0);
		}

		if(ConnectionString == null)
			throw new ConfigurationException("Missing 'connection'-string parameter");
	}

	public DBVersionTagger GetDBVersionTagger()
	{
		return new MongoVersionTagger(ConnectionString, VersionCollection);
	}

	public ScriptDispatcher GetScriptDispatcher()
	{
		auto dispatcher = new ScriptDispatcher();
		dispatcher.AddHandler(new ExternalMongoHandler("js", ConnectionString));
		return dispatcher;
	}
}
