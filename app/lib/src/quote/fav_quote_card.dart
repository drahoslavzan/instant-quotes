import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';

import '../database/model/quote.dart';
import 'quote_list_loader.dart';
import 'base_quote_card.dart';
import 'quote_card.dart';

class FavQuoteCard extends StatefulWidget implements BaseQuoteCard {
  final RemovableQuoteListLoader loader;

  @override
  final Quote quote;

  FavQuoteCard({required this.loader, required this.quote})
    : super(key: ValueKey(quote.id));

  @override
  State<FavQuoteCard> createState() => _FavQuoteCardState();
}

class _FavQuoteCardState extends State<FavQuoteCard> {
  @override
  void initState() {
    developer.log('init, quote: ${widget.quote.id}');
    widget.quote.addListener(_onChanged);
    // NOTE: if not favorite, remove immediatelly
    WidgetsBinding.instance.addPostFrameCallback((_) => _onChanged());
    super.initState();
  }

  @override
  void dispose() {
    developer.log('disposed, quote: ${widget.quote.id}');
    widget.quote.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(_dx, 0.0),
      curve: Curves.fastOutSlowIn,
      duration: const Duration(milliseconds: 800),
      child: QuoteCard(quote: widget.quote),
      onEnd: () {
        developer.log('remove ${widget.quote.id}');
        widget.loader.remove(widget.quote.id);
      }
    );
  }

  void _onChanged() {
    if (widget.quote.favorite) return;

    developer.log('quote id ${widget.quote.id}, favorite: ${widget.quote.favorite}');

    setState(() {
      _dx = (_random.nextBool() ? 1 : -1) *  1.2;
    });
  }

  var _dx = 0.0;
  static final _random = Random();
}