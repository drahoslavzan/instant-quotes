import '../components/list_loader.dart';
import '../database/quote_repository.dart';
import '../database/model/quote.dart';

typedef QuoteCount = Future<int> Function();

class QuoteFetchCount {
  final ElemFetch<Quote, int> fetch;
  final QuoteCount count;

  const QuoteFetchCount({required this.fetch, required this.count});
}

class QuoteService {
  static const routeAuthor = '/author';
  static const routeTag = '/tag';

  const QuoteService(this._repo);

  QuoteFetchCount linear({String? pattern}) {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip, pattern: pattern),
      count: () => _repo.count(pattern: pattern)
    );
  }

  QuoteFetchCount random({String? match}) {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip, match: match, random: true),
      count: () => _repo.count(match: match)
    );
  }

  QuoteFetchCount favorite({String? pattern}) {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip, pattern: pattern, favorite: true),
      count: () => _repo.count(favorite: true, pattern: pattern)
    );
  }

  QuoteFetchCount tag({required int tagId, String? pattern}) {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip, pattern: pattern, tagId: tagId),
      count: () => _repo.count(tagId: tagId, pattern: pattern)
    );
  }

  QuoteFetchCount author({required int authorId, String? pattern}) {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0}) => _repo.fetch(count: count, skip: skip, authorId: authorId, pattern: pattern),
      count: () => _repo.count(authorId: authorId, pattern: pattern)
    );
  }

  Future<void> seen(Iterable<Quote> quotes) {
    return _repo.markSeen(quotes);
  }

  final QuoteRepository _repo;
}