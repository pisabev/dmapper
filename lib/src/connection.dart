part of mapper_server;

class Connection {

    String _uri;

    int _min, _max;

    Pool _pool;

    Connection(this._uri, [this._min = 1, int this._max = 5]) {
        _createPool();
    }

    _createPool() => _pool = new Pool(_uri, min: _min, max: _max);

    Future connect() {
        return _pool.connect()
        /*.timeout(new Duration(milliseconds:500), onTimeout:() {
            _pool.destroy();
            _createPool();
            log.warning('pool destroyed (probably connections leak)');
            return connect();
        })*/
        .catchError((e) => log.severe(e));
    }

}