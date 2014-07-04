part of mapper;

abstract class Entity<E> {

    void init(Map data);

    Map toMap();

    Map toJson() => toMap();

}