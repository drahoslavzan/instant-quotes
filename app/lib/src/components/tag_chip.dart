import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final VoidCallback onPressed;
  final String name;

  const TagChip({Key? key, required this.name, required this.onPressed}):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('# $name'),
      onPressed: onPressed
    );
  }
}