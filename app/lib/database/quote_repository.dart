import 'package:quiver/iterables.dart';
import 'database_connector.dart';
import 'model/author.dart';
import 'model/tag.dart';
import 'model/topic.dart';
import 'model/quote.dart';

class QuoteRepository {
  final DatabaseConnector connector;

  QuoteRepository({this.connector});

  Future<List<Quote>> fetch({int count, int skip = 0, bool favorites = false, Author author, Tag tag, Topic topic}) async {
    final where = '${favorites ? "q.favorites = 1" : "q.seen = 0"}'
                  ' ${author == null ? "" : "AND a.id = ${author.id}"}'
                  ' ${tag == null ? "" : "AND t.id = ${tag.id}"}'
                  ' ${topic == null ? "" : "AND qp.topic_id = ${topic.id}"}';

    final query = '''SELECT q.id as quoteId, q.quote, q.seen, q.favorite, a.id as authorId, a.name as author, group_concat(qt.tag_id) as tagIds, group_concat(t.name) as tags
                       FROM quotes AS q
                         INNER JOIN quote_tags AS qt ON q.id = qt.quote_id
                         INNER JOIN tags AS t ON qt.tag_id = t.id
                         INNER JOIN authors AS a ON q.author_id = a.id
                         ${topic == null ? "" : "INNER JOIN quote_topics AS qp ON q.id = qp.quote_id"}
                       WHERE $where
                       GROUP BY q.id
                       LIMIT ?, ?;''';

    final result = await connector.db.rawQuery(query, [skip, count]);

    return result.map((q) {
      final quoteId = q['quoteId'];
      final quote = q['quote'];
      final seen = q['seen'] == 1;
      final favorite = q['favorite'] == 1;
      final authorId = q['authorId'];
      final authorName = q['author'];
      final tagIds = q['tagIds'].toString().split(',');
      final tagNames = q['tags'].toString().split(',');

      final tags = zip([tagIds, tagNames]).map((t) => Tag(id: int.parse(t[0]), name: t[1])).toList();
      final author = Author(id: authorId, name: authorName);

      return Quote(id: quoteId, quote: quote, seen: seen, favorite: favorite, author: author, tags: tags);
    }).toList();
  }

  Future<void> markSeen(List<Quote> quotes) async {
    final ids = quotes.map((q) => q.id).join(',');
    connector.db.rawQuery('UPDATE quotes SET seen = 1 WHERE id IN ($ids)');
  }

  Future<void> toggleFavorite(List<Quote> quotes, bool favorite) async {
    final ids = quotes.map((q) => q.id).join(',');
    connector.db.rawQuery('UPDATE quotes SET favorite = ${favorite ? 1 : 0} WHERE id IN ($ids)');
  }
}
