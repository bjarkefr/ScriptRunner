module Backend.DBVersionTagger;

public class DBVersioningException : Exception //TODO: Make generic and move to DBVersioning namespace
{
	this(string message) { super(message); }
}

public class VersionInfo
{
	public this(int _version, RunState state, string tag)
	{
		Version = _version;
		State = state;
		Tag = tag;
	}

	public this()
	{
		State = RunState.OK;
		Tag = "None";
		Version = 0;
	}

	public enum RunState { OK, UPDATING	}
	public int Version;
	public string Tag;
	public RunState State;
}

abstract class DBVersionTagger
{
	protected VersionInfo info;

	protected void InitializeDBImpl();

	public void InitializeDB()
	{
		info = new VersionInfo();
		InitializeDBImpl();
	}

	protected void GetInfoImpl();

	public VersionInfo GetInfo(bool ignoreState = false)
	{
		GetInfoImpl();

		if(!ignoreState && info.State != VersionInfo.RunState.OK)
			throw new DBVersioningException("Database is in UNCLEAN update state. This typically means that the ScriptRunner has previosly crashed and that the database is in an UNKNOWN state.");

		return info;
	}

	protected void SaveVersionInfo();

	public void SetUpdating()
	{
		info.State = VersionInfo.RunState.UPDATING;
		SaveVersionInfo();
	}

	public void SetDone(int _version, string tag)
	{
		if(_version < info.Version)
			throw new DBVersioningException("Version information is invalid");

		info.Version = _version;
		info.State = VersionInfo.RunState.OK;
		info.Tag = tag;
		SaveVersionInfo();
	}

	public void ForceNormalMode(int _version)
	{
		info = new VersionInfo(_version, VersionInfo.RunState.OK, "Force");
		SaveVersionInfo();
	}

	public void SetTag(string tag)
	{
		info.Tag = tag;
		SaveVersionInfo();
	}
}
