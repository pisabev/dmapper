part of test;

querySelector() {
    expect(new Builder(manager.connection).select('dummy').from('table').toString(),
    'SELECT dummy\n FROM table');
    expect(new Builder(manager.connection).select('dummy').from('table').orderBy('field').toString(),
    'SELECT dummy\n FROM table\n ORDER BY field ASC');
    expect(new Builder(manager.connection).select('dummy').from('table').orderBy('field', 'DESC').toString(),
    'SELECT dummy\n FROM table\n ORDER BY field DESC');
    expect(new Builder(manager.connection).select('dummy').from('table').where('sm = 1').toString(),
    'SELECT dummy\n FROM table\n WHERE sm = 1');
    expect(new Builder(manager.connection).select('dummy').from('table').limit(10).offset(5).toString(),
    'SELECT dummy\n FROM table\n LIMIT 10 OFFSET 5');
    expect(new Builder(manager.connection).select('dummy').from('table').where('sm = 1').andWhere('sm2 = 2').toString(),
    'SELECT dummy\n FROM table\n WHERE (sm = 1) AND (sm2 = 2)');
    expect(new Builder(manager.connection).select('dummy').from('table').where('sm = 1', 'sm2 = 2').toString(),
    'SELECT dummy\n FROM table\n WHERE (sm = 1) AND (sm2 = 2)');
    expect(new Builder(manager.connection).select('dummy').from('table').where('sm = 1').orWhere('sm2 = 2').toString(),
    'SELECT dummy\n FROM table\n WHERE (sm = 1) OR (sm2 = 2)');
    expect(new Builder(manager.connection).select('dummy').from('table').join('table2', 'table2.ref = table.ref').toString(),
    'SELECT dummy\n FROM table\n INNER JOIN table2 ON table2.ref = table.ref');
    expect(new Builder(manager.connection).select('dummy').from('table').having('sm > 1').toString(),
    'SELECT dummy\n FROM table\n HAVING sm > 1');
}