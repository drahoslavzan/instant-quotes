import 'package:flutter/material.dart';

import '../database/model/quote.dart';
import 'quote_list_loader.dart';

typedef QuoteFactory = BaseQuoteCard Function({
  required Quote quote,
  required QuoteListLoader loader
});

abstract class BaseQuoteCard extends Widget {
  final Quote quote;

  const BaseQuoteCard({Key? key, required this.quote}): super(key: key);
}