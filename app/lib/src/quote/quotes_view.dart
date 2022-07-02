import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/list_viewer.dart';
import '../components/search_edit.dart';
import '../database/model/quote.dart';
import 'quote_list_loader.dart';
import 'base_quote_card.dart';
import 'quote_changed_notifier.dart';

class QuotesView extends StatefulWidget {
  final QuoteListLoader Function({String? pattern}) loaderFactory;
  final QuoteFactory quoteFactory;
  final double padding;

  const QuotesView({
    Key? key,
    required this.loaderFactory,
    required this.quoteFactory,
    this.padding = 16
  }) : super(key: key);

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  @override
  void initState() {
    _loader = widget.loaderFactory();
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
    final tr = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        SearchEdit(
          padding: 8,
          hint: tr.search,
          onSearch: (value) {
            setState(() {
              _loader.flushSeen();
              _loader = widget.loaderFactory(
                pattern: value.isEmpty ? null : value
              );
            });
          },
        ),
        Expanded(
          child: ListViewer<Quote, int>(
            padding: widget.padding,
            loader: _loader,
            factory: (e, _) => widget.quoteFactory(quote: e, loader: _loader)
          )
        )
      ]
    );
  }

  void _onFavoriteChanged() {
    _loader.favoriteChanged(_notifier.quote);
  }

  late QuoteChangedNotifier _notifier;
  late QuoteListLoader _loader;
}
