part of mapper_server;

abstract class Entity<E> {

    void init(Map data);

    Map toMap();

    Map toJson() => toMap();

}