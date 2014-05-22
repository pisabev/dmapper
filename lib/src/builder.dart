part of mapper;

class Expression {
    String _type = '';

    List _parts = <String>[];

    Expression(String type, List parts) {
        _type = type;
        addMultiple(parts);
    }

    addMultiple(List parts) {
        parts.forEach((part) => add(part));
    }

    add(dynamic part) {
        if (part != '' || (part is Expression && part.count() > 0))
            _parts.add(part);
    }

    count() {
        return _parts.length;
    }

    toString() {
        if (_parts.length == 1)
            return _parts[0].toString();
        return '(' + _parts.join(') ' + _type + ' (') + ')';
    }

    getType() {
        return _type;
    }
}

class Builder {

    static const int SELECT = 0;

    static const int DELETE = 1;

    static const int INSERT = 2;

    static const int UPDATE = 3;

    var connection;

    String _sql = '';

    int _limit = 0;

    int _offset = 0;

    int _type = Builder.SELECT;

    Map _params = <String, dynamic> {
    };

    Map _sqlParts = <String, dynamic> {
        'select': new List(),
        'from': new List(),
        'join': new List(),
        'set': new List(),
        'where': '',
        'groupBy': new List(),
        'having': '',
        'orderBy': new List()
    };

    Builder(this.connection);

    _error(e) => throw new QueryException(e.toString(), getSQL());

    Future execute() {
        return connection
        .query(getSQL(), _params)
        .toList()
        .catchError(_error);
    }

    Future stream(Function handler) {
        return handler(connection.query(getSQL(), _params))
        .catchError(_error);
    }

    /*Future execute() {
        Completer completer = new Completer();
        connection.connect().then((con) {
            con.query(getSQL(), _params)
            .toList()
            .then(completer.complete)
            .then((_) => con.close())
            .catchError((e) => completer.completeError(_error(e)));
        });
        return completer.future;
    }

    Future stream(Function handler) {
        Completer completer = new Completer();
        connection.connect().then((con) {
            return handler(con.query(getSQL(), _params))
            .then(completer.complete)
            .then((_) => con.close())
            .catchError((e) => completer.completeError(_error(e)));
        });
        return completer.future;
    }*/

    getType() {
        return _type;
    }

    setParameter(String key, dynamic value) {
        _params[key] = value;
        return this;
    }

    setParameters(Map<String, String> params) {
        _params = params;
        return this;
    }

    getParameters() {
        return _params;
    }

    getParameter(key) {
        return (_params[key] != null) ? _params[key] : null;
    }

    getSQL() {
        if (_sql != '') {
            return _sql;
        }

        var sql = '';

        switch (_type) {
            case SELECT:
                sql = _getSQLForSelect();
                break;
            case DELETE:
                sql = _getSQLForDelete();
                break;
            case INSERT:
                sql = _getSQLForInsert();
                break;
            case UPDATE:
                sql = _getSQLForUpdate();
                break;
        }

        _sql = sql;
        return sql;
    }

    offset(int offset) {
        _offset = offset;
        return this;
    }

    getOffset() {
        return _offset;
    }

    limit(int limit) {
        _limit = limit;
        return this;
    }

    getLimit() {
        return _limit;
    }

    add(String sqlPartName, dynamic sqlPart, [bool append = false]) {
        if ((sqlPart is String && sqlPart == '') || (sqlPart is Map && sqlPart.isEmpty)) return this;
        if (append) {
            _sqlParts[sqlPartName].add(sqlPart);
        } else {
            _sqlParts[sqlPartName] = sqlPart;
        }
        return this;
    }

    select(String select) {
        _sqlParts['select'] = new List();
        return addSelect(select);
    }

    addSelect(String select) {
        _type = Builder.SELECT;
        return this.add('select', select, true);
    }

    delete(String del) {
        _type = Builder.DELETE;
        return this.add('from', del, true);
    }

    insert(String update) {
        _type = Builder.INSERT;
        return this.add('from', update, true);
    }

    update(String update) {
        _type = Builder.UPDATE;
        return this.add('from', update, true);
    }

    from(String from) {
        return this.add('from', from, true);
    }

    join(String joinTable, String condition) {
        return innerJoin(joinTable, condition);
    }

    innerJoin(String joinTable, String condition) {
        return this.add('join', {
            'joinType' : 'INNER',
            'joinTable' : joinTable,
            'joinCondition' : condition
        }, true);
    }

    leftJoin(String joinTable, String condition) {
        return this.add('join', {
            'joinType' : 'LEFT',
            'joinTable' : joinTable,
            'joinCondition' : condition
        }, true);
    }

    rightJoin(String joinTable, String condition) {
        return this.add('join', {
            'joinType' : 'RIGHT',
            'joinTable' : joinTable,
            'joinCondition' : condition
        }, true);
    }

    set(String key, dynamic value) {
        return this.add('set', {
            key: value
        }, true);
    }

    where(String where, [String where2 = '']) {
        if (where2 != '') where = new Expression('AND', [where, where2]).toString();
        return this.add('where', where);
    }

    andWhere(String where) {
        return _exprBuilder('where', where, 'AND');
    }

    orWhere(String where) {
        return _exprBuilder('where', where, 'OR');
    }

    groupBy(String groupBy) {
        return addGroupBy(groupBy);
    }

    addGroupBy(String groupBy) {
        return this.add('groupBy', groupBy, true);
    }

    having(String having, [String having2 = '']) {
        if (having2 != '') having = new Expression('AND', [having, having2]).toString();
        return this.add('having', having);
    }

    andHaving(String having) {
        return _exprBuilder('having', having, 'AND');
    }

    orHaving(String having) {
        return _exprBuilder('having', having, 'OR');
    }

    orderBy(String sort, [String order = 'ASC']) {
        return this.add('orderBy', sort + ' ' + order, true);
    }

    addOrderBy(String sort, [String order = 'ASC']) {
        return this.add('orderBy', sort + ' ' + order, true);
    }

    setQueryPart(String queryPartName, dynamic queryPart) {
        _sqlParts[queryPartName] = queryPart;
        return this;
    }

    getQueryPart(String queryPartName) {
        return _sqlParts[queryPartName];
    }

    getQueryParts() {
        Map res = <String, dynamic>{};
        _sqlParts.forEach((k, v) => res[k] = v);
        return res;
    }

    resetQueryParts(List queryPartNames) {
        if (queryPartNames.length == 0) {
            var queryPartNames = [];
            _sqlParts.forEach((k, v) => queryPartNames.add(k));
        }
        queryPartNames.forEach((e) => resetQueryPart(e));
        return this;
    }

    resetQueryPart(String queryPartName) {
        _sqlParts[queryPartName] = (_sqlParts[queryPartName] is List) ? [] : '';
        _sql = '';
        return this;
    }

    isJoinPresent(String joinTable) {
        List joins = getQueryPart('join');
        for (int i = 0; i < joins.length; i++)
            if(joins[i]['joinTable'] == joinTable)
                return true;
        return false;
    }

    _exprBuilder(String key, args, type, [bool append = false]) {
        var expr = this.getQueryPart(key);
        expr = (new Expression(type, [expr, args])).toString();
        return this.add(key, expr, append);
    }

    _getSQLForSelect() {
        StringBuffer sb = new StringBuffer()
            ..write('SELECT ')
            ..writeAll(_sqlParts['select'], ', ')
            ..write('\n FROM ')
            ..writeAll(_sqlParts['from'], ', ');
        if(_sqlParts['join'].length > 0) {
            _sqlParts['join'].forEach((e) {
                sb.write('\n ');
                sb.write(e['joinType']);
                sb.write(' JOIN ');
                sb.write(e['joinTable']);
                sb.write(' ON ');
                sb.write(e['joinCondition']);
            });
        }
        if(_sqlParts['where'] != '') {
            sb.write('\n WHERE ');
            sb.write(_sqlParts['where']);
        }
        if(_sqlParts['groupBy'].length > 0) {
            sb.write('\n GROUP BY ');
            sb.writeAll(_sqlParts['groupBy'], ', ');
        }
        if(_sqlParts['having'] != '') {
            sb.write('\n HAVING ');
            sb.write(_sqlParts['having']);
        }
        if(_sqlParts['orderBy'].length > 0) {
            sb.write('\n ORDER BY ');
            sb.writeAll(_sqlParts['orderBy'], ', ');
        }
        if (_limit > 0) {
            sb.write('\n LIMIT ' + _limit.toString());
            if (_offset > 0)
                sb.write(' OFFSET ' + _offset.toString());
        }
        return sb.toString();
    }

    _getSQLForUpdate() {
        List pairs = new List();
        _sqlParts['set'].forEach((s) {
            s.forEach((k, v) {
                pairs.add(k + ' = ' + v);
            });
        });
        StringBuffer sb = new StringBuffer()
            ..write('UPDATE ')
            ..write(_sqlParts['from'][0])
            ..write(' SET ')
            ..writeAll(pairs, ', ');
        if(_sqlParts['where'] != '') {
            sb.write('\n WHERE ');
            sb.write(_sqlParts['where']);
        }
        return sb.toString();
    }

    _getSQLForInsert() {
        List columns = new List();
        List values = new List();
        _sqlParts['set'].forEach((s) {
            s.forEach((k, v) {
                columns.add(k);
                values.add(v);
            });
        });
        StringBuffer sb = new StringBuffer()
            ..write('INSERT INTO ')
            ..write(_sqlParts['from'][0])
            ..write(' (')
            ..writeAll(columns, ', ')
            ..write(') VALUES (')
            ..writeAll(values, ', ')
            ..write(') RETURNING *');
        return sb.toString();
    }

    _getSQLForDelete() {
        StringBuffer sb = new StringBuffer()
            ..write('DELETE FROM ')
            ..write(_sqlParts['from'][0]);
        if(_sqlParts['where'] != '') {
            sb.write('\n WHERE ');
            sb.write(_sqlParts['where']);
        }
        return sb.toString();
    }

    clone() {
        Builder clone = new Builder(connection);
        _sqlParts.forEach((k, v) {
            if(v is List)
                v.forEach((s) => clone._sqlParts[k].add(s));
            else
                clone._sqlParts[k] = v;
        });
        clone._limit = _limit;
        clone._offset = _offset;
        return clone;
    }

    cloneFilter() {
        Builder clone = new Builder(connection);
        ['join', 'where', 'having'].forEach((k) {
            var v = _sqlParts[k];
            if(v is List)
                v.forEach((s) => clone._sqlParts[k].add(s));
            else
                clone._sqlParts[k] = v;
        });
        return clone;
    }

    toString() {
        return getSQL();
    }
}

class CollectionBuilder<E extends Entity, C extends Collection<E>, A extends Application> {

    static int _unique = 0;

    Builder query;

    Mapper<E, C, A> mapper;

    Map filter = new Map();

    Map filter_way = new Map();

    Map filter_map = new Map();

    String order_field = '';

    String order_way = '';

    int _page = 0;

    int _limit = 0;

    int total;

    C collection;

    CollectionBuilder(Builder q, Mapper<E, C, A> m) {
        query = q;
        mapper = m;
    }

    set limit(int limit) => _limit = limit;

    set page(int page) => _page = (page > 0) ? page : 0;

    order(String order, [String way = 'ASC']) {
        if (order != null) {
            order_field = order;
            order_way = way;
        }
    }

    Future process([total = false]) {
        _queryFilter();
        List list = new List();
        if (total)
            list.add(_total());
        _queryResult();
        list.add(_execute());
        return Future.wait(list).then((_) => this);
    }

    void _queryFilter() {
        filter.forEach((k, value) {
            if (value != null) {
                filter_way.forEach((way, List a) {
                    if (a.contains(k)) {
                        var key = k;
                        if (filter_map[k] != null)
                            key = filter_map[k];
                        _set(way, key, value);
                    }
                });
            }
        });
    }

    void _queryResult() {
        if (_limit != null) {
            query.limit(_limit);
            if (_page > 0)
                query.offset((_page - 1) * _limit);
        }
        if (order_field != '') {
            String k = order_field;
            if (filter_map[k] != null)
                k = filter_map[k];
            query.orderBy(k, order_way);
        }
    }

    Future _total() {
        return new Builder(query.connection)
        .select('COUNT(*) AS total')
        .from('(' + query._getSQLForSelect() + ') c')
        .setParameters(query.getParameters())
        .execute().then((result) => total = result[0].total);
    }

    Future _execute() => mapper.loadC(query).then((col) => collection = col);

    _set(String way, String key, dynamic value) {
        String ph = _cleanPlaceHolder(key);
        switch (way) {
            case 'eq':
                query.andWhere(key + ' = @' + ph).setParameter(ph, value);
                break;
            case 'gt':
                query.andWhere(key + ' > @' + ph).setParameter(ph, value);
                break;
            case 'lt':
                query.andWhere(key + ' < @' + ph).setParameter(ph, value);
                break;
            case 'gte':
                query.andWhere(key + ' >= @' + ph).setParameter(ph, value);
                break;
            case 'lte':
                query.andWhere(key + ' <= @' + ph).setParameter(ph, value);
                break;
            case 'like':
                query.andWhere('CAST($key AS text) ILIKE @' + ph).setParameter(ph, '%$value%');
                break;
            case 'rlike':
                query.andWhere('CAST($key AS text) ILIKE @' + ph).setParameter(ph, '%$value');
                break;
            case 'llike':
                query.andWhere('CAST($key AS text) ILIKE @' + ph).setParameter(ph, '$value%');
                break;
            case 'date':
                if(value is List) {
                    if (value[0] != null) {
                        DateTime from = DateTime.parse(value[0]);
                        query.andWhere(key + ' >= @date_from').setParameter('date_from', from);
                    }
                    if (value[1] != null) {
                        DateTime to = DateTime.parse(value[1]);
                        query.andWhere(key + ' <= @date_to').setParameter('date_to', to);
                    }
                }
                break;
        }
    }

    _cleanPlaceHolder(String key) {
        return key.replaceAll(new RegExp(r'\.'), '_') + (++_unique).toString();
    }

}