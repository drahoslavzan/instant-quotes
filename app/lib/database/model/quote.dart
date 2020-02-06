import 'author.dart';
import 'tag.dart';

class Quote {
  int id;
  String quote;
  bool seen;
  bool favorite;
  Author author;
  List<Tag> tags;

  Quote({this.id, this.quote, this.seen, this.favorite, this.author, this.tags});
}