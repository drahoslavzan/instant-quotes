import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'database/model/quote.dart';
import 'quote_provider.dart';
import 'quote_card.dart';

class QuotesView extends StatefulWidget {
  final QuoteProvider quoteProvider;

  const QuotesView({@required this.quoteProvider});

  @override
  _QuotesView createState() => _QuotesView();
}

class _QuotesView extends State<QuotesView> {
  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 0.8 * _scrollController.position.maxScrollExtent) {
        _fetch();
      }
    });
    _fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _quotes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
            controller: _scrollController,
            itemCount: _quotes.length + (_hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _quotes.length) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: CupertinoActivityIndicator()
                );
              }

              return QuoteCard(_quotes[index]);
            }
          )
      )
    );
  }

  void _fetch() async {
    if (_fetching || !_hasMoreData) return;

    setState(() {
      _fetching = true;
    });

    final quotes = await widget.quoteProvider.fetch(count: _count, skip: _skip);

    if (!mounted) return;
    setState(() {
      _skip += _count;
      _hasMoreData = quotes.length >= _count;
      _fetching = false;
      _quotes.addAll(quotes);
    });
  }

  var _skip = 0;
  var _fetching = false;
  var _hasMoreData = true;
  final _scrollController = ScrollController();
  final _quotes = List<Quote>();
  final _count = 10;
}
