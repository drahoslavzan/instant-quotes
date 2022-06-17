import 'package:quiver/iterables.dart';

import 'database_connector.dart';
import 'countable.dart';
import 'model/author.dart';
import 'model/tag.dart';
import 'model/quote.dart';

class QuoteRepository with Countable {
  @override final table = 'quotes';
  @override final DatabaseConnector connector;

  const QuoteRepository({required this.connector});

  Future<List<Quote>> fetch({Author? author, Tag? tag, int count = 50, int skip = 0, bool favorites = false}) async {
    final wheres = [
      'q.favorite = ${favorites ? 1 : 0}',
      if (author != null) 'a.id = ${author.id}',
      if (tag != null) 't.id = ${tag.id}',
    ];

    const gcpart = ', group_concat(qt.tag_id) AS tagIds, group_concat(t.name) AS tags';
    const gpart = 'GROUP BY q.id ORDER BY q.seen LIMIT ?, ?;';
    var query = '''
      SELECT q.id, q.quote, q.seen, q.favorite, a.id AS authId, a.name AS authName, a.profession AS authProfession
        ${tag != null ? "" : gcpart} 
        FROM $table AS q
          INNER JOIN quote_tags AS qt ON q.id = qt.quote_id
          INNER JOIN tags AS t ON qt.tag_id = t.id
          INNER JOIN authors AS a ON q.author_id = a.id
        WHERE ${wheres.join(' AND ')}
        ${tag != null ? "" : gpart}
    ''';

    if (tag != null) {
      query = '''
        SELECT q.* $gcpart
          FROM ($query) AS q
            INNER JOIN quote_tags AS qt ON q.id = qt.quote_id
            INNER JOIN tags AS t ON qt.tag_id = t.id
          $gpart
      ''';
    }

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

  Future<void> markSeen(Iterable<Quote> quotes) async {
    final ids = quotes.map((q) => q.id).join(',');
    if (ids.isEmpty) return;
    await connector.db.rawQuery('UPDATE $table SET seen = 1 WHERE id IN ($ids)');
  }

  Future<void> markFavorite(Quote quote, bool favorite) {
    return connector.db.rawQuery('UPDATE $table SET favorite = ${favorite ? 1 : 0} WHERE id = ${quote.id}');
  }
}
