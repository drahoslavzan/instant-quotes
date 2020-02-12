import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/quote_repository.dart';
import 'quote_provider.dart';
import 'quotes_view.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage();

  @override
  Widget build(BuildContext context) {
    return QuotesView(
      padding: 14,
      quoteProvider: QuoteProvider.favorites(quoteRepository: Provider.of<QuoteRepository>(context))
    );
  }
}