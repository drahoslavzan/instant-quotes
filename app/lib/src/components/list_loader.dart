import 'package:flutter/widgets.dart';

abstract class ListLoader<T> extends ChangeNotifier {
  int get size;

  T? elemAt(int index);
  Future<int> load({int position = 0});
  Future<void> flushSeen();
}
