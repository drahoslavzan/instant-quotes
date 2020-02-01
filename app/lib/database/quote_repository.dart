import 'database_connector.dart';
import 'model/quote_info.dart';
import 'model/quote.dart';
import 'limited_queue.dart';

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
    await _flushSeen();
  }

  Future<void> _fetchUnseen() async {
    var list = await _prefetchUnseen();
    _fetch = null;
    _queue.populate(list.map((qi) {
      return Quote.fromMap(qi);
    }));
  }

  Future<List<Map<String, dynamic>>> _prefetchUnseen() async {
    if (_fetch != null) return _fetch;

    var seen = _flushSeen();
    final db = await connector.db;
    _fetch = db.rawQuery('SELECT * FROM quotes WHERE seen = 0 $_andWhere AND id NOT IN ($_fetched) ORDER BY id LIMIT $_limit;');
    await seen;
    return _fetch;
  }

  Future<void> _flushSeen() async {
    final db = await connector.db;
    var seen = _queue.getSeen((u) { return u.id; }).join(',');
    if (seen.isEmpty) return;
    await db.rawQuery('UPDATE quotes SET seen = 1 WHERE id IN ($seen);');
    _queue.flushSeen();
  }

  String get _fetched => _queue.getSeenAndFetched((u) { return u.id; }).join(',');

  String name;
  String _andWhere = '';
  Future<List<Map<String, dynamic>>> _fetch;
  final DatabaseConnector connector;
  final QuoteInfo quoteInfo;
  final _queue = LimitedQueue<Quote>(_limit);
  static const _limit = 10;
}