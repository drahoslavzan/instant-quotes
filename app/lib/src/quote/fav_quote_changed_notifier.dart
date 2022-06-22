import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../database/model/quote.dart';

class FavQuoteChangedNotifier extends ChangeNotifier {
  Quote? quote;

  set favorite(Quote quote) {
    this.quote = quote;
    notifyListeners();
  }
}
