import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/quote_repository.dart';
import '../database/model/quote.dart';
import '../app_theme.dart';
import 'quote_changed_notifier.dart';

abstract class QuoteActions {
  Future<void> copy2clipboard(BuildContext context, Quote quote);
  Future<void> share(BuildContext context, Quote quote);
  Future<void> toggleFavorite(BuildContext context, Quote quote);
}

class QuoteActionsImpl implements QuoteActions {
  @override
  Future<void> copy2clipboard(BuildContext context, Quote quote) async {
    _displayInterstitialAd();

    Clipboard.setData(ClipboardData(text: _formatQuote(quote)));

    final tr = AppLocalizations.of(context)!;

    if (isMaterial(context)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr.quoteCopied)
      ));

      return;
    }

    final theme = AppTheme.of(context);

    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: tr.quoteCopied,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      fontSize: theme.labelStyle.fontSize,
      backgroundColor: theme.colorScheme.onBackground,
      textColor: theme.colorScheme.background
    );
  }

  @override
  Future<void> share(BuildContext context, Quote quote) async {
    _displayInterstitialAd();

    await Share.share(_formatQuote(quote),
      subject: 'A quote by ${quote.author.name}'
    );
  }

  @override
  Future<void> toggleFavorite(BuildContext context, Quote quote) async {
    if (_togglesInProgresss.contains(quote.id)) return;

    _displayInterstitialAd();

    try {
      _togglesInProgresss.add(quote.id);

      final notifier = Provider.of<QuoteChangedNotifier>(context, listen: false);
      final repo = Provider.of<QuoteRepository>(context, listen: false);
      final nfav = !quote.favorite;

      quote.favorite = nfav;
      await repo.markFavorite(quote, nfav);
      notifier.quote = quote;
    } finally {
      _togglesInProgresss.remove(quote.id);
    }
  }

  void _displayInterstitialAd() {
  }

  final Set<int> _togglesInProgresss = {};
}

String _formatQuote(Quote quote) {
  final msg = _chopString(quote.quote, 25);
  return '$msg\n${" " * 8}-- ${quote.author.name}';
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