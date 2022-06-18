import '../database/quote_repository.dart';
import '../database/model/quote.dart';
import '../database/model/author.dart';
import '../database/model/tag.dart';

typedef QuoteFetch = Future<List<Quote>> Function(int count, {int skip});

class QuoteService {
  const QuoteService(this._repo);

  QuoteFetch linear() {
    return (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip);
  }

  QuoteFetch random() {
    return (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip, random: true);
  }

  QuoteFetch favorite() {
    return (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip, favorites: true);
  }

  QuoteFetch tag({required Tag tag}) {
    return (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip, tag: tag);
  }

  QuoteFetch author({required Author author}) {
    return (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip, author: author);
  }

  final QuoteRepository _repo;
}