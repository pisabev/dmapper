part of mapper;

class Unit {

    Manager _manager;

    List<Entity> _dirty;

    List<Entity> _new;

    List<Entity> _delete;

    List<Future> _future;

    bool _started = false;

    bool get started => _started;

    Future _transaction;

    Unit(Manager manager) {
        _manager = manager;
        _set();
    }

    _set() {
        _dirty = new List<Entity>();
        _new = new List<Entity>();
        _delete = new List<Entity>();
        _future = new List<Future>();
        _transaction = null;
    }

    addDirty(Entity object) => (!_new.contains(object) && !_dirty.contains(object))? _dirty.add(object) : null;

    addNew(Entity object) => (!_new.contains(object))? _new.add(object) : null;

    addDelete(Entity object) => (!_delete.contains(object))? _delete.add(object): null;

    addFuture(Future f) => (!_future.contains(f))? _future.add(f) : null;

    Future _doUpdates() => Future.wait(_dirty.map((o) => _manager._mapper(o).update(o)));

    Future _doInserts() => Future.wait(_new.map((o) => _manager._mapper(o).insert(o)));

    Future _doDeletes() => Future.wait(_delete.map((o) => _manager._mapper(o).delete(o)));

    Future _doFutures() => Future.wait(_future);

    Future _begin() => _manager.connection.execute('BEGIN').then((_) => _started = true);

    Future _commit() => _manager.connection.execute('COMMIT').then((_) => _started = false);

    Future _rollback() => _manager.connection.execute('ROLLBACK').then((_) => _started = false);

    Future _start() => (!_started) ? _begin() : new Future.value();

    Future persist() {
        if(_transaction != null)
            throw new TransactionStartedException();
        return _transaction = _start()
        .then((_) => _doFutures())
        .then((_) => _doDeletes())
        .then((_) => _doUpdates())
        .then((_) => _doInserts())
        .then((_) => _set())
        .catchError((e) => _rollback().then((_) => throw e));
    }

    Future commit() {
        return persist()
        .then((_) => _commit())
        .catchError((e) => _rollback().then((_) => throw e));
    }

    Future begin() => _start();

    Future rollback() => _rollback();

}