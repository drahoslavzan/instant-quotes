import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'database/setup.dart';
import 'database/author_repository.dart';
import 'database/quote_repository.dart';
import 'quote/quotes_view.dart';
import 'quote/quote_service.dart';
import 'quote/quote_card.dart';
import 'quote/fav_quote_card.dart';
import 'quote/quote_list_loader.dart';
import 'author/authors_view.dart';
import 'author/author_loader_factory.dart';
import 'app_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _startBackgroundUpdate();

    final qs = Provider.of<QuoteService>(context, listen: false);
    final ar = Provider.of<AuthorRepository>(context, listen: false);

    _tabs = [
      QuotesView(
        loaderFactory: ({pattern}) => QuoteListLoaderImpl(
          fetch: qs.random(match: pattern).fetch,
          seen: qs.seen
        ),
        quoteFactory: ({ required loader, required quote }) => QuoteCard(
          quote: quote
        ),
      ),
      AuthorsView(loaderFactory: AuthorLoaderFactoryImpl(ar)),
      QuotesView(
        loaderFactory: ({pattern}) => FavQuoteListLoaderImpl(
          fetch: qs.favorite(pattern: pattern).fetch,
          seen: qs.seen,
        ),
        quoteFactory: ({ required loader, required quote }) => FavQuoteCard(
          quote: quote,
          loader: loader as RemovableQuoteListLoader,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final icons = AppIcons.of(context);
    final tr = AppLocalizations.of(context)!;

    return PlatformTabScaffold(
      tabController: _controller,
      items: [
        BottomNavigationBarItem(
          label: tr.tabNavQuote,
          icon: Icon(icons.quote),
        ),
        BottomNavigationBarItem(
          label: tr.tabNavAuthor,
          icon: Icon(icons.author),
        ),
        BottomNavigationBarItem(
          label: tr.tabNavFavorite,
          icon: Icon(icons.favorite),
        ),
      ],
      appBarBuilder: (context, i) {
        return [
          PlatformAppBar(title: PlatformText(tr.tabTitleQuote)),
          PlatformAppBar(title: PlatformText(tr.tabTitleAuthor)),
          PlatformAppBar(title: PlatformText(tr.tabTitleFavorite)),
        ][i];
      },
      bodyBuilder: (context, i) => IndexedStack(
        index: i,
        children: _tabs
      )
    );
  }

  void _startBackgroundUpdate() async {
    await Workmanager().initialize(callbackDispatcher,
      isInDebugMode: kDebugMode
    );
    await Workmanager().registerPeriodicTask('setRandomQuote', 'widgetBackgroundUpdate',
      frequency: const Duration(minutes: 15)
    );
  }

  late List<Widget> _tabs;
  final _controller = PlatformTabController(initialIndex: 0);
}

const _homeWidgetProvider = "QuoteHomeWidgetProvider";

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    final chf = HomeWidget.getWidgetData<int>("cellHeight", defaultValue: 1);
    final conn = await openExistingDb();
    final qr = QuoteRepository(connector: conn);
    final quote = await qr.random(maxLen: (await chf)! * 80);

    final v = await Future.wait<bool?>([
      HomeWidget.saveWidgetData<String>(
        'quote',
        quote.quote,
      ),
      HomeWidget.saveWidgetData<String>(
        'author',
        '-- ${quote.author.name}',
      ),
      HomeWidget.updateWidget(
        name: _homeWidgetProvider,
        iOSName: _homeWidgetProvider,
      ),
    ]);

    return !v.contains(false);
  });
}
