import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_connector.dart';
import 'database/quote_repository.dart';
import 'database/topic_repository.dart';
import 'database/tag_repository.dart';
import 'topics_page.dart';
import 'tags_page.dart';

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
        ProxyProvider<DatabaseConnector, TagRepository>(update: (_, conn, child) {
          return conn == null ? null : TagRepository(connector: conn);
        }),
      ],
      child: MaterialApp(
        title: 'Fortune quotes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DefaultTabController(
          length: choices.length,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              appBar: AppBar(
                flexibleSpace: SafeArea(
                  child: TabBar(
                    onTap: (index) {
                      FocusScope.of(context).unfocus();
                    },
                    tabs: choices.map((Choice choice) {
                      return Tab(
                        text: choice.title,
                        icon: choice.icon,
                      );
                    }).toList(),
                  )
                )
              ),
              body: TabBarView(
                children: choices.map((Choice choice) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ChoiceCard(choice: choice)
                  );
                }).toList()
              )
            )
          )
        )
      )
    );
  }

  Future<DatabaseConnector> _createDatabase() async {
    final conn = DatabaseConnector();
    await conn.initDb();
    return conn;
  }
}

const List<Choice> choices = <Choice>[
  Choice(title: 'TOPICS', icon: Icon(Icons.list), page: TopicsPage()),
  Choice(title: 'TAGS', icon: Text('#', style: TextStyle(fontSize: 22)), page: TagsPage()),
  Choice(title: 'AUTHORS', icon: Icon(Icons.person), page: TopicsPage()),
  Choice(title: 'FAVS', icon: Icon(Icons.favorite), page: TopicsPage()),
];

class Choice {
  const Choice({this.title, this.icon, this.page});

  final String title;
  final Widget icon;
  final Widget page;
}

class ChoiceCard extends StatelessWidget {
  final Choice choice;

  const ChoiceCard({Key key, this.choice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return choice.page;
  }
}