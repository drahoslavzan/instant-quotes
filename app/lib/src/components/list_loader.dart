import 'package:flutter/widgets.dart';

typedef ElemSeen<T> = Future<void> Function(Iterable<T> elems);
typedef ElemFetch<T, K> = Future<Iterable<T>> Function(int count, {int skip});

abstract class ListLoaderElem<K extends Comparable> {
  K get id;
}

abstract class ListLoader<T extends ListLoaderElem<K>, K extends Comparable> extends ChangeNotifier {
  int get size;

  T? elemAt(int index);
  Future<int> load({int position = 0});
  Future<void> flushSeen();
}

abstract class SearchableListLoader<T extends ListLoaderElem<K>, K extends Comparable> extends ListLoader<T, K> {
  T? find(K id);
}

abstract class InsertableListLoader<T extends ListLoaderElem<K>, K extends Comparable> extends ListLoader<T, K> {
  Future<void> insert(T elem);
}

abstract class RemovableListLoader<T extends ListLoaderElem<K>, K extends Comparable> extends ListLoader<T, K> {
  Future<void> remove(K id);
}
