import 'dart:developer' as developer;
import 'package:bestquotes/src/database/quote_repository.dart';
import 'package:flutter/widgets.dart';

import '../database/model/quote.dart';
import 'quote_service.dart';

abstract class QuoteLoader extends ChangeNotifier {
  int get size;

  Quote? quoteAt(int index);
  Future<int> load({int position = 0});
  void flushSeen();
}

class InfiniteQuoteLoader extends QuoteLoader {
  final int bufferSize;
  final int fetchCount;
  final QuoteFetch fetch;
  final QuoteRepository repo;

  @override
  int get size => _quotes.length + (_hasMore ? 1 : 0);

  InfiniteQuoteLoader({
    required this.fetch,
    required this.repo,
    this.bufferSize = 250,
    this.fetchCount = 50
  }) {
    assert(fetchCount <= bufferSize / 2);
    load();
  }

  @override
  Quote? quoteAt(int index) {
    if (index >= _quotes.length) return null;
    return _quotes[index];
  }

  @override
  Future<int> load({int position = 0}) async {
    _seenIdx = position;
    if (_loading || !_hasMore || position < _quotes.length - fetchCount / 2) return _seenIdx;

    try {
      _loading = true;
      developer.log("load at position $position, buffer: $bufferSize, total: ${_quotes.length}");

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

      _quotes.addAll(more);
      final start = _quotes.length - bufferSize;
      if (start > 0) {
        final qs = _quotes.sublist(0, start);
        await flushSeen(quotes: qs);

        _quotes = _quotes.sublist(start);
        assert(_quotes.length == bufferSize);

        var p = _seenIdx - start;
        if (p >= 0) {
          _seenIdx = p;
        }
      }

      developer.log("loading at position $position done, fetched: ${more.length}, total: ${_quotes.length}, more: $_hasMore");

      return _seenIdx;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> flushSeen({Iterable<Quote>? quotes}) async {
    if (_seenIdx < 0) return;

    quotes ??= _quotes.sublist(0, _seenIdx + 1);
    developer.log("flushing ${quotes.length} seen quotes");

    await repo.markSeen(quotes);
  }

  var _skip = 0;
  var _seenIdx = -1;
  var _loading = false;
  var _hasMore = true;
  List<Quote> _quotes = [];
}