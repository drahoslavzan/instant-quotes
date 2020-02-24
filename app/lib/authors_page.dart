import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'database/author_repository.dart';
import 'database/model/author.dart';
import 'database/quote_repository.dart';
import 'searchable.dart';
import 'quote_provider.dart';
import 'quotes_view.dart';

class AuthorsPage extends StatefulWidget {
  const AuthorsPage();

  @override
  _AuthorsPageState createState() => _AuthorsPageState();
}

class _AuthorsPageState extends State<AuthorsPage> {
  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 0.8 * _scrollController.position.maxScrollExtent) {
        _fetch();
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _init();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _authorsPromise?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _fetching && _authors.isEmpty
      ? Center(child: CircularProgressIndicator())
      : ListView.builder(
        controller: _scrollController,
        itemCount: _authors.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _authors.length) {
            return Padding(
              padding: EdgeInsets.all(20),
              child: CupertinoActivityIndicator()
            );
          }

          return Card(
            child: ListTile(title: Text(_authors[index].name), subtitle: Text(_authors[index].profession), onTap: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => 
                  QuotesView(quoteProvider: QuoteProvider.fromAuthor(quoteRepository: Provider.of<QuoteRepository>(context), author: _authors[index]))
                ),
              );
            })
          );
        }
      );

    return _search
      ? Searchable(
          searchValue: _searchValue,
          requestFocus: true,
          records: _records,
          onSearch: _onSearch,
          onSearchDone: () {
            setState(() {
              _search = false;
            });
          },
          child: child
        )
      : _AlphabetBar(
          initLetter: _letter,
          onLetter: _onLetter,
          onSearch: () {
            setState(() {
              _search = true;
            });
          },
          child: child
        );
  }

  void _init() {
    if (_authorRepository != null) return;
    _authorRepository = Provider.of<AuthorRepository>(context);
    _fetchRecords();
    _fetch();
  }

  void _fetchRecords() async {
    if (_authorRepository == null) return;

    final records = await _authorRepository.records;

    if (!mounted) return;
    setState(() {
      _records = records;
    });
  }

  void _onSearch(value) async {
    if (_authorRepository == null) return;

    _authorsPromise?.cancel();

    final authorsPromise = CancelableOperation.fromFuture(_authorRepository.search(pattern: value, count: _count));

    setState(() {
      _fetching = true;
      _authorsPromise = authorsPromise;
      _searchValue = value;
      _authors.clear();
    });

    final authors = await authorsPromise.value;

    setState(() {
      _fetching = false;
      _hasMoreData = false;
      _letter = '';
      _authors.addAll(authors);
    });
  }

  void _onLetter(String letter) async {
    if (letter == _letter) return;

    setState(() {
      _letter = letter;
      _searchValue = null;
      _hasMoreData = true;
      _authors.clear();
      _skip = 0;
    });

    _fetch();
  }

  void _fetch() async {
    if (_authorRepository == null || !_hasMoreData) return;

    _authorsPromise?.cancel();

    final authorsPromise = CancelableOperation.fromFuture(_authorRepository.fetch(startsWith: _letter, count: _count, skip: _skip));

    setState(() {
      _fetching = true;
      _authorsPromise = authorsPromise;
    });

    final authors = await authorsPromise.value;

    setState(() {
      _skip += _count;
      _fetching = false;
      _hasMoreData = authors.length >= _count;
      _authors.addAll(authors);
    });
  }

  AuthorRepository _authorRepository;
  CancelableOperation<List<Author>> _authorsPromise;
  int _records;
  String _searchValue;
  var _skip = 0;
  var _fetching = false;
  var _hasMoreData = true;
  var _letter = 'A';
  var _search = false;
  final _authors = List<Author>();
  final _scrollController = ScrollController();
  final _count = 50;
}

class _AlphabetBar extends StatefulWidget {
  final String initLetter;
  final Widget child;
  final Function onLetter;
  final Function onSearch;

  _AlphabetBar({@required this.child, @required this.initLetter, @required this.onLetter, @required this.onSearch});

  @override
  _AlphabetBarState createState() => _AlphabetBarState();
}

class _AlphabetBarState extends State<_AlphabetBar> {
  @override
  void initState() {
    _letter = widget.initLetter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(children: <Widget>[
      widget.child,
      if (_working) Center(child: Container(
        color: Colors.grey.withAlpha(128),
        padding: const EdgeInsets.all(50),
        child: Text(_letter, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold))
      ))
    ]);

    return Column(children: <Widget>[
      Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    widget.onSearch();
                  });
                },
              )
            ),
            Expanded(
              child: GestureDetector(
                key: _key,
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (details) {
                  _setLetter(details);
                },
                onHorizontalDragUpdate: (details) {
                  _setLetter(details);
                },
                onHorizontalDragEnd: (details) {
                  _update();
                },
                onPanStart: (details) {
                  _setLetter(details);
                },
                onPanUpdate: (details) {
                  _setLetter(details);
                },
                onPanEnd: (details) {
                  _update();
                },
                onTapUp: (details) {
                  _setLetter(details);
                  _update();
                },
                child: Wrap(
                  spacing: 8,
                  children: _alphabet.map((a) {
                    return MetaData(
                      metaData: a,
                      child: a == _letter
                        ? Text(a, style: TextStyle(color: Colors.deepOrange))
                        : Text(a)
                    );
                  }).toList()
                )
              )
            )
          ]
        )
      ),
      Expanded(child: child)
    ]);
  }

  void _update() {
    widget.onLetter(_letter);

    setState(() {
      _working = false;
    });
  }

  void _setLetter(details) {
    final lp = details.localPosition;
    if (lp.dx < 0 || lp.dy < 0) return;

    final RenderBox obj = _key.currentContext.findRenderObject();
    final size = obj.size;

    if (lp.dx >= size.width || lp.dy >= size.height) return;

    final res = BoxHitTestResult();
    if (!obj.hitTest(res, position: lp)) return;

    final meta = res.path.firstWhere((p) => p.target is RenderMetaData, orElse: () => null);

    if (meta == null) return;

    final letter = (meta.target as RenderMetaData).metaData;

    setState(() {
      _working = true;
      _letter = letter;
    });
  }

  String _letter;
  var _working = false;
  final GlobalKey _key = GlobalKey();
  static const _alphabet = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
}