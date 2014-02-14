module BackendImpl.MongoDB.ExternalMongoHandler;

import ScriptDispatch.GenericHandler;
import std.net.uri; // from the extras section - I took this file directly off MikevanDongen's GitHub page

public class MongoHandlerException : Exception
{
	this (string message) { super(message); }
}

public class ExternalMongoHandler : GenericHandler
{
	private static string connWithoutScheme(URI conn)
	{
		URI noScheme = URI();

		noScheme.host = conn.host;
		noScheme.port = conn.port;
		noScheme.rawPath = conn.rawPath;
		noScheme.rawQuery = conn.rawQuery;
		
		return noScheme.toString()[3..$];
	}

	private static getTemplate(string conn)
	{
		URI uri = URI(conn);
		if (uri.scheme != "mongodb")
			throw new MongoHandlerException("Invalid mongo connection string scheme.");

		string mongoTemp = connWithoutScheme(uri);
		
		if (uri.username.length > 0)
			mongoTemp ~= " -u " ~ uri.username;

		if (uri.password.length > 0)
			mongoTemp ~= " -p " ~ uri.password;

		return mongoTemp ~ " %s";
	}

	this(string extension, string conn)
	{
		super(extension, "mongo", getTemplate(conn));
	}

	public override void SanityCheck(string fullpath)
	{
		super.Run("--eval \"print('Mongo launcher connection test success')\"");
	}

	public override void Run(string fullpath)
	{
		super.Run("\"" ~ fullpath ~ "\"");
	}
}