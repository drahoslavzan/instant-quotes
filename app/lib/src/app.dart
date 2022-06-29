import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'components/tabbed.dart';
import 'components/modal.dart';
import 'database/database_connector.dart';
import 'database/quote_repository.dart';
import 'database/author_repository.dart';
import 'database/model/author.dart';
import 'database/model/tag.dart';
import 'quote/quote_actions.dart';
import 'quote/quotes_view.dart';
import 'quote/quote_service.dart';
import 'quote/quote_card.dart';
import 'quote/fav_quote_card.dart';
import 'quote/quote_changed_notifier.dart';
import 'quote/quote_list_loader.dart';
import 'author/authors_view.dart';
import 'app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DatabaseConnector>(
      future: _openDB(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const PreparingDBMessage();
        return MultiProvider(
          providers: [
            Provider<QuoteRepository>(
              lazy: false,
              create: (_) => QuoteRepository(connector: snapshot.data!)
            ),
            Provider<AuthorRepository>(
              lazy: false,
              create: (_) => AuthorRepository(connector: snapshot.data!)
            ),
            Provider<QuoteActions>(
              lazy: false,
              create: (_) => QuoteActions(),
            ),
            ChangeNotifierProvider<QuoteChangedNotifier>(
              lazy: false,
              create: (_) => QuoteChangedNotifier(),
            ),
            ProxyProvider<QuoteRepository, QuoteService>(
              lazy: false,
              update: (_, repo, __) => QuoteService(repo)
            ),
          ],
          builder: (context, _) {
            return PlatformApp(
              // Providing a restorationScopeId allows the Navigator built by the
              // MaterialApp to restore the navigation stack when a user leaves and
              // returns to the app after it has been killed while running in the
              // background.
              restorationScopeId: 'app',

              // Provide the generated AppLocalizations to the MaterialApp. This
              // allows descendant Widgets to display the correct translations
              // depending on the user's locale.
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English, no country code
              ],

              // Theming
              cupertino: (_, __) => CupertinoAppData(
                debugShowCheckedModeBanner: false,
                color: CupertinoAppTheme.appColor,
                theme: CupertinoAppTheme.appTheme(),
              ),
              material: (_, __) => MaterialAppData(
                debugShowCheckedModeBanner: false,
                themeMode: ThemeMode.system,
                color: MaterialAppTheme.appColor,
                theme: MaterialAppTheme.appTheme(),
                darkTheme: MaterialAppTheme.darkAppTheme(),
              ),

              // Use AppLocalizations to configure the correct application title
              // depending on the user's locale.
              //
              // The appTitle is defined in .arb files found in the localization
              // directory.
              onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,

              // Define a function to handle named routes in order to support
              // Flutter web url navigation and deep linking.
              onGenerateRoute: (RouteSettings routeSettings) {
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (context) {
                    final qs = Provider.of<QuoteService>(context, listen: false);
                    switch (routeSettings.name) {
                    case QuoteService.routeAuthor:
                      final author = ModalRoute.of(context)!.settings.arguments as Author;
                      return Modal(
                        title: author.name,
                        child: QuotesView(
                          loader: QuoteListLoaderImpl(fetch: qs.author(author: author).fetch, seen: qs.seen),
                          factory: ({ key, required quote }) => QuoteCard(key: key, quote: quote),
                        )
                      );
                    case QuoteService.routeTag:
                      final tag = ModalRoute.of(context)!.settings.arguments as Tag;
                      return Modal(
                        title: tag.name,
                        child: QuotesView(
                          loader: QuoteListLoaderImpl(fetch: qs.tag(tag: tag).fetch, seen: qs.seen),
                          factory: ({ key, required quote }) => QuoteCard(key: key, quote: quote),
                        )
                      );
                    default:
                      final fl = FavQuoteListLoaderImpl(fetch: qs.favorite().fetch, seen: qs.seen);
                      return Tabbed(
                        titles: [
                          AppLocalizations.of(context)!.tabTitleQuote,
                          AppLocalizations.of(context)!.tabTitleAuthor,
                          AppLocalizations.of(context)!.tabTitleFavorite,
                        ],
                        tabs: (context) => [
                          BottomNavigationBarItem(
                            label: AppLocalizations.of(context)!.tabNavQuote,
                            icon: Icon(context.platformIcons.flag),
                          ),
                          BottomNavigationBarItem(
                            label: AppLocalizations.of(context)!.tabNavAuthor,
                            icon: Icon(context.platformIcons.person),
                          ),
                          BottomNavigationBarItem(
                            label: AppLocalizations.of(context)!.tabNavFavorite,
                            icon: Icon(context.platformIcons.favoriteSolid),
                          ),
                        ],
                        children: [
                          QuotesView(
                            loader: QuoteListLoaderImpl(fetch: qs.random().fetch, seen: qs.seen),
                            factory: ({ key, required quote }) => QuoteCard(key: key, quote: quote),
                          ),
                          const AuthorsView(),
                          QuotesView(
                            loader: fl,
                            factory: ({ key, required quote }) => FavQuoteCard(key: key, quote: quote, loader: fl),
                          ),
                        ]
                      );
                    }
                  },
                );
              }
            );
          }
        );
      }
    );
  }
}

class PreparingDBMessage extends StatelessWidget {
  const PreparingDBMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      onGenerateTitle: (BuildContext context) =>
        AppLocalizations.of(context)!.appTitle,
      builder: (context, _) {
        return PlatformScaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlatformCircularProgressIndicator(),
                const SizedBox(height: 15),
                PlatformText(AppLocalizations.of(context)!.loadingDb,
                  textAlign: TextAlign.center
                )
              ]
            )
          )
        );
      }
    );
  }
}

Future<DatabaseConnector> _openDB() async {
  const dbName = 'quotes.db';
  final conn = DatabaseConnector();
  if (conn.isOpened) return conn;

  final appDir = await getApplicationSupportDirectory();
  final dbPath = join(appDir.path, dbName);

  try {
    final ft = await FileSystemEntity.type(dbPath);
    if (ft == FileSystemEntityType.file) {
      developer.log('=== OPEN DB ===');
      return conn;
    }

    // NOTE: migrate the db
    if (Platform.isAndroid) {
      final docDir = await getApplicationDocumentsDirectory();
      final path = join(docDir.path, "database.db");
      final ft = await FileSystemEntity.type(path);
      if (ft == FileSystemEntityType.file) {
        developer.log('=== MIGRATE DB ===');
        conn.migrateVer = 0;
        await File(path).copy(dbPath);
        return conn;
      }
    }

    developer.log('=== CREATE DB ===');

    // NOTE: copy from assets
    var data = await rootBundle.load(join('assets', dbName));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes, flush: true);
  } finally {
    await conn.open(dbPath);
  }

  return conn;
}
