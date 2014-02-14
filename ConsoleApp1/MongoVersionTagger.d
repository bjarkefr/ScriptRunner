module BackendImpl.MongoDB.MongoVersionTagger;
import Backend.DBVersionTagger;

import std.net.uri; // from the extras section - I took this file directly off MikevanDongen's GitHub page
import vibe.db.mongo.client;
import vibe.db.mongo.mongo;

import vibe.data.bson;

class MongoVersionDoc
{
	public static const BsonObjectID Id;

	static this()
	{
		Id = BsonObjectID.fromString("50f92bfd2960520c80888326");
	}

	public BsonObjectID _id;

	public this() {} // Deserialization constructor

	public this(VersionInfo info)
	{
		_id = Id;
		State = to!string(info.State);
		Tag = info.Tag;
		Version = info.Version;
	}

	public VersionInfo toVersionInfo()
	{
		return new VersionInfo(Version, to!(VersionInfo.RunState)(State), Tag);
	}

	public int Version;
	public string Tag;
	public string State;
}

public class MongoVersionTagger : DBVersionTagger
{
	private string collection;
	private MongoDatabase database;
	private MongoCollection versionCollection;

	public this(string connection, string collection)
	{
		auto paths = URI(connection).path;
		if (paths.length != 1)
		    throw new DBVersioningException("Missing database name in mongodb connection string");
		
		string database = paths[0];

		this.database = connectMongoDB(connection).getDatabase(database);
		this.collection = collection;
	}

	public override void InitializeDBImpl()
	{
		MongoCollection col = database[collection];
		col.remove([ "_id": MongoVersionDoc.Id ]);
		col.insert(new MongoVersionDoc(info));
	}

	protected override void GetInfoImpl()
	{
		MongoCollection col = database[collection]; // Would have been nice to check if the collection exists, but the vibe.d mongo driver is a litte limited - and using a non-existing collection is not an error in MongoDB.

		auto doc = col.findOne([ "_id": MongoVersionDoc.Id ]);
		if(doc.isNull())
			throw new DBVersioningException("Unable to find versioning document");

		info = deserializeBson!MongoVersionDoc(doc).toVersionInfo();
	}

	public override void SaveVersionInfo()
	{
		MongoCollection col = database[collection];
		col.update([ "_id": MongoVersionDoc.Id ], new MongoVersionDoc(info));
	}
}
