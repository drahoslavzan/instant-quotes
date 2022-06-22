import '../components/infinite_list_loader.dart';
import '../database/quote_repository.dart';
import '../database/model/quote.dart';
import '../database/model/author.dart';
import '../database/model/tag.dart';

typedef QuoteCount = Future<int> Function();

class QuoteFetchCount {
  final ElemFetch<Quote> fetch;
  final QuoteCount count;

  const QuoteFetchCount({required this.fetch, required this.count});
}

class QuoteService {
  static const routeAuthor = '/author';
  static const routeTag = '/tag';

  const QuoteService(this._repo);

  QuoteFetchCount linear() {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0, List<int>? ids}) => _repo.fetch(ids: ids, count: count, skip: skip),
      count: () => _repo.count()
    );
  }

  QuoteFetchCount random() {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0, List<int>? ids}) => _repo.fetch(ids: ids, count: count, skip: skip, random: true),
      count: () => _repo.count()
    );
  }

  QuoteFetchCount favorite() {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0, List<int>? ids}) => _repo.fetch(ids: ids, count: count, skip: skip, favorite: true),
      count: () => _repo.count(favorite: true)
    );
  }

  QuoteFetchCount tag({required Tag tag}) {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0, List<int>? ids}) => _repo.fetch(ids: ids, count: count, skip: skip, tag: tag),
      count: () => _repo.count(tag: tag)
    );
  }

  QuoteFetchCount author({required Author author}) {
    return QuoteFetchCount(
      fetch: (int count, {int skip = 0, List<int>? ids}) => _repo.fetch(ids: ids, count: count, skip: skip, author: author),
      count: () => _repo.count(author: author)
    );
  }

  Future<void> seen(Iterable<Quote> quotes) {
    return _repo.markSeen(quotes);
  }

  final QuoteRepository _repo;
}