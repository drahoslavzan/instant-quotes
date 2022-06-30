import 'package:flutter/material.dart';

import '../app_theme.dart';

class TagChip extends StatelessWidget {
  final VoidCallback onPressed;
  final String name;

  const TagChip({Key? key, required this.name, required this.onPressed}):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return ActionChip(
      backgroundColor: theme.colorScheme.tertiary,
      label: Text('# $name',
        style: theme.sublabelStyle.copyWith(color: theme.colorScheme.onTertiary)
      ),
      onPressed: onPressed
    );
  }
}