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
    int? authorId,
    int? tagId,
    bool? favorite,
    String? pattern,
    String? match,
    bool random = false,
    int count = 50,
    int skip = 0,
  }) async {
    final where = _where(
      authorId: authorId,
      tagId: tagId,
      favorite: favorite,
      pattern: pattern,
      match: match
    );

    var select = '''
      SELECT q.id, q.quote, q.seen, q.favorite, q.author_id
             ${_putIf(random, ', q.shuffle_idx')}
        FROM $table q
          ${_putIf(match != null, 'INNER JOIN fts_$table m ON m.rowid = q.id')}
          ${_putIf(tagId != null, _joinTags)}
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
            selected: id == tagId,
          );
        })
        .toList();

      final a = Author(
        id: authId,
        name: authName,
        profession: authProfession,
        selected: authId == authorId
      );

      return Quote(
        id: quoteId,
        quote: quote,
        seen: seen,
        favorite: favorite,
        author: a,
        tags: tags
      );
    });
  }

  Future<Quote> byId(int id) async {
    return _partialQuote(id: id);
  }

  Future<Quote> random({int? maxLen}) async {
    return _partialQuote(maxLen: maxLen);
  }

  Future<int> count({
    int? authorId,
    int? tagId,
    bool? favorite,
    String? pattern,
    String? match
  }) async {
    final where = _where(
      authorId: authorId,
      tagId: tagId,
      favorite: favorite,
      pattern: pattern,
      match: match
    );

    var query = '''
      SELECT count(*) AS count
        FROM $table q
          ${_putIf(match != null, 'INNER JOIN fts_$table m ON m.rowid = q.id')}
          ${_putIf(tagId != null, _joinTags)}
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

  Future<Quote> _partialQuote({int? id, int? maxLen}) async {
    final ws = [
      if (id != null) 'q.id = $id',
      if (maxLen != null) 'LENGTH(q.quote) <= $maxLen',
    ];

    final where = ws.isNotEmpty ? 'WHERE ${ws.join(' AND ')}' : '';

    var query = '''
      SELECT q.id, q.quote, q.favorite, q.author_id,
             a.id AS authId, a.name AS authName, a.profession AS authProfession
        FROM $table q
          INNER JOIN authors a ON q.author_id = a.id
        $where
        ORDER BY random()
        LIMIT 1
    ''';

    final q = (await connector.db.rawQuery(query)).first;
    final quoteId = q['id'] as int;
    final quote = q['quote'] as String;
    final favorite = q['favorite'] == 1;
    final authId = q['authId'] as int;
    final authName = q['authName'] as String;
    final authProfession = q['authProfession'] as String;

    final a = Author(
      id: authId,
      name: authName,
      profession: authProfession,
    );

    return Quote(
      id: quoteId,
      quote: quote,
      favorite: favorite,
      author: a,
      seen: false,
      tags: []
    );
  }

  static const _joinTags = '''
    INNER JOIN quote_tags qt ON q.id = qt.quote_id
    INNER JOIN tags t ON qt.tag_id = t.id
  ''';
}

String _putIf(bool p, String v) => p ? v : "";

String _where({ required bool? favorite,
  required int? authorId,
  required int? tagId,
  required String? pattern,
  required String? match
}) {
  final ws = [
    if (tagId != null) 't.id = $tagId',
    if (authorId != null) 'q.author_id = $authorId',
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
