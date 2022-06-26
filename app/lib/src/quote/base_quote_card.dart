import 'package:flutter/material.dart';

import '../database/model/quote.dart';

typedef QuoteFactory = BaseQuoteCard Function({Key? key, required Quote quote});

abstract class BaseQuoteCard extends Widget {
  final Quote quote;

  const BaseQuoteCard({Key? key, required this.quote}): super(key: key);
}