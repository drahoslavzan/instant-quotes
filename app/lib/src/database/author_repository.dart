import 'database_connector.dart';
import 'countable.dart';
import 'model/author.dart';

class AuthorRepository with Countable {
  static const numPattern = '#';

  @override final table = 'authors';
  @override final DatabaseConnector connector;

  const AuthorRepository({required this.connector});

  Future<Iterable<Author>> search({
    String? pattern,
    String? startsWith,
    int count = 50,
    int skip = 0
  }) async {
    assert(
      (pattern != null && startsWith == null) ||
      (pattern == null && startsWith != null)
    );

    final like = startsWith != null
      ? 'name LIKE ?'
      : 'name LIKE ? OR profession LIKE ?';

    var args = startsWith != null
      ? ['$startsWith%']
      : ['%$pattern%', '%$pattern%'];

    var where = like;
    if (startsWith == numPattern) {
      args = [];
      for (var i = 0; i < 10; ++i) {
        args.add('$i%');
      }
      where = args.map((_) => like).join(' OR ');
    }

    final query = '''
      SELECT id, name, profession
        FROM $table
        WHERE $where
        ORDER BY name
        LIMIT ?, ?
    ''';

    return _runQuery(query, [...args, skip, count]);
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
