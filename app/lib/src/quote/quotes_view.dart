import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'quote_loader.dart';
import 'quote_card.dart';

class QuotesView extends StatefulWidget {
  final QuoteLoader loader;
  final double padding;

  const QuotesView({Key? key, required this.loader, this.padding = 16})
    : super(key: key);

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  @override
  void initState() {
    _positionListener.itemPositions.addListener(() async {
      final cp = _currentPos();
      final pos = await widget.loader.load(position: cp);
      if (cp == pos || !mounted || pos == _currentPos()) return;

      developer.log('jump to $pos');

      _scrollController.jumpTo(index: pos);
    });

    super.initState();
  }

  @override
  void deactivate() {
    widget.loader.flushSeen();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.loader,
      builder: (context, _) {
        return ScrollablePositionedList.builder(
          itemScrollController: _scrollController,
          itemPositionsListener: _positionListener,
          itemCount: widget.loader.size,
          itemBuilder: (context, index) {
            final quote = widget.loader.quoteAt(index);
            if (quote == null) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: PlatformCircularProgressIndicator())
              );
            }

            return Padding(
              key: ValueKey(quote.id),
              padding: EdgeInsets.only(left: widget.padding, right: widget.padding, top: 10, bottom: 10),
              child: QuoteCard(quote: quote)
            );
          }
        );
      }
    );
  }

  int _currentPos() {
    final positions = _positionListener.itemPositions.value;
    if (positions.isEmpty) return 0;

    final item = positions
      .where((position) => position.itemLeadingEdge < 1)
      .reduce((max, pos) => pos.itemLeadingEdge > max.itemLeadingEdge ? pos : max);

    return item.index - 1;
  }

  final _scrollController = ItemScrollController();
  final _positionListener = ItemPositionsListener.create();
}
