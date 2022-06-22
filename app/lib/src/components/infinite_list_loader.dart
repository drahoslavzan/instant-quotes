import 'dart:developer' as developer;

import 'list_loader.dart';

typedef ElemFetch<T> = Future<List<T>> Function(int count, {int skip, List<int>? ids});
typedef ElemSeen<T> = Future<void> Function(Iterable<T> elems);

class InfiniteListLoader<T> extends ListLoader<T> {
  final int bufferSize;
  final int fetchCount;
  final ElemFetch<T> fetch;
  final ElemSeen<T> seen;

  @override
  int get size => _elems.length + (_hasMore ? 1 : 0);

  InfiniteListLoader({
    required this.fetch,
    required this.seen,
    this.bufferSize = 250,
    this.fetchCount = 50
  }) {
    assert(fetchCount <= bufferSize / 2);
    load();
  }

  @override
  T? elemAt(int index) {
    if (index >= _elems.length) return null;
    return _elems[index];
  }

  @override
  Future<int> load({int position = 0}) async {
    _seenIdx = position;
    if (_loading || !_hasMore || position < _elems.length - fetchCount / 2) return _seenIdx;

    try {
      _loading = true;
      developer.log("load at position $position, buffer: $bufferSize, total: ${_elems.length}");

      final more = await fetch(fetchCount, skip: _skip);
      if (more.length < fetchCount) {
        if (_skip < 1) {
          _hasMore = false;
        } else {
          final ext = await fetch(fetchCount - more.length);
          more.addAll(ext);
          _skip = ext.length;
        }
      } else {
        _skip += more.length;
      }

      _elems.addAll(more);
      final start = _elems.length - bufferSize;
      if (start > 0) {
        final es = _elems.sublist(0, start);
        await flushSeen(elems: es);

        _elems = _elems.sublist(start);
        assert(_elems.length == bufferSize);

        var p = _seenIdx - start;
        if (p >= 0) {
          _seenIdx = p;
        }
      }

      developer.log("loading at position $position done, fetched: ${more.length}, total: ${_elems.length}, more: $_hasMore");

      return _seenIdx;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> flushSeen({Iterable<T>? elems}) async {
    if (_seenIdx < 0) return;

    elems ??= _elems.sublist(0, _seenIdx + 1);
    developer.log("flushing ${elems.length} seen elems");

    await seen(elems);
  }

  var _skip = 0;
  var _seenIdx = -1;
  var _loading = false;
  var _hasMore = true;
  List<T> _elems = [];
}

class SearchableInfiniteListLoader<T extends ListLoaderElem<K>, K>
  extends InfiniteListLoader<T>
  implements SearchableListLoader<T, K>
{
  SearchableInfiniteListLoader({
    required super.fetch,
    required super.seen,
    super.bufferSize = 250,
    super.fetchCount = 50
  });

  @override
  T? find(K id) {
    for (var e in _elems) {
      if (e.id == id) {
        return e;
      }
    }

    return null;
  }
}