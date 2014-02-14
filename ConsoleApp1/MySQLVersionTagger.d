module BackendImpl.MySQL.MySQLVersionTagger;

import Backend.DBVersionTagger;

import std.conv;
import std.string;
import mysql.connection;

//import std.net.uri; // from the extras section - I took this file directly off MikevanDongen's GitHub page
//import vibe.db.mongo.client;
//import vibe.db.mongo.mongo;
//
//import vibe.data.bson;

//class MongoVersionDoc
//{
//    public static const BsonObjectID Id;
//
//    static this()
//    {
//        Id = BsonObjectID.fromString("50f92bfd2960520c80888326");
//    }
//
//    public BsonObjectID _id;
//
//    public this() {} // Deserialization constructor
//
//    public this(VersionInfo info)
//    {
//        _id = Id;
//        State = to!string(info.State);
//        Tag = info.Tag;
//        Version = info.Version;
//    }
//
//    public VersionInfo toVersionInfo()
//    {
//        return new VersionInfo(Version, to!(VersionInfo.RunState)(State), Tag);
//    }
//
//    public int Version;
//    public string Tag;
//    public string State;
//}

static const int Id = 7704;

public class MySQLVersionTagger : DBVersionTagger
{
	private string table;
	private Connection connection;

	public this(string connection, string table)
	{
		this.connection = new Connection(connection);
		this.table = table;
	}

	private void BindParameters(Command* cmd)
	{

	}

	public override void InitializeDBImpl()
	{
		ulong count;
		//auto command0 = new Command(connection, "drop table _Version");
		//scope(exit) { command0.releaseStatement(); }
		//command0.prepare();
		//command0.execPrepared(count);

		auto command1 = new Command(connection, format("create table %s (Id int not null primary key, Version int not null, State varchar(32) not null, Tag varchar(1024) not null)", table));
		scope(exit) { command1.releaseStatement(); }
		command1.execSQL(count);
		//command1.prepare();
		//command1.execPrepared(count);
		command1.releaseStatement();

		auto command2 = new Command(connection, format("insert into %s (Id, Version, State, Tag) values (?, ?, ?, ?)", table));
		scope(exit) { command2.releaseStatement(); }
		command2.prepare();
		int id = Id;
		command2.bindParameter(id, 0);
		command2.bindParameter(info.Version, 1);
		string state = to!string(info.State);
		command2.bindParameter(state, 2);
		command2.bindParameter(info.Tag, 3);
		command2.execPrepared(count);
		command2.releaseStatement();
	}

	protected override void GetInfoImpl()
	{
		ulong count;

		auto command = new Command(connection, format("select Version, State, Tag from %s where Id=?", table));
		scope(exit) { command.releaseStatement(); }
		command.prepare();
		int id = Id;
		command.bindParameter(id, 0);
		auto result = command.execPreparedResult();
		if (result.empty())
			throw new DBVersioningException(format("Unable to find versioning information in table %s", table));

		Row row = result.front();
		info = new VersionInfo(
			row[0].coerce!int,
			VersionInfo.RunState.OK, //to!VersionInfo.RunState(row[1].coerce!string),
			row[2].coerce!string
			);
	}

	public override void SaveVersionInfo()
	{
		ulong count;
		auto command = new Command(connection, format("update %s set Version=?, State=?, Tag=? where Id=?", table));
		scope(exit) { command.releaseStatement(); }
		command.prepare();
		
		command.bindParameter(info.Version, 0);
		string state = to!string(info.State);
		command.bindParameter(state, 1);
		command.bindParameter(info.Tag, 2);
		int id = Id;
		command.bindParameter(id, 3);

		command.execPrepared(count);
	}
}
