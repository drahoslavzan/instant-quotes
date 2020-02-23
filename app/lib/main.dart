import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_connector.dart';
import 'database/quote_repository.dart';
import 'database/tag_repository.dart';
import 'database/author_repository.dart';
import 'quote_actions.dart';
import 'tags_page.dart';
import 'authors_page.dart';
import 'favorites_page.dart';
import 'choice_card.dart';

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
        ProxyProvider<DatabaseConnector, TagRepository>(update: (_, conn, child) {
          return conn == null ? null : TagRepository(connector: conn);
        }),
        ProxyProvider<DatabaseConnector, AuthorRepository>(update: (_, conn, child) {
          return conn == null ? null : AuthorRepository(connector: conn);
        }),
        Provider<QuoteActions>(create: (_) => QuoteActions(), lazy: false),
      ],
      child: MaterialApp(
        //debugShowCheckedModeBanner: false,
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
            body: _InitDbScreen(
              child: TabBarView(
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
  Choice(title: 'Tags', icon: Text('#', style: TextStyle(fontSize: 22)), page: TagsPage()),
  Choice(title: 'Authors', icon: Icon(Icons.person), page: AuthorsPage()),
  Choice(title: 'Favorites', icon: Icon(Icons.favorite, color: Colors.red), page: FavoritesPage()),
];

class _InitDbScreen extends StatefulWidget {
  final Widget child;

  _InitDbScreen({this.child});

  @override
  _InitDbScreenState createState() => _InitDbScreenState();
}

class _InitDbScreenState extends State<_InitDbScreen> {
  @override
  void didChangeDependencies() {
    _init();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          return widget.child;
        }

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 25),
              Text('Initializing Database ...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('(may take a while for a first time)', style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic))
            ],
          )
        );
      }
    );
  }

  void _init() {
    if (_tagRepository != null) return;
    _tagRepository = Provider.of<TagRepository>(context);
    if (_tagRepository == null) return;

    final future = _tagRepository.random(count: 30);

    if (!mounted) return;
    setState(() {
      _future = future;
    });
  }

  TagRepository _tagRepository;
  Future _future;
}
