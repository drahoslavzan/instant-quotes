import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

abstract class AppIcons {
  final BuildContext context;
  final PlatformIcons _pic;

  AppIcons(this.context) : _pic = PlatformIcons(context);

  factory AppIcons.of(BuildContext context) => isMaterial(context)
    ? _MaterialAppIcons(context)
    : _CupertinoAppIcons(context);

  IconData get share => _pic.shareSolid;
  IconData get favorite => _pic.favoriteSolid;
  IconData get copy => Icons.content_copy;
  IconData get forwoard => _pic.rightChevron;

  IconData get quote => _pic.bookmarkSolid;
  IconData get author => _pic.personSolid;
}

class _MaterialAppIcons extends AppIcons {
  _MaterialAppIcons(BuildContext context) : super(context);
}

class _CupertinoAppIcons extends AppIcons {
  _CupertinoAppIcons(BuildContext context) : super(context);
}