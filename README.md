ScriptRunner
============

Commandline tool to run migration scripts against databases (mongo and mysql only at the moment). The tool perform sanity checking (to catch typical merge mishaps, etc.) and tags the database with appropriate versioning information.

The tool is a complete rewrite of a tool with similar functionality I originally wrote for my workplace. The original tool was written in C# .NET and was used with great succes locally on dev machines as well as for deploy's to mainline and production servers.

It should be noted that this version is written from scratch in D and has received little testing. In addition to that the D database drivers seem early in their development cycle as well. These drivers are however only used for tagging the database with versioning information, not for running the scripts - mongo and mysql console tools are used for actualy script execution.

The tool is written so that it should be fairly simple to:
 - add a new backend for another database
 - adding a new method for running scripts
 - even getting scripts from other sources (at the moment they have to be stored in a filesystem folder).

Note: I'm planning to switch away from using VisualD and make the project a standard dub project.
