import 'database_connector.dart';
import 'countable.dart';
import 'model/author.dart';

class AuthorRepository with Countable {
  final table = 'authors';
  final DatabaseConnector connector;

  AuthorRepository({this.connector});

  Future<List<Author>> fetch({String startsWith, int count = 50, int skip = 0}) async {
    var like = 'name LIKE ?';
    var args = ['$startsWith%'];

    if (startsWith == '#') {
      args = ['0%','1%','2%','3%','4%','5%','6%','7%','8%','9%'];
      like = args.map((_) => 'name LIKE ?').join(' OR ');
    }
    
    final query = "SELECT id, name, profession FROM $table WHERE $like ORDER BY known, name LIMIT ?, ?;";

    final result = await connector.db.rawQuery(query, [...args, skip, count]);

    return result.map((q) {
      final id = q['id'];
      final tag = q['name'];
      final profession = q['profession'];

      return Author(id: id, name: tag, profession: profession);
    }).toList();
  }

  Future<List<Author>> search({String pattern, int count = 50}) async {
    final query = "SELECT id, name, profession FROM $table WHERE name LIKE ? OR profession LIKE ? ORDER BY known, name LIMIT ?;";

    final result = await connector.db.rawQuery(query, ['%$pattern%', '%$pattern%', count]);

    return result.map((q) {
      final id = q['id'];
      final tag = q['name'];
      final profession = q['profession'];

      return Author(id: id, name: tag, profession: profession);
    }).toList();
  }
}
