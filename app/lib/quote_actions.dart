import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'database/model/quote.dart';
import 'quote_provider.dart';

class QuoteActions {
  QuoteActions() {
    _ad = _createAd();
  }

  void share(BuildContext context, Quote quote) {
    _action = () async => Share.text('Quote', '${quote.quote}\n\n    --${quote.author.name}', 'text/plain');
    _showAd();
  }

  void toggleFavorite(BuildContext context, Quote quote) async {
    final repo = Provider.of<QuoteProvider>(context, listen: false).quoteRepository;
    final nfav = !quote.favorite;
    final action = () async {
      await repo.markFavorite(quote, nfav);
      quote.favorite = nfav;
    };

    if (nfav) {
      _action = action;
      _showAd();
      return;
    }

    await action();
  }

  void _showAd() {
    _ad.show();
  }

  InterstitialAd _createAd() {
    return InterstitialAd(
      adUnitId: kReleaseMode ? _intAdUnitId : InterstitialAd.testAdUnitId,
      targetingInfo: _targetingInfo,
      listener: (MobileAdEvent event) async {
        if (event == MobileAdEvent.closed) {
          await _action();
          _ad.dispose();
          _action = null;
          _ad = _createAd();
        }
    })..load();
  }

  MobileAd _ad;
  Function _action;
  static const _intAdUnitId = 'ca-app-pub-5625584276004610/1791707949';
  static const _testDevice = '2A54B77CB09A19B5B0C7EC5DB89400E3';
  static const MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo(
    testDevices: _testDevice != null ? <String>[_testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Quotes'],
  );
}