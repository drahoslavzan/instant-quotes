import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'quote_list_loader.dart';
import 'base_quote_card.dart';
import 'quote_changed_notifier.dart';

/*
* TODO:
* check if seen works correctly
* theme color for author name
* all widgets should be platform widgets
* all strings should be thorough localization
* increase quotes fetch count
* remove favorite from list

* Prevent opening new page (e.g. for tag) if the same tag is already open
* Prevent removing favorite if it has been removed already (effect)
* Use theme font size insead of a fixed number
* Share button on the app bar should share about the app

* remove favorite loader ???, do animation while removing favorite item
*/

class QuotesView extends StatefulWidget {
  final QuoteListLoader loader;
  final QuoteFactory factory;
  final double padding;

  const QuotesView({
    Key? key,
    required this.loader,
    required this.factory,
    this.padding = 16
  }) : super(key: key);

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  @override
  void initState() {
    _notifier = Provider.of<QuoteChangedNotifier>(context, listen: false);
    _notifier.addListener(_onFavoriteChanged);
    _positionListener.itemPositions.addListener(() async {
      final cp = _currentPos();
      final pos = await widget.loader.load(position: cp);
      if (cp == pos || !mounted || pos == _currentPos()) return;

      developer.log('jump to $pos');

      // TODO: should jump to the same position inisde the element, not align to the top 

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
  void dispose() {
    _notifier.removeListener(_onFavoriteChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.loader,
      builder: (context, _) {
        return ScrollablePositionedList.builder(
          shrinkWrap: true,
          itemScrollController: _scrollController,
          itemPositionsListener: _positionListener,
          itemCount: widget.loader.size,
          itemBuilder: (context, index) {
            final quote = widget.loader.elemAt(index);
            if (quote == null) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: PlatformCircularProgressIndicator())
              );
            }

            return Padding(
              key: ValueKey(quote.id),
              padding: EdgeInsets.only(left: widget.padding, right: widget.padding, top: 10, bottom: 10),
              child: widget.factory(quote: quote)
            );
          }
        );
      }
    );
  }

  void _onFavoriteChanged() {
    widget.loader.favoriteChanged(_notifier.quote);
  }

  int _currentPos() {
    final positions = _positionListener.itemPositions.value;
    if (positions.isEmpty) return 0;

    final item = positions
      .where((position) => position.itemLeadingEdge < 1)
      .reduce((max, pos) => pos.itemLeadingEdge > max.itemLeadingEdge ? pos : max);

    return item.index - 1;
  }

  late QuoteChangedNotifier _notifier;
  final _scrollController = ItemScrollController();
  final _positionListener = ItemPositionsListener.create();
}
