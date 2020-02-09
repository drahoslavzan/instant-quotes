import 'database/quote_repository.dart';
import 'database/model/quote.dart';
import 'database/model/author.dart';
import 'database/model/topic.dart';
import 'database/model/tag.dart';

class QuoteProvider {
  QuoteProvider.favorites({this.quoteRepository}) {
    _fetch = (int count, int skip) => quoteRepository.fetch(count: count, skip: skip, favorites: true);
  }

  QuoteProvider.fromTopic({this.quoteRepository, Topic topic}) {
    _fetch = (int count, int skip) => quoteRepository.fetch(count: count, skip: skip, topic: topic);
  }

  QuoteProvider.fromTag({this.quoteRepository, Tag tag}) {
    _fetch = (int count, int skip) => quoteRepository.fetch(count: count, skip: skip, tag: tag);
  }

  QuoteProvider.fromAuthor({this.quoteRepository, Author author}) {
    _fetch = (int count, int skip) => quoteRepository.fetch(count: count, skip: skip, author: author);
  }

  Future<List<Quote>> fetch({int count, int skip = 0}) {
    return _fetch(count, skip);
  }

  Function _fetch;
  final QuoteRepository quoteRepository;
}