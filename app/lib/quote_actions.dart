import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'database/model/quote.dart';
import 'quote_provider.dart';
import 'ad_display.dart';

class QuoteActions {
  QuoteActions() {
    _adDisplay.load();
  }

  void share(BuildContext context, Quote quote) async {
    final action = () async => Share.text('Quote', '${quote.quote}\n\n${" " * 8}--${quote.author.name}', 'text/plain');
    _adDisplay.show(context, action);
  }

  void toggleFavorite(BuildContext context, Quote quote) async {
    final repo = Provider.of<QuoteProvider>(context, listen: false).quoteRepository;
    final nfav = !quote.favorite;
    final action = () async {
      await repo.markFavorite(quote, nfav);
      quote.favorite = nfav;
    };
    _adDisplay.show(context, action);
  }

  final _adDisplay = AdDisplay();
}
