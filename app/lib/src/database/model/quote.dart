import 'package:flutter/foundation.dart';

import '../../components/list_loader.dart';
import 'author.dart';
import 'tag.dart';

class Quote extends ChangeNotifier implements ListLoaderElem<int> {
  final String quote;
  final Author author;
  final List<Tag> tags;
  final bool seen;

  @override final int id;

  bool get favorite => _favorite;

  set favorite(value) {
    _favorite = value;
    notifyListeners();
  }

  Quote({required this.id, required this.quote, required this.author, required this.tags, required this.seen, required favorite })
    : _favorite = favorite;

  bool _favorite;
}