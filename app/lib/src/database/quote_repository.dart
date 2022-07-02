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

  Future<Iterable<Quote>> fetch({
    Author? author,
    Tag? tag,
    bool? favorite,
    String? pattern,
    String? match,
    bool random = false,
    int count = 50,
    int skip = 0,
  }) async {
    final where = _where(
      author: author,
      tag: tag,
      favorite: favorite,
      pattern: pattern,
      match: match
    );

    var select = '''
      SELECT q.id, q.quote, q.seen, q.favorite, q.author_id
             ${_putIf(random, ', q.shuffle_idx')}
        FROM $table q
          ${_putIf(match != null, 'INNER JOIN fts_$table m ON m.rowid = q.id')}
          ${_putIf(tag != null, _joinTags)}
        $where
        ORDER BY q.seen, ${random ? 'q.shuffle_idx' : 'q.id'}
        LIMIT ?, ?
    ''';

    final query = '''
      SELECT q.id, q.quote, q.seen, q.favorite, q.author_id,
             a.id AS authId, a.name AS authName, a.profession AS authProfession,
             group_concat(qt.tag_id) AS tagIds, group_concat(t.name) AS tags
        FROM ($select) q
          INNER JOIN authors a ON q.author_id = a.id
          $_joinTags
        GROUP BY ${random ? 'q.shuffle_idx' : 'q.id'}
    ''';

    final result = await connector.db.rawQuery(query, _args(
      skip: skip,
      count: count,
      pattern: pattern,
      match: match,
    ));

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

      final tags = zip([tagIds, tagNames])
        .map((t) {
          final id = int.parse(t[0]);
          return Tag(
            id: id,
            name: t[1],
            selected: tag?.id == id,
          );
        })
        .toList();

      final author = Author(id: authId, name: authName, profession: authProfession);

      return Quote(id: quoteId, quote: quote, seen: seen, favorite: favorite, author: author, tags: tags);
    });
  }

  Future<int> count({
    Author? author,
    Tag? tag,
    bool? favorite,
    String? pattern,
    String? match
  }) async {
    final where = _where(
      author: author,
      tag: tag,
      favorite: favorite,
      pattern: pattern,
      match: match
    );

    var query = '''
      SELECT count(*) AS count
        FROM $table q
          ${_putIf(match != null, 'INNER JOIN fts_$table m ON m.rowid = q.id')}
          ${_putIf(tag != null, _joinTags)}
        $where
    ''';

    final result = (await connector.db.rawQuery(query, _args(
      pattern: pattern,
      match: match,
    ))).first;

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

  static const _joinTags = '''
    INNER JOIN quote_tags qt ON q.id = qt.quote_id
    INNER JOIN tags t ON qt.tag_id = t.id
  ''';
}

String _putIf(bool p, String v) => p ? v : "";

String _where({
  required bool? favorite,
  required Author? author,
  required Tag? tag,
  required String? pattern,
  required String? match
}) {
  final ws = [
    if (tag != null) 't.id = ${tag.id}',
    if (author != null) 'q.author_id = ${author.id}',
    if (favorite != null) 'q.favorite = ${favorite ? 1 : 0}',
    if (pattern != null) 'q.quote LIKE ?',
    if (match != null) 'm.quote MATCH ?',
  ];

  return ws.isNotEmpty ? 'WHERE ${ws.join(' AND ')}' : '';
}

List<Object?>? _args({
  required String? pattern,
  required String? match,
  int? skip,
  int? count
}) {
  final args = [
    if (pattern != null) '%$pattern%',
    if (match != null) match,
    if (skip != null) skip,
    if (count != null) count,
  ];

  return args.isEmpty ? null : args;
}
