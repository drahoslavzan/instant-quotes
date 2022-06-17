import 'database_connector.dart';
import 'countable.dart';
import 'model/tag.dart';

class TagRepository with Countable {
  @override final table = 'tags';
  @override final DatabaseConnector connector;

  const TagRepository({required this.connector});

  Future<List<Tag>> random({int count = 50}) {
    final query = 'SELECT id, name FROM $table ORDER BY random() LIMIT ?;';
    return _runQuery(query, [count]);
  }

  Future<List<Tag>> search({required String pattern, int count = 50}) {
    final query = "SELECT id, name FROM $table WHERE name LIKE ? ORDER BY name LIMIT ?;";
    return _runQuery(query, ['%$pattern%', count]);
  }

  Future<List<Tag>> _runQuery(String query, List<Object?> args) async {
    final result = await connector.db.rawQuery(query, args);
    return result.map((q) {
      final tagId = q['id'] as int;
      final tag = q['name'] as String;
      return Tag(id: tagId, name: tag);
    }).toList();
  }
}