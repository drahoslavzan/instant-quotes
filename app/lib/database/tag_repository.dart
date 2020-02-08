import 'database_connector.dart';
import 'model/tag.dart';

class TagRepository {
  final DatabaseConnector connector;

  TagRepository({this.connector});

  Future<List<Tag>> random({int count = 50}) async {
    final query = 'SELECT id, name FROM tags ORDER BY random() LIMIT ?;';

    final result = await connector.db.rawQuery(query, [count]);

    return result.map((q) {
      final tagId = q['id'];
      final tag = q['name'];

      return Tag(id: tagId, name: tag);
    }).toList();
  }

  Future<List<Tag>> search({String pattern, int count = 50}) async {
    final query = "SELECT id, name FROM tags WHERE name LIKE ? ORDER BY name LIMIT ?;";

    final result = await connector.db.rawQuery(query, ['%$pattern%', count]);

    return result.map((q) {
      final tagId = q['id'];
      final tag = q['name'];

      return Tag(id: tagId, name: tag);
    }).toList();
  }
}