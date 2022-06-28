import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../database/author_repository.dart';
import '../database/model/author.dart';
import '../components/alphabet_bar.dart';
import '../components/search_bar.dart';
import '../quote/quote_service.dart';

class AuthorsView extends StatefulWidget {
  const AuthorsView({Key? key}): super(key: key);

  @override
  State<AuthorsView> createState() => _AuthorsView();
}

class _AuthorsView extends State<AuthorsView> {
  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 0.8 * _scrollController.position.maxScrollExtent) {
        _fetch();
      }
    });

    _authorRepository = Provider.of<AuthorRepository>(context, listen: false);
    _fetchRecords();
    _fetch();

    super.initState();
  }

  @override
  void dispose() {
    _authorsPromise?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _fetching && _authors.isEmpty
      ? Center(child: PlatformCircularProgressIndicator())
      : ListView.builder(
        controller: _scrollController,
        itemCount: _authors.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _authors.length) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: PlatformCircularProgressIndicator()
            );
          }

          return Card(
            child: ListTile(
              title: Text(_authors[index].name),
              subtitle: Text(_authors[index].profession),
              onTap: () => Navigator.pushNamed(context, QuoteService.routeAuthor, arguments: _authors[index]),
            )
          );
        }
      );

    if (_search) {
      return Column(
        children: <Widget>[
          SearchBar(
            searchValue: _searchValue,
            requestFocus: true,
            records: _records,
            onSearch: _onSearch,
            onSearchDone: () {
              setState(() {
                _search = false;
              });
            },
          ),
          /*
          Expanded(
            child: child
          )
          */
        ]
      );
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: AlphabetBar(
        initLetter: _letter,
        onLetter: _onLetter,
        lead: Padding(
          padding: const EdgeInsets.only(right: 2),
          child: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _search = true;
              });
            },
          )
        ),
        child: Container()
        //child: child
      )
    );
  }

  void _fetchRecords() async {
    final records = await _authorRepository.records;
    if (!mounted) return;

    setState(() {
      _records = records;
    });
  }

  void _onSearch(value) async {
    _authorsPromise?.cancel();
    _authorsPromise = CancelableOperation.fromFuture(_authorRepository.search(pattern: value, count: _count));

    setState(() {
      _fetching = true;
      _searchValue = value;
      _authors.clear();
    });

    final authors = await _authorsPromise!.value;
    if (!mounted) return;

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
      _searchValue = '';
      _hasMoreData = true;
      _authors.clear();
      _skip = 0;
    });

    _fetch();
  }

  void _fetch() async {
    if (!_hasMoreData) return;

    _authorsPromise?.cancel();
    _authorsPromise = CancelableOperation.fromFuture(_authorRepository.fetch(startsWith: _letter, count: _count, skip: _skip));

    setState(() {
      _fetching = true;
    });

    final authors = await _authorsPromise!.value;
    if (!mounted) return;

    setState(() {
      _skip += _count;
      _fetching = false;
      _hasMoreData = authors.length >= _count;
      _authors.addAll(authors);
    });
  }

  CancelableOperation<List<Author>>? _authorsPromise;
  late AuthorRepository _authorRepository;
  late int _records;
  var _searchValue = '';
  var _skip = 0;
  var _fetching = false;
  var _hasMoreData = true;
  var _letter = 'A';
  var _search = false;
  final _count = 50;
  final _scrollController = ScrollController();
  final List<Author> _authors = [];
}
