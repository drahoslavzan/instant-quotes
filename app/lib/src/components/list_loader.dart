import 'package:flutter/widgets.dart';

abstract class ListLoaderElem<K> {
  K get id;
}

abstract class ListLoader<T> extends ChangeNotifier {
  int get size;

  T? elemAt(int index);
  Future<int> load({int position = 0});
  Future<void> flushSeen();
}

abstract class SearchableListLoader<T extends ListLoaderElem<K>, K> extends ListLoader<T> {
  T? find(K id);
}
