import 'dart:io';
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
import 'database/model/author.dart';
import 'database/model/tag.dart';
import 'database/model/quote.dart';
import 'quote/quote_actions.dart';
import 'quote/quotes_view.dart';
import 'quote/quote_service.dart';
import 'components/infinite_list_loader.dart';
import 'quote/fav_quote_changed_notifier.dart';
import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
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
                return FutureBuilder<DatabaseConnector>(
                  future: _setupDB(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const PreparingDBMessage();
                    return MultiProvider(
                      providers: [
                        Provider<QuoteRepository>(
                          lazy: false,
                          create: (_) => QuoteRepository(connector: snapshot.data!)
                        ),
                        Provider<QuoteService>(
                          lazy: false,
                          create: (context) => QuoteService(Provider.of<QuoteRepository>(context, listen: false))
                        ),
                        ChangeNotifierProvider<FavQuoteChangedNotifier>(
                          lazy: false,
                          create: (_) => FavQuoteChangedNotifier(),
                        ),
                        Provider<QuoteActions>(
                          lazy: false,
                          create: (_) => QuoteActions(),
                        ),
                      ],
                      builder: (context, _) {
                        final qs = Provider.of<QuoteService>(context, listen: false);
                        switch (routeSettings.name) {
                          case QuoteService.routeAuthor:
                            final author = ModalRoute.of(context)!.settings.arguments as Author;
                            return Modal(
                              title: author.name,
                              child: QuotesView(
                                loader: SearchableInfiniteListLoader<Quote, int>(fetch: qs.author(author: author).fetch, seen: qs.seen)
                              )
                            );
                          case QuoteService.routeTag:
                            final tag = ModalRoute.of(context)!.settings.arguments as Tag;
                            return Modal(
                              title: tag.name,
                              child: QuotesView(
                                loader: SearchableInfiniteListLoader<Quote, int>(fetch: qs.tag(tag: tag).fetch, seen: qs.seen)
                              )
                            );
                          default:
                            return Tabbed(
                              titles: const [
                                'All Quotes',
                                'Authors',
                                'Favorites',
                              ],
                              tabs: (context) => [
                                BottomNavigationBarItem(
                                  label: 'Quotes',
                                  icon: Icon(context.platformIcons.flag),
                                ),
                                BottomNavigationBarItem(
                                  label: 'Authors',
                                  icon: Icon(context.platformIcons.personSolid),
                                ),
                                BottomNavigationBarItem(
                                  label: 'Favorites',
                                  icon: Icon(context.platformIcons.favoriteSolid),
                                ),
                              ],
                              children: [
                                QuotesView(
                                  loader: SearchableInfiniteListLoader<Quote, int>(fetch: qs.linear().fetch, seen: qs.seen, fetchCount: 3, bufferSize: 7)
                                ),
                                QuotesView(
                                  loader: SearchableInfiniteListLoader<Quote, int>(fetch: qs.random().fetch, seen: qs.seen)
                                ),
                                QuotesView(
                                  loader: SearchableInfiniteListLoader<Quote, int>(fetch: qs.favorite().fetch, seen: qs.seen)
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
    );
  }
}

class PreparingDBMessage extends StatelessWidget {
  const PreparingDBMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformCircularProgressIndicator();
  }
}

Future<DatabaseConnector> _setupDB() async {
  const dbName = 'quotes.db';
  final conn = DatabaseConnector();
  if (conn.isOpened) return conn;

  var documentsDirectory = await getApplicationSupportDirectory();
  var path = join(documentsDirectory.path, dbName);
  if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
    var data = await rootBundle.load(join('assets', dbName));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  }

  await conn.open(path);
  return conn;
}
