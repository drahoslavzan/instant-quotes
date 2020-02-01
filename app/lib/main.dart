import 'package:flutter/material.dart';
import 'package:myapp/database/database_connector.dart';
import 'package:myapp/database/quote_info_repository.dart';
import 'package:myapp/database/quote_repository.dart';
import 'package:myapp/database/model/quote_info.dart';
import 'fortune.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var conn = DatabaseConnector();
  await conn.initDb();
  runApp(MyApp(conn));
}

class MyApp extends StatelessWidget {
  MyApp(this._databaseConnector);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fortune quotes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Settings(title: 'Flavors', databaseConnector: _databaseConnector)
    );
  }

  final DatabaseConnector _databaseConnector;
}

class Settings extends StatefulWidget {
  Settings({this.title, @required databaseConnector})
    : databaseConnector = databaseConnector
    , quoteInfoRepository = QuoteInfoRepository(databaseConnector);

  @override
  _SettingsState createState() => _SettingsState();

  final String title;
  final DatabaseConnector databaseConnector;
  final QuoteInfoRepository quoteInfoRepository;
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    _infos = widget.quoteInfoRepository.all;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuoteInfo>>(
      future: _infos,
      builder: (BuildContext context, AsyncSnapshot<List<QuoteInfo>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // TODO: busy indicator
          return Text('working');
        }

        var favorites = 0;
        final list = snapshot.data.map((qi) {
          favorites += qi.favorites;
          return _createListTitle(Icons.star, qi.name, () => QuoteRepository.info(connector: widget.databaseConnector, quoteInfo: qi));
        });

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: ListView(
            children: <Widget>[
              if (favorites > 0) _createListTitle(Icons.favorite, 'Favorites', () => QuoteRepository.favorite(connector: widget.databaseConnector, name: 'Favorites')),
              _createListTitle(Icons.all_inclusive, 'All', () => QuoteRepository(connector: widget.databaseConnector, name: 'All')),
              ...list
            ],
          ),
        );
      }
    );
  }

  ListTile _createListTitle(IconData icon, String title, Function provider) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Fortune(provider())),
        );
      }
    );
  }

  Future<List<QuoteInfo>> _infos;
}
