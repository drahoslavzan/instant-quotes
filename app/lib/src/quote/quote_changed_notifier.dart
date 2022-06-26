import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../database/model/quote.dart';

class QuoteChangedNotifier extends ChangeNotifier {
  Quote get quote => _quote;

  set quote(Quote value) {
    _quote = value;
    notifyListeners();
  }

  late Quote _quote;
}
