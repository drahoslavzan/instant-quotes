import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class Modal extends StatelessWidget {
  final String title;
  final Widget child;

  const Modal({Key? key, required this.title, required this.child}):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(title)),
      iosContentPadding: false,
      iosContentBottomPadding: false,
      body: child,
    );
  }
}