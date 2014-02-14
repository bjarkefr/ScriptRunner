module BackendImpl.MySQL.ExternalMySQLHandler;

import ScriptDispatch.GenericHandler;

import std.stdio;
import std.conv;
import std.string;
import std.array;

public class MySQLHandlerException : Exception
{
	this (string message) { super(message); }
}

private static string connectionStringParser(string connection)
{
	auto mysqlArgs = appender!string();
	string[] args = split(connection, ";");
	foreach(arg; args)
	{
		string[] pair = split(arg, "=");
		switch(toLower(pair[0]))
		{
			case "host":
				mysqlArgs.put(" --host=" ~ pair[1]);
				break;
			case "port":
				mysqlArgs.put(" --port=" ~ pair[1]);
				break;
			case "user":
				mysqlArgs.put(" --user=" ~ pair[1]);
				break;
			case "pwd":
				mysqlArgs.put(" --password=" ~ pair[1]);
				break;
			case "db":
				mysqlArgs.put(" --database=" ~ pair[1]);
				break;
			default:
				writeln(format("Warning: unknown connection string key '%s'", pair[0]));
		}
	}

	return mysqlArgs.data;
}

public class ExternalMySQLHandler : GenericHandler
{
	private string arguments;

	public this(string extension, string connection)
	{
		super(extension, "mysql");
		arguments = connectionStringParser(connection);
	}

	public override void SanityCheck(string fullpath)
	{
		super.Run(arguments ~ " --execute \"select 'MySQL launcher connection test success' as Status\"");
	}

	public override void Run(string fullpath)
	{
		super.Run(arguments ~ " --execute \"source " ~ fullpath ~ "\"");
	}
}
