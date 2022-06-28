import 'dart:developer' as developer;

import 'list_loader.dart';

class InfiniteListLoader<T extends ListLoaderElem<K>, K extends Comparable>
extends ListLoader<T, K> {
  final int bufferSize;
  final int fetchCount;
  final ElemFetch<T, K> fetch;
  final ElemSeen<T> seen;
  final List<T> elems = [];

  @override
  int get size => elems.length + (_hasMore ? 1 : 0);

  InfiniteListLoader({
    required this.fetch,
    required this.seen,
    required this.bufferSize,
    required this.fetchCount,
  }) {
    assert(fetchCount <= bufferSize / 2);
    load();
  }

  @override
  T? elemAt(int index) {
    if (index >= elems.length) return null;
    return elems[index];
  }

  @override
  Future<int> load({int position = 0}) async {
    _seenIdx = position;
    if (_loading || !_hasMore || position < elems.length - fetchCount / 2) return _seenIdx;

    try {
      _loading = true;
      developer.log("load at position $position, buffer: $bufferSize, total: ${elems.length}");

      final ids = elems.map((e) => e.id);
      final more = await fetch(fetchCount, skip: _skip, noIDs: ids);
      if (more.length < fetchCount) {
        if (_skip < 1) {
          _hasMore = false;
        } else {
          final mids = ids.toList();
          mids.addAll(more.map((e) => e.id));
          final ext = await fetch(fetchCount - more.length, noIDs: mids);
          more.addAll(ext);
          _skip = ext.length;
        }
      } else {
        _skip += more.length;
      }

      elems.addAll(more);
      await adjustSize();

      developer.log("loading at position $position done, fetched: ${more.length}, total: ${elems.length}, more: $_hasMore");

      return _seenIdx;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> adjustSize() async {
    final start = elems.length - bufferSize;
    if (start > 0) {
      final es = elems.sublist(0, start);
      await flushSeen(elems: es);

      elems.removeRange(0, start);
      assert(elems.length == bufferSize);

      var p = _seenIdx - start;
      if (p >= 0) {
        _seenIdx = p;
      }
    }
  }

  @override
  Future<void> flushSeen({Iterable<T>? elems}) async {
    if (_seenIdx < 0) return;

    elems ??= this.elems.sublist(0, _seenIdx + 1);
    developer.log("flushing ${elems.length} seen elems");

    await seen(elems);
  }

  var _skip = 0;
  var _seenIdx = -1;
  var _loading = false;
  var _hasMore = true;
}

mixin InsertableListLoaderImpl<T extends ListLoaderElem<K>, K extends Comparable>
implements InsertableListLoader<T, K>
{
  List<T> get elems;
  Future<void> adjustSize();

  @override
  Future<void> insert(T elem) async {
    final idx = elems.indexWhere((e) => e.id.compareTo(elem.id) >= 0);
    if (idx < 0) {
      elems.add(elem);
    } else {
      final e = elems[idx];
      if (e.id == elem.id) return;
      elems.insert(idx, elem);
    }

    await adjustSize();

    notifyListeners();
  }
}

mixin RemovableListLoaderImpl<T extends ListLoaderElem<K>, K extends Comparable>
implements RemovableListLoader<T, K> {
  List<T> get elems;

  @override
  Future<void> remove(K id) async {
    final idx = elems.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    elems.removeAt(idx);
    notifyListeners();
  }
}

mixin SearchableListLoaderImpl<T extends ListLoaderElem<K>, K extends Comparable>
implements SearchableListLoader<T, K> {
  List<T> get elems;

  @override
  T? find(K id) {
    final idx = elems.indexWhere((e) => e.id == id);
    if (idx < 0) return null;
    return elems[idx];
  }
}