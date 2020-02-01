import 'database_connector.dart';
import 'limited_queue.dart';
import 'model/quote_info.dart';
import 'model/quote.dart';

class QuoteRepository {
  QuoteRepository({this.connector, this.name})
    : this.quoteInfo = null;

  QuoteRepository.info({this.connector, this.quoteInfo}) {
    name = quoteInfo.name;
    _andWhere = 'AND info_id = ${quoteInfo.id}';
  }

  QuoteRepository.favorite({this.connector, this.name})
    : this.quoteInfo = null {
    _andWhere = 'AND favorite = 1';
  }

  Future<Quote> get nextUnseen async {
    if(_queue.isEmpty) {
      await _fetchUnseen();
    }
    else if(_queue.isHalfEmpty) {
      _prefetchUnseen();
    }

    return _queue.next;
  }

  Future<void> save() async {
    final seen = _queue.getSeen((u) { return u.id; }).toList();
    seen.removeLast();
    await _flushSeen(seen);
  }

  Future<void> _fetchUnseen() async {
    final list = await _prefetchUnseen();
    _fetch = null;
    _queue.populate(list.map((qi) {
      return Quote.fromMap(qi);
    }));
  }

  Future<List<Map<String, dynamic>>> _prefetchUnseen() async {
    if (_fetch != null) return _fetch;

    final seen = _flushSeen(_queue.getSeen((u) { return u.id; }));
    final db = await connector.db;
    final fetched = _queue.getSeenAndFetched((u) { return u.id; }).join(',');
    _fetch = db.rawQuery('SELECT * FROM quotes WHERE seen = 0 $_andWhere AND id NOT IN ($fetched) ORDER BY id LIMIT $_limit;');
    await seen;
    return _fetch;
  }

  Future<void> _flushSeen(seen) async {
    final db = await connector.db;
    if (seen.isEmpty) return;
    await db.rawQuery('UPDATE quotes SET seen = 1 WHERE id IN (${seen.join(',')});');
    _queue.flushSeen();
  }

  String name;
  String _andWhere = '';
  Future<List<Map<String, dynamic>>> _fetch;
  final DatabaseConnector connector;
  final QuoteInfo quoteInfo;
  final _queue = LimitedQueue<Quote>(_limit);
  static const _limit = 10;
}