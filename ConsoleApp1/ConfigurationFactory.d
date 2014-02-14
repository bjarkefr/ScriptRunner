module Configuration.ConfigurationFactory;
import Backend.DBVersionTagger;
import ScriptDispatch.ScriptDispatcher;

import std.string;

public class ConfigurationException : Exception
{
	this (string message) { super(message); }
}

public interface ConfigurationFactory
{
	string Name();
	DBConfiguration GetConfig(string[] args, bool help);
}

public interface DBConfiguration
{
	DBVersionTagger GetDBVersionTagger();
	ScriptDispatcher GetScriptDispatcher();
}

public class ConfigurationFactoryRepo
{
	ConfigurationFactory[string] map;

	public void AddFactory(ConfigurationFactory factory)
	{
		map[factory.Name()] = factory;
	}

	public DBConfiguration GetConfig(string name, string[] args, bool help)
	{
		if(name !in map)
			throw new ConfigurationException(format("Unknown backend '%s' type?", name));

		return map[name].GetConfig(args, help);
	}

	public string[] GetNames()
	{
		return map.keys;
	}
}
