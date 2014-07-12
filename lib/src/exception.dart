part of mapper_server;

class TransactionStartedException implements Exception {

    String _msg = 'Transaction already started';

    TransactionStartedException();

    String toString() => _msg;

}

class QueryException implements Exception {

    String _msg;

    String _q;

    QueryException(this._msg, this._q);

    String toString() => _msg + ':\n' + _q;

}