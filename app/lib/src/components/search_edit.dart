import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../app_theme.dart';

class SearchEdit extends StatefulWidget {
  final void Function(String) onSearch;
  final String hint;
  final double padding;
  final bool focus;

  const SearchEdit({
    Key? key,
    required this.onSearch,
    required this.hint,
    this.padding = 0,
    this.focus = false
  }) : super(key: key);

  @override
  State<SearchEdit> createState() => _SearchEditState();
}

class _SearchEditState extends State<SearchEdit> {
  final _controller = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focus) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      color: theme.colorScheme.primaryContainer,
      child: PlatformWidget(
        cupertino: (_, __) => CupertinoSearchTextField(
          focusNode: _focusNode,
          padding: const EdgeInsets.all(10),
          onChanged: widget.onSearch,
          controller: _controller,
          placeholder: widget.hint,
        ),
        material: (_, __) => Padding(
          padding: EdgeInsets.all(widget.padding),
          child: TextField(
            focusNode: _focusNode,
            onChanged: widget.onSearch,
            controller: _controller,
            decoration: InputDecoration(
              fillColor: theme.colorScheme.background,
              contentPadding: const EdgeInsets.all(10),
              hintText: widget.hint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    padding: const EdgeInsets.only(right: 15),
                    icon: Icon(Icons.clear, color: theme.dangerColor),
                    onPressed: () => _clear(context)
                  ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))
              )
            )
          )
        )
      )
    );
  }

  void _clear(BuildContext context) {
    _controller.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
    widget.onSearch('');
  }

  final _focusNode = FocusNode();
}
