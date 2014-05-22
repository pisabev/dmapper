part of test;

class Field {
    final String name;
    final dynamic def;
    const Field({this.name: null, this.def: 'DEFAULT'});
}

class Test {

    var title;

    var _price;

    Test();
}

/*class TestDBRule extends CustomRule {
    bool appliesTo(instance, Writer w) => instance is Test;
    getState(instance) => {
        'title': instance.title,
        'price': instance._price
    };
    create(state) => new Test();
    setState(Test a, Map state) {
        a.title = state['title'];
        a._price = state['price'];
    }
}

/*class Test2 extends Test {

    var ddddd;

    Test2(title, price) : super(title, price);
}*/

inpsector(object) {
    InstanceMirror mirror = reflect(object);
    List data = new List();
    mirror.type.superclass.declarations.forEach((k, v) {
        if(v.metadata.isNotEmpty) {
            var f = v.metadata.firstWhere((e) => e.reflectee is Field);
            if(f != null) {
                Field field = f.reflectee;
                data.add({
                    'property': k,
                    'field': field.name != null? field.name : MirrorSystem.getName(k),
                    'default': field.def
                });
            }
        }
    });
    return data;
}*/