import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_connector.dart';
import 'database/quote_repository.dart';
import 'database/topic_repository.dart';
import 'database/tag_repository.dart';
import 'database/author_repository.dart';
import 'quote_actions.dart';
import 'topics_page.dart';
import 'tags_page.dart';
import 'authors_page.dart';
import 'favorites_page.dart';

// TODO: change app icon
// TODO: change splash screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  void initState() {
    _controller = new TabController(length: choices.length, vsync: this);
    _title = choices[0].title;
    _controller.addListener(() {
      setState(() {
        _title = choices[_controller.index].title;
      });
    });
    super.initState();
  }

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
        ProxyProvider<DatabaseConnector, AuthorRepository>(update: (_, conn, child) {
          return conn == null ? null : AuthorRepository(connector: conn);
        }),
        Provider<QuoteActions>(create: (_) => QuoteActions(), lazy: false),
      ],
      child: MaterialApp(
        title: 'Fortune quotes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(_title),
              bottom: TabBar(
                controller: _controller,
                onTap: (index) {
                  FocusScope.of(context).unfocus();
                },
                tabs: choices.map((Choice choice) => Tab(
                  icon: choice.icon,
                )).toList(),
              )
            ),
            body: TabBarView(
              controller: _controller,
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
    );
  }

  Future<DatabaseConnector> _createDatabase() async {
    final conn = DatabaseConnector();
    await conn.initDb();
    return conn;
  }

  String _title;
  TabController _controller;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'Categories', icon: Icon(Icons.list), page: TopicsPage()),
  Choice(title: 'Tags', icon: Text('#', style: TextStyle(fontSize: 22)), page: TagsPage()),
  Choice(title: 'Authors', icon: Icon(Icons.person), page: AuthorsPage()),
  Choice(title: 'Favorites', icon: Icon(Icons.favorite, color: Colors.red), page: FavoritesPage()),
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