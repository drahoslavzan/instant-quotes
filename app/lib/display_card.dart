import 'package:flutter/material.dart';

class DisplayCard extends StatelessWidget {
  DisplayCard({this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: child
      )
    );
  }

  final Widget child;
}