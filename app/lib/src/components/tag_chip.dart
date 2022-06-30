import 'package:flutter/material.dart';

import '../app_theme.dart';

class TagChip extends StatelessWidget {
  final VoidCallback onPressed;
  final String name;
  final Color color;
  final Color background;

  const TagChip({
    Key? key,
    required this.onPressed,
    required this.name,
    required this.color,
    required this.background
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return ActionChip(
      backgroundColor: background,
      label: Text('# $name',
        style: theme.sublabelStyle.copyWith(color: color)
      ),
      onPressed: onPressed
    );
  }
}