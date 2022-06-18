import 'package:bestquotes/src/database/quote_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/model/quote.dart';

class QuoteActions {
  void share(BuildContext context, Quote quote) async {
    // TODO: show ad
    await Share.share('${quote.quote}\n\n${" " * 8}--${quote.author.name}', subject: 'A quote by ${quote.author.name}');
  }

  void toggleFavorite(BuildContext context, Quote quote) async {
    // TODO: show ad
    final repo = Provider.of<QuoteRepository>(context, listen: false);
    final nfav = !quote.favorite;
    await repo.markFavorite(quote, nfav);
    quote.favorite = nfav;
  }
}
