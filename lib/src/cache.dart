part of mapper;

class Cache {

    Map _cache = new Map();

    add(String key, Future<Entity> object) => _cache[key] = object;

    get(String key) => (_cache.containsKey(key))? _cache[key] : null;

    toString() =>_cache.toString();

}