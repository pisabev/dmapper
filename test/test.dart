library test;

import 'dart:io';
import 'dart:async';
import 'dart:mirrors';
import 'package:mapper/mapper.dart';
import 'package:unittest/unittest.dart';

import 'package:mapper/mapper.dart';

part 'builder_test.dart';
part 'mapper_test.dart';

class A extends Application<A> {
    init() => new A();
}

Manager<A> manager;

String database = 'test';

startUp() {
    test('_Startup_', () => Process.run('./install.sh', ['-d ' + database, '-m 0'], workingDirectory: '../bin', runInShell:true)
    .then((_) => Process.run('./install.sh', ['-d ' + database, '-m 1'], workingDirectory: '../bin', runInShell:true))
    .then((_) {
        manager = new Manager(new Connection('postgres://user:dummy@localhost:5432/' + database), new A());
        return manager.init();
    }));
}

cleanUp() {
    test('_Cleanup_', () => manager.destroy());
}

main() {
    //startUp();
    group('Builder', () {
        //test('Select', querySelector);
        test('annotations', ttt);
        /*var s = new Serialization()..addRule(new TestDBRule());
        var p = new Test();
        p.title = 'title';
        p._price = 122;
        print(s.write(p));
        var r = s.read(s.write(p));
        print(r);*/
        //print(inpsector(new Test2('asdasdas', 123)));
    });
    //cleanUp();
}