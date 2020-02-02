import 'dart:collection';

class LimitedQueue<T> {
  LimitedQueue(this.limit);

  bool get isEmpty => _unseen.isEmpty;

  bool get isHalfEmpty => _unseen.length <= limit / 2;

  T get next {
    if (_unseen.isEmpty) return null;

    var q = _unseen.removeFirst();
    _seen.add(q);
    return q;
  }

  void populate(Iterable<T> list) {
    _unseen.addAll(list);
  }

  void flushSeen() => _seen.clear();

  Iterable getSeen(Function f) => _seen.map(f);

  Iterable getSeenAndFetched(Function f) => _seen.map(f).followedBy(_unseen.map(f));

  final int limit;
  final _unseen = Queue<T>();
  final _seen = Queue<T>();
}
