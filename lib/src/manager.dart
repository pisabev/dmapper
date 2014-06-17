part of mapper;

class Manager<A extends Application> {

    A app;

    Unit _unit;

    Cache _cache;

    Connection _connection;

    var connection;

    Map session;

    Manager(Connection conn, A application) {
        _unit = new Unit(this);
        _cache = new Cache();
        _connection = conn;
        app = application;
        //app = application.init();
        app.m = this;
    }


    /*static Manager instance;
    factory Manager(Connection conn, A application) {
        if(instance == null)
            instance = new Manager._(conn, application);
        return instance;
    }
    Manager._(Connection conn, A application) {
        _unit = new Unit(this);
        _cache = new Cache();
        _connection = conn;
        app = application;
        //app = application.init();
        app.m = this;
    }*/

    Future<Manager> init() {
        return _connection.connect().then((c) {
            print(_connection._pool);
            connection = c;
            return this;
        });
    }

    /*Future<Manager> init() {
        return new Future.value(this);
    }*/


    void destroy() => _connection._pool.destroy();

    Future query(query, [params]) => connection.query(query, params).toList();

    /*Future query(query, [params]) {
        Completer completer = new Completer();
        connection.connect().then((con) {
            con.query(query, params)
            .toList()
            .then(completer.complete)
            .then((_) => con.close());
        });
        return completer.future;
    }

    Future execute(query, [params]) {
        Completer completer = new Completer();
        connection.connect().then((con) {
            con.execute(query, params)
            .then(completer.complete)
            .then((_) => con.close());
        });
        return completer.future;
    }*/

    builder() => new Builder(connection);

    cacheAdd(String key, Future<Entity> object) => _cache.add(key, object);

    cacheGet(String key) => _cache.get(key);

    cache() => _cache.toString();

    addDirty(Entity object) => _unit.addDirty(object);

    addNew(Entity object) => _unit.addNew(object);

    addDelete(Entity object) => _unit.addDelete(object);

    addFuture(Future f) => _unit.addFuture(f);

    Future persist() => _unit.persist();

    Future commit() => _unit.commit();

    Future begin() => _unit.begin();

    Future rollback() => _unit.rollback();

    bool inTransaction() => _unit.started;

    Future close() {
        return new Future.sync(() {
            if(_unit.started)
                return _unit.rollback().then((_) => connection.close());
            return connection.close();
        });
    }

    Mapper _mapper(Entity object) => Mapper._ref[object.runtimeType.toString()];

}