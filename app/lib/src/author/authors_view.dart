import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/list_viewer.dart';
import '../components/alphabet_bar.dart';
import '../components/search_edit.dart';
import '../database/model/author.dart';
import '../quote/quote_service.dart';
import '../app_icons.dart';
import 'author_loader_factory.dart';

class AuthorsView extends StatefulWidget {
  final AuthorLoaderFactory loaderFactory;

  const AuthorsView({
    Key? key,
    required this.loaderFactory
  }): super(key: key);

  @override
  State<AuthorsView> createState() => _AuthorsView();
}

class _AuthorsView extends State<AuthorsView> {
  @override
  void initState() {
    _loader = widget.loaderFactory.search(startsWith: _letter);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final icons = AppIcons.of(context);
    const pad = 8.0;

    final child = ListViewer<Author, int>(
      loader: _loader,
      factory: (a, _) {
        return ListTile(
          title: Text(a.name),
          subtitle: Text(a.profession),
          trailing: Icon(icons.forwoard),
          onTap: () => Navigator.pushNamed(context, QuoteService.routeAuthor, arguments: a),
        );
      }
    );

    if (_search) {
      return Column(
        children: <Widget>[
          SearchEdit(
            padding: pad,
            hint: tr.search,
            onSearch: _onSearch,
            focus: true,
          ),
          Expanded(
            child: child
          )
        ]
      );
    }

    return AlphabetBar(
      padding: pad,
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
      child: child
    );
  }

  void _onSearch(String value) async {
    if (value.isEmpty) {
      setState(() {
        _search = false;
        _loader = widget.loaderFactory.search(startsWith: _letter);
      });

      return;
    }

    setState(() {
      _search = true;
      _loader = widget.loaderFactory.search(pattern: value);
    });
  }

  void _onLetter(String letter) async {
    if (letter == _letter) return;

    setState(() {
      _letter = letter;
      _loader = widget.loaderFactory.search(startsWith: letter);
    });
  }

  late AuthorListLoader _loader;
  var _letter = 'A';
  var _search = false;
}
