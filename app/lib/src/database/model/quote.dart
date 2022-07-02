import 'package:flutter/foundation.dart';

import '../../components/list_loader.dart';
import 'author.dart';
import 'tag.dart';

class Quote extends ChangeNotifier implements ListLoaderElem<int> {
  @override final int id;
  final String quote;
  final Author author;
  final List<Tag> tags;
  final bool seen;

  bool get favorite => _favorite;

  set favorite(value) {
    _favorite = value;
    notifyListeners();
  }

  Quote({
    required this.id,
    required this.quote,
    required this.author,
    required this.tags,
    required this.seen,
    required favorite
  }) : _favorite = favorite;

  Quote.from(Quote quote):
    id = quote.id,
    quote = quote.quote,
    author = Author.from(quote.author),
    tags = quote.tags.map((t) => Tag.from(t)).toList(),
    seen = quote.seen,
    _favorite = quote.favorite;

  bool _favorite;
}