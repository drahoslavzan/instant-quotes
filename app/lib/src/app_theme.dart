import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

abstract class AppTheme extends ChangeNotifier {
  final BuildContext context;
  final ThemeData theme;

  static Color get appColor => Colors.black;

  static bool get isDarkModeRequested =>
    Brightness.dark == SchedulerBinding.instance.window.platformBrightness;

  factory AppTheme.of(BuildContext context) => isMaterial(context)
    ? MaterialAppTheme(context)
    : CupertinoAppTheme(context);

  AppTheme(this.context): theme = Theme.of(context);

  bool get isDark => isDarkModeRequested;

  Color get errorColor => theme.errorColor;
  Color get successColor => Colors.green[500]!;
  Color get dangerColor => Colors.red[500]!;
  Color get favoriteColor => Colors.red[500]!;
  Color get noFavoriteColor => theme.hintColor;
  Color get disabledColor => theme.backgroundColor;

  ColorScheme get colorScheme => theme.colorScheme;

  TextStyle get titleStyle;
  TextStyle get labelStyle;
  TextStyle get sublabelStyle;

  TextStyle get quoteStyle => TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: titleStyle.fontSize! - 3,
  );

  TextStyle get letterStyle => TextStyle(
    color: colorScheme.onSurface,
    fontWeight: FontWeight.normal,
    fontSize: labelStyle.fontSize! + 2,
  );

  TextStyle get selectedLetterStyle => TextStyle(
    color: colorScheme.background,
    fontWeight: FontWeight.bold,
    fontSize: labelStyle.fontSize! + 2,
  );

  TextStyle get authorStyle => labelStyle.copyWith(
    color: colorScheme.secondary,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
  );

  SystemUiOverlayStyle get overlayStyle;
}

class MaterialAppTheme extends AppTheme {
  static ThemeData appTheme() => _adjustTheme(FlexColorScheme.light(
    scheme: FlexScheme.bigStone,
    appBarStyle: FlexAppBarStyle.primary,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  ).toTheme);

  static ThemeData darkAppTheme() => _adjustTheme(FlexColorScheme.dark(
    scheme: FlexScheme.bigStone,
    appBarStyle: FlexAppBarStyle.primary,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
  ).toTheme);

  static ThemeData _adjustTheme(ThemeData theme) => theme.copyWith(
    dialogTheme: theme.dialogTheme.copyWith(
      backgroundColor: theme.colorScheme.background.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
    )
  );

  MaterialAppTheme(BuildContext context): super(context);

  @override
  bool get isDark => theme.brightness == Brightness.dark;

  @override
  TextStyle get titleStyle => theme.textTheme.headline5!;
  @override
  TextStyle get labelStyle => theme.textTheme.subtitle1!;
  @override
  TextStyle get sublabelStyle => theme.textTheme.subtitle2!;

  @override
  SystemUiOverlayStyle get overlayStyle => FlexColorScheme.themedSystemNavigationBar(context, noAppBar: true);
}

class CupertinoAppTheme extends AppTheme {
  late CupertinoThemeData ios;

  static CupertinoThemeData appTheme(ThemeData theme) => CupertinoThemeData(
    //primaryColor: theme.primaryColor,
    brightness: theme.brightness,
    scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
    barBackgroundColor: theme.backgroundColor
  );

  CupertinoAppTheme(BuildContext context)
    : ios = CupertinoTheme.of(context)
    , super(context);

  @override
  TextStyle get titleStyle => ios.textTheme.navLargeTitleTextStyle.copyWith(fontSize: ios.textTheme.navLargeTitleTextStyle.fontSize! - 8);
  @override
  TextStyle get labelStyle => ios.textTheme.navTitleTextStyle.copyWith(fontSize: ios.textTheme.navTitleTextStyle.fontSize! - 3);
  @override
  TextStyle get sublabelStyle => ios.textTheme.textStyle.copyWith(fontSize: ios.textTheme.textStyle.fontSize! - 5);

  @override
  SystemUiOverlayStyle get overlayStyle => isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
}