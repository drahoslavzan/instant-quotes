import 'package:flutter/foundation.dart';
import 'author.dart';
import 'tag.dart';

class Quote extends ChangeNotifier {
  final int id;
  final String quote;
  final Author author;
  final List<Tag> tags;

  bool get seen => _seen;
  bool get favorite => _favorite;

  set favorite(value) {
    _favorite = value;
    notifyListeners();
  }

  Quote({this.id, this.quote, this.author, this.tags, seen, favorite })
    : _seen = seen, _favorite = favorite;

  bool _seen;
  bool _favorite;
}