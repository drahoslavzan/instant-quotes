
import 'database_connector.dart';
import 'model/quote_info.dart';

class QuoteInfoRepository {
  QuoteInfoRepository(this.connector);

  Future<List<QuoteInfo>> get all async {
    final db = await connector.db;
    var list = await db.rawQuery('SELECT i.*, SUM(CASE WHEN q.favorite = 1 THEN 1 ELSE 0 END) as favorites from quote_infos as i INNER JOIN quotes as q ON i.id = q.info_id;');
    return list.map((qi) {
      return QuoteInfo.fromMap(qi);
    }).toList();
  }

  final DatabaseConnector connector;
}