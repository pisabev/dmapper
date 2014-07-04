part of mapper;

class Entity {

    void init(Map data);

    void initMerge(Map data) {
        var m = toMap();
        m.addAll(data);
        init(m);
    }

    Map toMap();

    Map toJson() => toMap();

}