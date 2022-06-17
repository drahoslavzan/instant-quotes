import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final VoidCallback onPressed;
  final String name;

  const TagChip({Key? key, required this.name, required this.onPressed}):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Text('#', style: TextStyle(fontSize: 20)),
      label: Text(name),
      onPressed: onPressed
    );
  }
}