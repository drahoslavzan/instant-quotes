import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_theme.dart';

class ThemedApp extends StatelessWidget {
  final TransitionBuilder? builder;
  final RouteFactory? onGenerateRoute;

  const ThemedApp({
    Key? key,
    this.builder,
    this.onGenerateRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

      onGenerateRoute: onGenerateRoute,
      builder: builder,
    );
  }
}

