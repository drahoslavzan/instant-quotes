import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';

class ThemedApp extends StatelessWidget {
  final Widget Function(BuildContext, String?) routeBuilder;

  const ThemedApp({
    Key? key,
    required this.routeBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final mt = AppTheme.isDarkModeRequested
      ? MaterialAppTheme.darkAppTheme()
      : MaterialAppTheme.appTheme();

    final theme = mt.copyWith(
      cupertinoOverrideTheme: CupertinoAppTheme.appTheme(mt)
    );

    return Theme(
      data: theme,
      child: PlatformProvider(
        //initialPlatform: TargetPlatform.iOS,
        settings: PlatformSettingsData(iosUsesMaterialWidgets: true),
        builder:(context) => PlatformApp(
          debugShowCheckedModeBanner: false,

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
            color: AppTheme.appColor,
            theme: CupertinoAppTheme.appTheme(theme),
          ),
          material: (_, __) => MaterialAppData(
            themeMode: ThemeMode.system,
            color: AppTheme.appColor,
            darkTheme: MaterialAppTheme.darkAppTheme(),
            theme: theme,
          ),

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,

          onGenerateRoute: (routeSettings) => platformPageRoute(
            context: context,
            settings: routeSettings,
            builder: (context) => routeBuilder(context, routeSettings.name)
          )
        )
      )
    );
  }
}

