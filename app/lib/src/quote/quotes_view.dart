import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:provider/provider.dart';

import '../database/quote_repository.dart';
import '../database/model/quote.dart';
import 'quote_service.dart';
import 'quote_card.dart';

class QuotesView extends StatefulWidget {
  final QuoteFetch fetch;
  final double padding;

  const QuotesView({Key? key, required this.fetch, this.padding = 16})
    : super(key: key);

  @override
  State<QuotesView> createState() => _QuotesView();
}

class _QuotesView extends State<QuotesView> {
  @override
  void dispose() {
    _markSeen();
    super.dispose();
  }

  @override
  void initState() {
    _positionListener.itemPositions.addListener(() {
      final positions = _positionListener.itemPositions.value;
      if (positions.isEmpty) return;

      final max = positions
        .where((ItemPosition position) => position.itemLeadingEdge < 1)
        .reduce((ItemPosition max, ItemPosition position) =>
          position.itemLeadingEdge > max.itemLeadingEdge
            ? position
            : max)
        .index;

      final last = max - 1;

      if (last > _seenTo) {
        _seenTo = last;
      }

      if (max >= _quotes.length - _endCount) {
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
        child: _quotes.isEmpty && _fetching
          ? const Center(child: CircularProgressIndicator())
          : _quotes.isEmpty
            ? const Center(child: Text('Empty'))
            : ScrollablePositionedList.builder(
                itemPositionsListener: _positionListener,
                itemCount: _quotes.length + (_hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _quotes.length) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: CupertinoActivityIndicator()
                    );
                  }

                  final quote = _quotes[index];

                  return Padding(
                    padding: EdgeInsets.only(left: widget.padding, right: widget.padding, top: 10, bottom: 10),
                    child: QuoteCard(quote: quote)
                  );
                }
              )
      )
    );
  }

  Future<void> _markSeen() async {
    if (_seenTo < 1) return;
    final to = _seenTo + 1;
    final seen = _quotes.sublist(_seenFrom, to);
    final qr = Provider.of<QuoteRepository>(context, listen: false);
    await qr.markSeen(seen);
    developer.log("seen: [$_seenFrom, $to]");
    _seenFrom = to;
  }

  void _fetch() async {
    if (_fetching || !_hasMoreData) return;

    developer.log("fetch quotes");

    setState(() {
      _fetching = true;
    });

    await _markSeen();
    final quotes = await widget.fetch(_count, skip: _skip);

    if (!mounted) return;
    setState(() {
      _skip += _count;
      _hasMoreData = quotes.length >= _count;
      _fetching = false;
      _quotes.addAll(quotes);
    });
  }

  var _skip = 0;
  var _seenFrom = 0;
  var _seenTo = -1;
  var _fetching = false;
  var _hasMoreData = true;
  final _positionListener = ItemPositionsListener.create();
  final List<Quote> _quotes = []; 
  static const _count = 5;
  static const _endCount = 2;
}
