import 'database_connector.dart';
import 'countable.dart';
import 'model/author.dart';

class AuthorRepository with Countable {
  @override final table = 'authors';
  @override final DatabaseConnector connector;

  const AuthorRepository({required this.connector});

  Future<Iterable<Author>> fetch({
    required String startsWith,
    int count = 50,
    int skip = 0
  }) async {
    var like = 'name LIKE ?';
    var args = ['$startsWith%'];

    if (startsWith == '#') {
      args = ['0%','1%','2%','3%','4%','5%','6%','7%','8%','9%'];
      like = args.map((_) => 'name LIKE ?').join(' OR ');
    }
    
    final query = '''
      SELECT id, name, profession
        FROM $table
        WHERE $like
        ORDER BY name
        LIMIT ?, ?
    ''';

    return _runQuery(query, [...args, skip, count]);
  }

  Future<Iterable<Author>> search({
    required String pattern,
    int count = 50
  }) async {
    final query = '''
      SELECT id, name, profession
        FROM $table
        WHERE name LIKE ? OR profession LIKE ?
        ORDER BY name
        LIMIT ?
    ''';

    return _runQuery(query, ['%$pattern%', '%$pattern%', count]);
  }

  Future<Iterable<Author>> _runQuery(String query, List<Object?> args) async {
    final result = await connector.db.rawQuery(query, args);

    return result.map((q) {
      final id = q['id'] as int;
      final tag = q['name'] as String;
      final profession = q['profession'] as String;
      return Author(id: id, name: tag, profession: profession);
    });
  }
}
