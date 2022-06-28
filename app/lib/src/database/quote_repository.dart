import 'package:quiver/iterables.dart';

import 'database_connector.dart';
import 'countable.dart';
import 'model/author.dart';
import 'model/tag.dart';
import 'model/quote.dart';

class QuoteRepository with Countable {
  @override final table = 'quotes';
  @override final DatabaseConnector connector;

  QuoteRepository({required this.connector});

  Future<List<Quote>> fetch({
    Author? author,
    Tag? tag,
    Iterable<int>? noIDs,
    bool? favorite,
    bool random = false,
    int count = 50,
    int skip = 0,
  }) async {
    final where = _where(author: author, tag: tag, favorite: favorite, noIDs: noIDs);
    const concat = ', group_concat(qt.tag_id) AS tagIds, group_concat(t.name) AS tags';
    final group = 'GROUP BY q.id ORDER BY q.seen, ${random ? "RANDOM()" : "q.id"} LIMIT ?, ?';

    var select = '''
      SELECT q.id, q.quote, q.seen, q.favorite,
             a.id AS authId, a.name AS authName, a.profession AS authProfession
        ${_putIf(tag == null, concat)} 
        FROM $table q
          INNER JOIN quote_tags AS qt ON q.id = qt.quote_id
          INNER JOIN tags AS t ON qt.tag_id = t.id
          INNER JOIN authors AS a ON q.author_id = a.id
        $where
        ${_putIf(tag == null, group)}
    ''';

    final query = tag == null ? select : '''
      SELECT q.*
        $concat
        FROM ($select) q
          INNER JOIN quote_tags AS qt ON q.id = qt.quote_id
          INNER JOIN tags AS t ON qt.tag_id = t.id
        $group
    ''';

    final result = await connector.db.rawQuery(query, [skip, count]);
    return result.map((q) {
      final quoteId = q['id'] as int;
      final quote = q['quote'] as String;
      final seen = q['seen'] == 1;
      final favorite = q['favorite'] == 1;
      final authId = q['authId'] as int;
      final authName = q['authName'] as String;
      final authProfession = q['authProfession'] as String;
      final tagIds = q['tagIds'].toString().split(',');
      final tagNames = q['tags'].toString().split(',');

      final tags = zip([tagIds, tagNames]).map((t) => Tag(id: int.parse(t[0]), name: t[1])).toList();
      final author = Author(id: authId, name: authName, profession: authProfession);

      return Quote(id: quoteId, quote: quote, seen: seen, favorite: favorite, author: author, tags: tags);
    }).toList();
  }

  Future<int> count({
    Author? author,
    Tag? tag,
    bool? favorite,
  }) async {
    final where = _where(author: author, tag: tag, favorite: favorite);

    var query = '''
      SELECT COUNT(*) AS count
        FROM $table q
        $where
    ''';

    final result = (await connector.db.rawQuery(query)).first;
    return result['count'] as int;
  }

  Future<void> markSeen(Iterable<Quote> quotes) async {
    final ids = quotes.map((q) => q.id).join(',');
    if (ids.isEmpty) return;
    await connector.db.rawQuery('UPDATE $table SET seen = 1 WHERE id IN ($ids)');
  }

  Future<void> markFavorite(Quote quote, bool favorite) async {
    await connector.db.rawQuery('UPDATE $table SET favorite = ${favorite ? 1 : 0} WHERE id = ${quote.id}');
  }

  String _where({
    bool? favorite,
    Author? author,
    Tag? tag,
    Iterable<int>? noIDs,
  }) {
    final ws = [
      if (favorite != null) 'q.favorite = ${favorite ? 1 : 0}',
      if (noIDs?.isNotEmpty == true) 'q.id NOT IN (${noIDs!.join(",")})',
      if (author != null) 'a.id = ${author.id}',
      if (tag != null) 't.id = ${tag.id}',
    ];

    return ws.isNotEmpty ? 'WHERE ${ws.join(' AND ')}' : '';
  }
}

String _putIf(bool p, String v) => p ? v : "";