part of mapper_server;

abstract class Application<A extends Application> {

    Manager<A> m;

    Map data = new Map();

    Map _cache = new Map();

    Application(this.data);

    //get(String key, Function f) => (_cache.containsKey(key))? _cache[key] : _cache[key] = f();

    noSuchMethod(Invocation invocation) {
        var key = invocation.memberName;
        return (_cache.containsKey(key))? _cache[key] : _cache[key] = data[key](m);
    }

}