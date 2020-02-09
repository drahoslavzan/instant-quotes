import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'database/author_repository.dart';
import 'database/model/author.dart';

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
  Widget build(BuildContext context) {
    return _AlphabetBar(
      initLetter: _letter,
      onLetter: _onLetter,
      disabled: _fetching,
      child: _fetching && _authors.isEmpty
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
              child: ListTile(title: Text(_authors[index].name), onTap: () {
                // TODO: navigate
              })
            );
          }
        )
    );
  }

  void _init() {
    if (_authorRepository != null) return;
    _authorRepository = Provider.of<AuthorRepository>(context);
    _fetch();
  }

  void _onLetter(String letter) async {
    if (letter == _letter) return;

    setState(() {
      _letter = letter;
      _hasMoreData = true;
      _authors.clear();
      _skip = 0;
    });

    _fetch();
  }

  void _fetch() async {
    if (_authorRepository == null || _fetching || !_hasMoreData) return;

    setState(() {
      _fetching = true;
    });

    final authors = await _authorRepository.fetch(startsWith: _letter, count: _count, skip: _skip);

    if (!mounted) return;
    setState(() {
      _skip += _count;
      _hasMoreData = authors.length >= _count;
      _fetching = false;
      _authors.addAll(authors);
    });
  }

  AuthorRepository _authorRepository;
  var _skip = 0;
  var _fetching = false;
  var _hasMoreData = true;
  var _letter = 'A';
  final _authors = List<Author>();
  final _scrollController = ScrollController();
  final _count = 50;
}

class _AlphabetBar extends StatefulWidget {
  final String initLetter;
  final Widget child;
  final Function onLetter;
  final bool disabled;

  _AlphabetBar({@required this.child, @required this.initLetter, @required this.onLetter, this.disabled = false});

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
    return Row(children: <Widget>[
      Expanded(child: Stack(children: <Widget>[
        widget.child,
        if (_working) Center(child: Container(
          color: Colors.grey.withAlpha(128),
          padding: const EdgeInsets.all(50),
          child: Text(_letter, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.deepOrange))
        ))
      ])),
      Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GestureDetector(
            key: _key,
            behavior: HitTestBehavior.translucent,
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _alphabet.map((a) {
                  return a == _letter
                    ? Text(a, style: TextStyle(color: Colors.deepOrange))
                    : Text(a);
                }).toList()
              )
            )
          ),
        ),
      )
    ]);
  }

  void _update() {
    widget.onLetter(_letter);

    setState(() {
      _working = false;
    });
  }

  void _setLetter(details) {
    if (widget.disabled || details.localPosition.dx < 0) return;

    final RenderBox obj = _key.currentContext.findRenderObject();
    final size = obj.size;

    final p = (details.localPosition.dy / size.height).clamp(0, 1);
    final k = (p * (_alphabet.length - 1)).round();

    setState(() {
      _working = true;
      _letter = _alphabet[k];
    });
  }

  String _letter;
  var _working = false;
  final GlobalKey _key = GlobalKey();
  static const _alphabet = ['#','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
}