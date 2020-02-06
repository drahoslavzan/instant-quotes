import 'database_connector.dart';
import 'model/topic.dart';

class TopicRepository {
  final DatabaseConnector connector;

  TopicRepository({this.connector});

  Future<List<Topic>> fetch({int count, int skip = 0}) async {
    final query = 'SELECT id, name FROM topics ORDER BY name LIMIT ?, ?;';

    final result = await connector.db.rawQuery(query, [skip, count]);

    return result.map((q) {
      final topicId = q['id'];
      final topic = q['name'];

      return Topic(id: topicId, name: topic);
    }).toList();
  }

  Future<List<Topic>> search({String pattern}) async {
    final query = "SELECT id, name FROM topics WHERE name LIKE '?' ORDER BY name";

    final result = await connector.db.rawQuery(query, [pattern]);

    return result.map((q) {
      final topicId = q['id'];
      final topic = q['name'];

      return Topic(id: topicId, name: topic);
    }).toList();
  }
}