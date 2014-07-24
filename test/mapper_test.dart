part of test;

class Field {
    final String name;
    final dynamic def;
    final String type;
    const Field({this.name: null, this.def: 'DEFAULT', this.type: null});
}


class Table {
    final String name;
    const Table(this.name);
}

@Table('product')
class Product {

    @Field()
    var title;

    @Field()
    var price;

    Test();
}

class ProductExt extends Product {

}

ttt() {
    var obj = new Product2();
    obj.title = 'ssss';
    var ser = new Serialization();
    ser.addRule(new ClosureRule(obj.runtimeType,
    productToMap, createProduct, fillInProduct));
    //ser.read(obj);
    print(ser.write(obj));
    return;
    var data = readClassData();
    var date = new DateTime.now();
    for(int i = 0; i<100000; i++) {

        readObject(obj, data);
        //readObject2(obj);
        //setObject(obj, data, {'title':'dddd'});
        //setObject2(obj, {'title':'dddd'});
        //print(data);
    }
    print(new DateTime.now().difference(date).inMilliseconds);
}

class _Field {

    Symbol property;
    String field;
    dynamic def;

    _Field(this.property, this.field, this.def);
}

readClassData() {
    Map field_map = new Map();
    var classMirror = reflectClass(ProductExt);
    var metadata = classMirror.superclass.metadata;
    classMirror.superclass.declarations.forEach((k, v) {
        var f = v.metadata.firstWhere((e) => e.reflectee is Field, orElse: () => null);
        if(f != null) {
            Field field = f.reflectee;
            var name = MirrorSystem.getName(k);
            field_map[name] = {
                'symbol': k,
                'db': field.name != null? field.name : name,
                'default': field.def
            };
        }
    });
    return field_map;
}

readObject(obj, Map field_map) {
    var refl = reflect(obj);
    Map data = new Map();
    field_map.forEach((k, v) => data[v['db']] = refl.getField(v['symbol']).reflectee);
    return data;
}

setObject(obj, Map field_map, Map data) {
    var refl = reflect(obj);
    data.forEach((k, v) => refl.setField(field_map[k]['symbol'], v));
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

class Product2 {
    var title;
    var price;

    Product2();

    Product2.fromMap(Map data) {
        init(data);
    }

    init(Map data) {
        title = data['title'];
        price = data['price'];
    }

    toMap() => {
        'title': title,
        'price': price,
    };
}

productToDb(Product2 product) => product.toMap();

class Product2ext extends Product2 {

}

readObject2(obj) {
    return obj.toMap();
}

setObject2(obj, Map data) {
    obj.init(data);
}

productToMap(a) => {"title" : a.title, "price" : a.price};
createProduct(Map m) => new Product2.fromMap(m);
fillInProduct(Product a, Map m) {
    a.title = m["title"];
    a.price = m['price'];
}

class ProductRule extends CustomRule {
    bool appliesTo(instance, Writer w) => instance.runtimeType == Product2;
    getState(instance) => {
        'title': instance.title,
        'price': instance._price
    };
    create(state) => new Product2();
    setState(Product2 a, Map state) {
        a.title = state[0];
        a.price = state[1];
    }
}