part of mapper;

class Connection {

    String uri;

    Pool _pool;

    Connection(String u, [int min = 1, int max = 5]) {
        uri = u;
        _pool = new Pool(uri, min: min, max: 2);
    }

    Future connect() {
        return _pool.connect()
        .catchError((e) => print(e));
    }

}