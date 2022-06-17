import '../database/quote_repository.dart';
import '../database/model/quote.dart';
import '../database/model/author.dart';
import '../database/model/tag.dart';

class QuoteProvider {
  final QuoteRepository repo;

  QuoteProvider.favorites(this.repo) {
    _fetch = (int count, int skip) => repo.fetch(count: count, skip: skip, favorites: true);
  }

  QuoteProvider.fromTag(this.repo, {required Tag tag}) {
    _fetch = (int count, int skip) => repo.fetch(count: count, skip: skip, tag: tag);
  }

  QuoteProvider.fromAuthor(this.repo, {required Author author}) {
    _fetch = (int count, int skip) => repo.fetch(count: count, skip: skip, author: author);
  }

  Future<List<Quote>> fetch(int count, {int skip = 0}) {
    return _fetch(count, skip);
  }

  late Function _fetch;
}