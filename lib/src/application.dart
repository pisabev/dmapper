part of mapper_server;

class Application<A extends Application> {

    Manager<A> m;

    Map _data = new Map();

    Map _cache = new Map();

    Application(Map data) {
        data.forEach((k, v) => _data[new Symbol(k)] = v);
    }

    noSuchMethod(Invocation invocation) {
        var key = invocation.memberName;
        if(invocation.isGetter)
            return (_cache.containsKey(key))? _cache[key] : _cache[key] = _data[key](m);
        super.noSuchMethod(invocation);
    }

}