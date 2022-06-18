import 'package:flutter/material.dart';

class DisplayCard extends StatelessWidget {
  const DisplayCard({Key? key, required this.child}):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: child,
      )
    );
  }

  final Widget child;
}