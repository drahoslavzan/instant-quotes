import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'database/database_connector.dart';
import 'database/quote_repository.dart';
import 'quote/quote_actions.dart';
import 'quote/quotes_view.dart';
import 'quote/quote_service.dart';
import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

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
        return MaterialApp(
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

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (context) {
                return FutureBuilder<DatabaseConnector>(
                  future: _createDatabase(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
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
                        Provider<QuoteActions>(
                          lazy: false,
                          create: (_) => QuoteActions(),
                        ),
                      ],
                      builder: (context, _) {
                        switch (routeSettings.name) {
                          case SettingsView.routeName:
                            return SettingsView(controller: settingsController);
                          case SampleItemDetailsView.routeName:
                            return const SampleItemDetailsView();
                          case SampleItemListView.routeName:
                          default:
                            return QuotesView(
                              fetch: Provider.of<QuoteService>(context, listen: false).linear()
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

Future<DatabaseConnector> _createDatabase() async {
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
