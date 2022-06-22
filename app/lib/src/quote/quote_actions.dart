import 'package:bestquotes/src/database/quote_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/model/quote.dart';
import 'fav_quote_changed_notifier.dart';

class QuoteActions {
  void share(BuildContext context, Quote quote) async {
    // TODO: show ad

    final msg = _chopString(quote.quote, 25);
    await Share.share('$msg\n${" " * 8}-- ${quote.author.name}', subject: 'A quote by ${quote.author.name}');
  }

  void toggleFavorite(BuildContext context, Quote quote) async {
    // TODO: show ad

    final notifier = Provider.of<FavQuoteChangedNotifier>(context, listen: false);
    final repo = Provider.of<QuoteRepository>(context, listen: false);
    final nfav = !quote.favorite;
    await repo.markFavorite(quote, nfav);
    quote.favorite = nfav;
    notifier.quote = quote;
  }
}

String _chopString(String str, int width) {
  final words = str.split(RegExp(r'\s+'));

  var msg = '';
  var line = '';
  for (var word in words) {
    line += '$word ';
    if (line.length >= width) {
      msg += '${line.trimRight()}\n';
      line = '';
      continue;
    }
  }

  if (line.isNotEmpty) {
    msg += '${line.trimRight()}\n';
  }

  return msg;
}