import 'database_connector.dart';
import 'limited_queue.dart';
import 'model/quote_info.dart';
import 'model/quote.dart';

class QuoteRepository {
  QuoteRepository({this.connector, this.name}) : this.quoteInfo = null;

  QuoteRepository.info({this.connector, this.quoteInfo}) {
    name = quoteInfo.name;
    _where = 'seen = 0 AND info_id = ${quoteInfo.id}';
  }

  factory QuoteRepository.favorite({connector, name}) => _FavoriteQuoteRepository(connector: connector, name: name);

  Future<Quote> get next async {
    if(_queue.isEmpty) {
      await _fetchUnseen();
    }
    else if(_queue.isHalfEmpty) {
      _prefetchUnseen();
    }

    return _queue.next;
  }

  Future<void> markFavorite(Quote quote, bool favorite) async {
    final db = await connector.db;
    await db.rawQuery('UPDATE quotes SET favorite = ${favorite ? 1 : 0} WHERE id = ${quote.id}');
  }

  Future<void> save() async {
    final seen = _queue.getSeen((u) => u.id).toList();
    if (seen.isEmpty) return;
    seen.removeLast();
    await _flushSeen(seen);
  }

  Future<void> _fetchUnseen() async {
    final list = await _prefetchUnseen();
    _fetch = null;
    _queue.populate(list.map((qi) => Quote.fromMap(qi)));
  }

  Future<List<Map<String, dynamic>>> _prefetchUnseen() async {
    if (_fetch != null) return _fetch;

    final seen = _flushSeen(_queue.getSeen((u) => u.id));
    final db = await connector.db;
    final fetched = _queue.getSeenAndFetched((u) => u.id).join(',');
    _fetch = db.rawQuery('SELECT * FROM quotes WHERE $_where AND id NOT IN ($fetched) ORDER BY id LIMIT $_limit;');
    await seen;
    return _fetch;
  }

  Future<void> _flushSeen(seen) async {
    if (seen.isEmpty) return;
    final db = await connector.db;
    await db.rawQuery('UPDATE quotes SET seen = 1 WHERE id IN (${seen.join(',')});');
    _queue.flushSeen();
  }

  String name;
  String _where = 'seen = 0';
  Future<List<Map<String, dynamic>>> _fetch;
  final DatabaseConnector connector;
  final QuoteInfo quoteInfo;
  final _queue = LimitedQueue<Quote>(_limit);
  static const _limit = 10;
}

class _FavoriteQuoteRepository extends QuoteRepository {
  @override
  Future<void> _flushSeen(seen);

  _FavoriteQuoteRepository({connector, name}) : super(connector: connector, name: name) {
    _where = 'favorite = 1';
  }
}