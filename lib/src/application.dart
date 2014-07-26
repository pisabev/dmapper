part of mapper_server;

abstract class Application<A extends Application> {

    Manager<A> m;

    Map _cache = new Map();

    get(String key, Function f) => (_cache.containsKey(key))? _cache[key] : _cache[key] = f();

}