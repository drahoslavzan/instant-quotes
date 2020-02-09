import 'database_connector.dart';
import 'model/author.dart';

class AuthorRepository {
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
    
    final query = "SELECT id, name FROM $table WHERE $like ORDER BY known, name LIMIT ?, ?;";

    final result = await connector.db.rawQuery(query, [...args, skip, count]);

    return result.map((q) {
      final tagId = q['id'];
      final tag = q['name'];

      return Author(id: tagId, name: tag);
    }).toList();
  }
}
