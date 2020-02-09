import 'database_connector.dart';

mixin Countable {
  String get table;
  DatabaseConnector get connector;

  Future<int> get count async {
    final query = 'SELECT count(id) as count FROM $table;';

    final result = await connector.db.rawQuery(query);
    return result.first['count'];
  }
}