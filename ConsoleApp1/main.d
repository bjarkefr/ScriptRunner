import Configuration.Configuration;
import ScriptRepository.FSScriptRepository;
import BackendImpl.MongoDB.MongoVersionTagger;
import Backend.DBVersionTagger;
import Configuration.ConfigurationFactory;
import ScriptDispatch.ScriptDispatcher;
import ScriptRunner;
import DBTools;

import BackendImpl.MongoDB.MongoConfiguration;
import BackendImpl.MySQL.MySQLConfiguration;

import std.file;
import std.string;
import std.stdio;


int main(string[] argv)
{
	try
	{
		ConfigurationFactoryRepo configRepo = new ConfigurationFactoryRepo();

		ConfigurationFactory mongoConfigFactory = new MongoConfigurationFactory();
		configRepo.AddFactory(mongoConfigFactory);

		ConfigurationFactory mysqlConfigFactory = new MySQLConfigurationFactory();
		configRepo.AddFactory(mysqlConfigFactory);

		ConfigurationImpl config = new ConfigurationImpl(configRepo, argv);

		DBVersionTagger tagger = config.DBConf.GetDBVersionTagger();
		ScriptDispatcher dispatcher = config.DBConf.GetScriptDispatcher();

		FSScriptRepository repository = new FSScriptRepository(config.ScriptsFolder);

		switch(config.Mode)
		{
			case ConfigurationImpl.ModeType.RunScripts:
				{
					ScriptRunner runner = new ScriptRunner(tagger, repository, dispatcher);
					runner.Go(config.Tag);
				}
				break;
			case ConfigurationImpl.ModeType.InitializeDB:
				{
					DBTools tools = new DBTools(tagger);
					tools.InitializeDB();
				}
				break;
			case ConfigurationImpl.ModeType.PrintVersion:
				{
					DBTools tools = new DBTools(tagger);
					tools.PrintInfo();
				}
				break;
			case ConfigurationImpl.ModeType.ResetDB:
				{
					DBTools tools = new DBTools(tagger);
					tools.ForceNormalMode(config.ResetVersion);
				}
				break;
			default:
				throw new Exception("Operation not implemented!");
		}
	}
	catch (Exception e)
	{
		writeln(e.msg);
		return -1;
	}

    return 0;
}
