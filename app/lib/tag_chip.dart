import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final Function onPressed;
  final String name;

  TagChip({this.name, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Text('#', style: TextStyle(fontSize: 20)),
      label: Text(name),
      onPressed: this.onPressed
    );
  }
}