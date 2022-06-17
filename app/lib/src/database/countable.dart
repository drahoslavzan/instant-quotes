import 'database_connector.dart';

mixin Countable {
  DatabaseConnector get connector;
  String get table;

  Future<int> get records async {
    final query = 'SELECT count(id) as count FROM $table;';
    final result = await connector.db.rawQuery(query);
    return result.first['count'] as int;
  }
}