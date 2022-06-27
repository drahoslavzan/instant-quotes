import 'package:flutter/widgets.dart';

abstract class ListLoaderElem<K extends Comparable> {
  K get id;
}

abstract class ListLoader<T> extends ChangeNotifier {
  int get size;

  T? elemAt(int index);
  Future<int> load({int position = 0});
  Future<void> flushSeen();
}

abstract class SearchableListLoader<T extends ListLoaderElem<K>, K extends Comparable> extends ListLoader<T> {
  T? find(K id);
}

abstract class InsertableListLoader<T extends ListLoaderElem<K>, K extends Comparable> extends ListLoader<T> {
  Future<void> insert(T elem);
}

abstract class RemovableListLoader<T extends ListLoaderElem<K>, K extends Comparable> extends ListLoader<T> {
  Future<void> remove(K id);
}
