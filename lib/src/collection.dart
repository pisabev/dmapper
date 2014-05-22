part of client;

class Collection<E> extends ListBase<E> {

    List innerList = new List();

    int get length => innerList.length;

    void set length(int length) {
        innerList.length = length;
    }

    void operator []=(int index, E value) {
        innerList[index] = value;
    }

    E operator [](int index) => innerList[index];

    void add(E value) => innerList.add(value);

    void addAll(Iterable<E> all) => innerList.addAll(all);

    Iterable map(f(E element)) => innerList.map(f);

}