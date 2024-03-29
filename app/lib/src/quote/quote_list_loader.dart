import '../components/list_loader.dart';
import '../components/infinite_list_loader.dart';
import '../database/model/quote.dart';

abstract class QuoteListLoader
implements ListLoader<Quote, int> {
  void favoriteChanged(Quote quote);
}

abstract class RemovableQuoteListLoader
implements RemovableListLoader<Quote, int> {}

class QuoteListLoaderImpl
extends InfiniteListLoader<Quote, int>
with SearchableListLoaderImpl<Quote, int>
implements QuoteListLoader {
  QuoteListLoaderImpl({
    required super.fetch,
    required super.seen,
    super.bufferSize = 250,
    super.fetchCount = 50,
  });

  @override
  void favoriteChanged(Quote quote) {
    final q = find(quote.id);
    if (q == null) return;
    q.favorite = quote.favorite;
  }
}

class FavQuoteListLoaderImpl
extends InfiniteListLoader<Quote, int>
with SearchableListLoaderImpl<Quote, int>,
     RemovableListLoaderImpl<Quote, int>,
     InsertableListLoaderImpl<Quote, int>
implements QuoteListLoader,
           RemovableQuoteListLoader {
  FavQuoteListLoaderImpl({
    required super.fetch,
    required super.seen,
    super.bufferSize = 250,
    super.fetchCount = 50,
  });

  @override
  void favoriteChanged(Quote quote) {
    final q = find(quote.id);
    if (q == null) {
      if (quote.favorite) insert(Quote.from(quote));
      return;
    }

    q.favorite = quote.favorite;
  }
}
