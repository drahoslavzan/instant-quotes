import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_connector.dart';
import 'database/quote_repository.dart';
import 'database/topic_repository.dart';
import 'topics_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider<DatabaseConnector>(create: (_) => _createDatabase()),
        ProxyProvider<DatabaseConnector, QuoteRepository>(update: (_, conn, child) {
          return conn == null ? null : QuoteRepository(connector: conn);
        }),
        ProxyProvider<DatabaseConnector, TopicRepository>(update: (_, conn, child) {
          return conn == null ? null : TopicRepository(connector: conn);
        }),
      ],
      child: MaterialApp(
        title: 'Fortune quotes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TopicsPage(title: 'Topics')
      )
    );
  }

  Future<DatabaseConnector> _createDatabase() async {
    final conn = DatabaseConnector();
    await conn.initDb();
    return conn;
  }
}