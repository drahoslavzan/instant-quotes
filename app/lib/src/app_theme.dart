import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

abstract class AppTheme extends ChangeNotifier {
  final BuildContext context;

  AppTheme(this.context);

  factory AppTheme.of(BuildContext context) {
    return isMaterial(context)
      ? MaterialAppTheme(context)
      : CupertinoAppTheme(context);
  }

  Color get favoriteColor => Colors.red[500]!;

  bool get isDark;

  Color get errorColor;
  Color get successColor;
  Color get dangerColor;
  Color get disabledColor;
  Color get selectedRowColor;
  Color get selectedRowContrastColor;
  Color get selectedIconColor;

  ColorScheme get colorScheme;

  TextStyle get titleStyle;
  TextStyle get labelStyle;
  TextStyle get sublabelStyle;

  TextStyle get linkStyle => const TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline
  );

  TextStyle get quoteStyle => TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: titleStyle.fontSize! - 3,
  );

  TextStyle get letterStyle => TextStyle(
    color: colorScheme.onSurface,
    fontWeight: FontWeight.normal,
    fontSize: labelStyle.fontSize! + 3,
  );

  TextStyle get selectedLetterStyle => TextStyle(
    color: colorScheme.background,
    fontWeight: FontWeight.bold,
    fontSize: labelStyle.fontSize! + 3,
  );

  TextStyle get authorStyle => TextStyle(
    color: isDark ? Colors.blue[300] : Colors.blue[600],
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    fontSize: labelStyle.fontSize!,
  );

  SystemUiOverlayStyle get overlayStyle;
}

class MaterialAppTheme extends AppTheme {
  final ThemeData theme;

  static Color get appColor => Colors.black;

  static ThemeData appTheme() {
    return _adjustTheme(FlexColorScheme.light(
      scheme: FlexScheme.bigStone,
      appBarStyle: FlexAppBarStyle.primary,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).toTheme);
  }

  static ThemeData darkAppTheme() {
    return _adjustTheme(FlexColorScheme.dark(
      scheme: FlexScheme.bigStone,
      appBarStyle: FlexAppBarStyle.primary,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).toTheme);
  }

  static ThemeData _adjustTheme(ThemeData theme) {
    return theme.copyWith(
      dialogTheme: theme.dialogTheme.copyWith(
        backgroundColor: theme.colorScheme.background.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 0,
      )
    );
  }

  MaterialAppTheme(BuildContext context)
    : theme = Theme.of(context)
    , super(context);

  @override
  bool get isDark => theme.brightness == Brightness.dark;

  @override
  Color get errorColor => theme.errorColor;
  @override
  Color get successColor => Colors.green[500]!;
  @override
  Color get dangerColor => Colors.red[500]!;
  @override
  Color get disabledColor => theme.disabledColor;
  @override
  Color get selectedRowColor => theme.colorScheme.secondary;
  @override
  Color get selectedRowContrastColor => theme.colorScheme.onSecondary;
  @override
  Color get selectedIconColor => Colors.green[800]!;

  @override
  ColorScheme get colorScheme => theme.colorScheme;

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
  late CupertinoThemeData theme;
  late ThemeData td;

  static Color get appColor => Colors.black;

  static CupertinoThemeData appTheme() {
    final dark = Brightness.dark == SchedulerBinding.instance.window.platformBrightness;
    final theme = _getTheme(dark);

    return CupertinoThemeData(
      //primaryColor: theme.primaryColor,
      brightness: theme.brightness,
      scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
      barBackgroundColor: theme.backgroundColor
    );
  }

  static ThemeData _getTheme(bool dark) {
    if (dark) {
      return FlexColorScheme.dark(
        scheme: FlexScheme.bigStone,
        appBarStyle: FlexAppBarStyle.primary,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
      ).toTheme;
    }

    return FlexColorScheme.light(
      scheme: FlexScheme.bigStone,
      appBarStyle: FlexAppBarStyle.primary,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    ).toTheme;
  }

  CupertinoAppTheme(BuildContext context)
    : theme = CupertinoTheme.of(context)
    , super(context) {
      td = _getTheme(isDark);
    }

  @override
  bool get isDark => theme.brightness == Brightness.dark;

  @override
  Color get errorColor => td.errorColor;
  @override
  Color get successColor => Colors.green[300]!;
  @override
  Color get dangerColor => Colors.red[500]!;
  @override
  Color get disabledColor => td.disabledColor;
  @override
  Color get selectedRowColor => td.colorScheme.secondary;
  @override
  Color get selectedRowContrastColor => td.colorScheme.onSecondary;
  @override
  Color get selectedIconColor => Colors.green[800]!;

  @override
  ColorScheme get colorScheme => td.colorScheme;

  @override
  TextStyle get titleStyle => theme.textTheme.navLargeTitleTextStyle.copyWith(fontSize: theme.textTheme.navLargeTitleTextStyle.fontSize! - 8);
  @override
  TextStyle get labelStyle => theme.textTheme.navTitleTextStyle.copyWith(fontSize: theme.textTheme.navTitleTextStyle.fontSize! - 3);
  @override
  TextStyle get sublabelStyle => theme.textTheme.textStyle.copyWith(fontSize: theme.textTheme.textStyle.fontSize! - 5);

  @override
  SystemUiOverlayStyle get overlayStyle => isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
}