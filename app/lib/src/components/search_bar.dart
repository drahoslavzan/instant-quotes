import 'package:flutter/material.dart';

typedef SearchCallback = void Function(String);

class SearchBar extends StatefulWidget {
  final SearchCallback onSearch;
  final String searchValue;
  final bool requestFocus;
  final VoidCallback? onSearchDone;
  final int? records;

  const SearchBar({
    Key? key,
    required this.onSearch,
    required this.searchValue,
    this.onSearchDone,
    this.records,
    this.requestFocus = false
  }): super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  void initState() {
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.onSearchDone != null) {
        widget.onSearchDone?.call();
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies () {
    if (widget.requestFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        focusNode: _focusNode,
        onChanged: widget.onSearch,
        initialValue: widget.searchValue,
        decoration: InputDecoration(
          labelText: 'Search',
          hintText: widget.records == null ? null : '${widget.records} records',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)))
          ),
      ),
    );
  }

  final FocusNode _focusNode = FocusNode();
}
