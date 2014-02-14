//module Backend.BackendRepo;
//
//import Configuration.ConfigurationFactory;
//import Backend.DBVersionTagger;
//import ScriptDispatch.GenericHandler;
//import std.typecons;
//
//public class BackendRepo
//{
//    private Tuple!(DBVersionTagger, ScriptHandler)[string] map;
//
//    public ConfigurationFactoryRepo ConfigRepo;
//
//    public this(ConfigurationFactoryRepo configRepo)
//    {
//        ConfigRepo = configRepo;
//    }
//
//    public Tuple!(DBVersionTagger, ScriptHandler) GetBackend(DBConfiguration config)
//    {
//        return map[config.Name()];
//    }
//
//    public void AddBackend(ConfigurationFactory config, DBVersionTagger tagger, ScriptHandler handler)
//    {
//        ConfigRepo.AddFactory(config);
//        map[config.Name()] = Tuple!(DBVersionTagger, ScriptHandler)(tagger, handler);
//    }
//}