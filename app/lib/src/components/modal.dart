import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class Modal extends StatelessWidget {
  final Widget title;
  final Widget child;
  final List<Widget>? actions;

  const Modal({
    Key? key,
    this.actions,
    required this.title,
    required this.child
  }):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(title: title, trailingActions: actions),
      iosContentPadding: false,
      iosContentBottomPadding: false,
      body: child,
    );
  }
}