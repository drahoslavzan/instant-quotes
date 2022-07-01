import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../components/list_viewer.dart';
import '../database/model/quote.dart';
import 'quote_list_loader.dart';
import 'base_quote_card.dart';
import 'quote_changed_notifier.dart';

/*
* TODO:
* show random tags, show short quotes
* add copy button on Android

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
    super.initState();
  }

  @override
  void dispose() {
    _notifier.removeListener(_onFavoriteChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListViewer<Quote, int>(
      padding: widget.padding,
      loader: widget.loader,
      factory: (e, _) => widget.factory(quote: e)
    );
  }

  void _onFavoriteChanged() {
    widget.loader.favoriteChanged(_notifier.quote);
  }

  late QuoteChangedNotifier _notifier;
}
