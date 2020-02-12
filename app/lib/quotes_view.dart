import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:provider/provider.dart';
import 'database/model/quote.dart';
import 'quote_provider.dart';
import 'quote_card.dart';

class QuotesView extends StatefulWidget {
  final QuoteProvider quoteProvider;
  final double padding;

  const QuotesView({@required this.quoteProvider, this.padding = 30});

  @override
  _QuotesView createState() => _QuotesView();
}

class _QuotesView extends State<QuotesView> {
  @override
  void dispose() {
    // TODO: implement quotes destroy to prevent list being too big
    if (_lastSeen >= 0) {
      final seen = _quotes.sublist(0, _lastSeen + 1);
      widget.quoteProvider.quoteRepository.markSeen(seen);
    }
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

      if (last > _lastSeen) {
        _lastSeen = last;
      }

      if (max >= _quotes.length - 4) {
        _fetch();
      }
    });
    _fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Provider(
        create: (context) => widget.quoteProvider,
        child: SafeArea(
          child: _quotes.isEmpty && _fetching
            ? Center(child: CircularProgressIndicator())
            : _quotes.isEmpty
              ? Center(child: Text('Empty'))
              : ScrollablePositionedList.builder(
                  itemPositionsListener: _positionListener,
                  itemCount: _quotes.length + (_hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _quotes.length) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: CupertinoActivityIndicator()
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.all(widget.padding),
                      child: QuoteCard(_quotes[index])
                    );
                  }
                )
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
  var _lastSeen = -1;
  var _fetching = false;
  var _hasMoreData = true;
  final _positionListener = ItemPositionsListener.create();
  final _quotes = List<Quote>();
  final _count = 10;
}
