import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'database/quote_repository.dart';
import 'database/model/quote.dart';

class QuotesView extends StatefulWidget {
  const QuotesView();

  @override
  _QuotesView createState() => _QuotesView();
}

class _QuotesView extends State<QuotesView> {
  @override
  void didChangeDependencies() {
    _init();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Text(
          'aaa'
        )
      )
    );
  }

  void _init() {
    if (_quoteRepository != null) return;
    _quoteRepository = Provider.of<QuoteRepository>(context);
  }

  QuoteRepository _quoteRepository;
  CancelableOperation<List<Quote>> _quotesPromise;
  final _quotes = List<Quote>();
}
