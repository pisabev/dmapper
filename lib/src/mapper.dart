part of mapper;

abstract class Mapper<E extends Entity, C extends Collection<E>, A extends Application> {

    Manager<A> manager;

    String table;

    dynamic pkey;

    List nulls = new List();

    static Map _ref = new Map();

    static const String _SEP = '.';

    Mapper(Manager<A> man) {
        manager = man;
        if (pkey == null)
            pkey = table + '_id';
    }

    Future<E> find(dynamic id) {
        if (id is List)
            return findComposite(id);
        String cache_key = id.toString();
        Future<E> f = _cacheGet(cache_key);
        if (f != null) {
            return f;
        } else {
            return _cacheAdd(cache_key, selectBuilder()
            .where(_escape(pkey) + ' = @pkey')
            .setParameter('pkey', id).stream(_streamToEntityFind));
        }
    }

    Future<E> findComposite(List<dynamic> ids) {
        String cache_key = ids.join(_SEP);
        Future<E> f = _cacheGet(cache_key);
        if (f != null) {
            return f;
        } else {
            Builder q = selectBuilder();
            int i = 0;
            ids.forEach((k) {
                String key = 'pkey' + i.toString();
                q.andWhere(_escape(pkey[i]) + ' = @' + key).setParameter(key, k);
                i++;
            });
            return _cacheAdd(cache_key, q.stream(_streamToEntityFind));
        }
    }

    Future<C> findAll() => loadC(selectBuilder());

    Builder queryBuilder() => new Builder(manager.connection);

    Builder selectBuilder([String select = '*']) => new Builder(manager.connection).select(select).from(_escape(table));

    Builder deleteBuilder() => new Builder(manager.connection).delete(_escape(table));

    Builder insertBuilder() => new Builder(manager.connection).insert(_escape(table));

    Builder updateBuilder() => new Builder(manager.connection).update(_escape(table));

    Future<E> loadE(Builder builder) => builder.stream(_streamToEntity);

    Future<C> loadC(Builder builder) => builder.stream(_streamToCollection);

    Future<E> insert(E object) {
        Map data = object.toMap();
        return _setUpdateData(insertBuilder(), data, true)
        .execute().then((result) {
            object.init(_reMapResult(result[0]));
            return _cacheAdd(_cacheKeyFromData(data), new Future.value(object));
        });
    }

    Future<E> update(E object) {
        Map data = object.toMap();
        Builder q = _setUpdateData(updateBuilder(), data);
        if (pkey is List)
            pkey.forEach((k) => q.andWhere(_escape(k) + ' = @' + k).setParameter(k, data[k]));
        else
            q.andWhere(_escape(pkey) + ' = @' + pkey).setParameter(pkey, data[pkey]);
        return q.stream((stream) => stream.drain(object));
    }

    Future<bool> delete(E object) {
        Map data = object.toMap();
        if(pkey is List)
            return deleteComposite(pkey.map((k) => data[k]));
        else
            return deleteById(data[pkey]);
    }

    Future<bool> deleteById(dynamic id) {
        _cacheAdd(id.toString(), new Future.value(null));
        return deleteBuilder()
        .where(_escape(pkey) + ' = @' + pkey).setParameter(pkey, id)
        .stream((stream) => stream.drain(true));
    }

    Future<bool> deleteComposite(Iterable<dynamic> ids) {
        _cacheAdd(ids.join(_SEP), new Future.value(null));
        Builder q = deleteBuilder();
        int i = 0;
        ids.forEach((k) {
            String key = 'pkey' + i.toString();
            q.andWhere(_escape(pkey[i]) + ' = @' + key).setParameter(key, k);
            i++;
        });
        return q.stream((stream) => stream.drain(true));
    }

    Builder _setUpdateData(Builder builder, data, [bool insert = false]) {
        data.forEach((k, v) {
            if (v == null) {
                if (insert)
                    builder.set(_escape(k), 'DEFAULT');
                else if (nulls.contains(k))
                    builder.set(_escape(k), '@' + k).setParameter(k, v);
            } else {
                builder.set(_escape(k), '@' + k).setParameter(k, v);
            }
        });
        return builder;
    }

    /*Builder _setUpdateData(Builder builder, data, [bool insert = false]) {
        data.forEach((k, v) {
            if (v == null && insert)
                builder.set(_escape(k), 'DEFAULT');
            else
                builder.set(_escape(k), '@' + k).setParameter(k, v);
        });
        return builder;
    }*/

    Future<E> _onStreamRow(row) {
        Map data = _reMapResult(row);
        String key = _cacheKeyFromData(data);
        Future<E> f = _cacheGet(key);
        return (f == null)? _cacheAdd(key, new Future.value(createObject(data))) : f;
    }

    Future<E> _streamToEntityFind(Stream stream) {
        return stream.map((row) => createObject(_reMapResult(row)))
        .toList()
        .then((list) => (list.length > 0)? list[0] : null);
    }

    Future<E> _streamToEntity(Stream stream) {
        return stream.map(_onStreamRow)
        .toList()
        .then(Future.wait)
        .then((list) => (list.length > 0)? list[0] : null);
    }

    Future<C> _streamToCollection(Stream stream) {
        return stream.map(_onStreamRow)
        .toList()
        .then(Future.wait)
        .then((list) {
            C col = createCollection();
            col.addAll(list);
            return col;
        });
    }

    E markObject(E object) {
        _ref[object.runtimeType.toString()] = this;
        return object;
    }

    Map _reMapResult(data) {
        Map d = new Map();
        data.forEach((k, v) => d[k] = v);
        return d;
    }

    String _cacheKeyFromData(Map data) {
        return (pkey is List)?
            pkey.map((k) => data[k]).join(_SEP) :
            data[pkey].toString();
    }

    Future<E> _cacheAdd(String k, Future<E> f) {
        manager.cacheAdd(this.runtimeType.toString() + k, f);
        return f;
    }

    Future<E> _cacheGet(String k) {
        return manager.cacheGet(this.runtimeType.toString() + k);
    }

    CollectionBuilder<E, C, A> collectionBuilder([Builder q]) {
        if (q == null)
            q = selectBuilder();
        return new CollectionBuilder(q, this);
    }

    _escape(String string) => '"$string"';

    E createObject([dynamic data]);

    E mergeData(E object, Map data) {
        Map m = object.toMap();
        m.addAll(data);
        return object;
    }

    C createCollection();

}