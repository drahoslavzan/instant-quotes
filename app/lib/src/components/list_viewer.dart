import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'list_loader.dart';

class ListViewer<T extends ListLoaderElem<K>, K extends Comparable> extends StatefulWidget {
  final ListLoader<T, K> loader;
  final Widget Function(T elem, int index) factory;
  final double padding;

  const ListViewer({
    Key? key,
    required this.loader,
    required this.factory,
    this.padding = 0
  }) : super(key: key);

  @override
  State<ListViewer<T, K>> createState() => _ListViewerState<T, K>();
}

class _ListViewerState<T extends ListLoaderElem<K>, K extends Comparable>
extends State<ListViewer<T, K>> {
  @override
  void initState() {
    super.initState();
    _positionListener.itemPositions.addListener(() async {
      final cp = _currentPos();
      final pos = await widget.loader.load(position: cp);
      if (cp == pos || !mounted || pos == _currentPos()) return;

      developer.log('jump to $pos');

      // TODO: should jump to the same position inisde the element, not align to the top 

      _scrollController.jumpTo(index: pos);
    });
  }

  @override
  void deactivate() {
    widget.loader.flushSeen();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final pad = widget.padding / 2;

    return AnimatedBuilder(
      animation: widget.loader,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.only(
            left: widget.padding,
            right: widget.padding,
            top: pad,
            bottom: pad
          ),
          child: ScrollablePositionedList.builder(
            shrinkWrap: true,
            itemScrollController: _scrollController,
            itemPositionsListener: _positionListener,
            itemCount: widget.loader.size,
            itemBuilder: (context, index) {
              final elem = widget.loader.elemAt(index);
              if (elem == null) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: PlatformCircularProgressIndicator())
                );
              }

              return Padding(
                key: ValueKey(elem.id),
                padding: EdgeInsets.only(top: pad, bottom: pad),
                child: widget.factory(elem, index)
              );
            }
          )
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
