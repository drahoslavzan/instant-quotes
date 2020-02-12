import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Searchable extends StatefulWidget {
  final String title;
  final Widget child;
  final Function onSearch;
  final Function onSearchDone;
  final String searchValue;
  final int records;
  final bool requestFocus;

  Searchable({@required this.child, @required this.onSearch, @required this.searchValue, this.records, this.onSearchDone, this.title = '', this.requestFocus = false});

  @override
  _SearchableState createState() => _SearchableState();
}

class _SearchableState extends State<Searchable> {
  @override
  void initState() {
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.onSearchDone != null) {
        widget.onSearchDone();
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
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            focusNode: _focusNode,
            onChanged: widget.onSearch,
            initialValue: widget.searchValue,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: widget.records == null ? null : '${widget.records} records',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)))
              ),
          ),
        ),
        if (widget.title.isNotEmpty) Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: widget.child
        )
      ]
    );
  }

  final FocusNode _focusNode = FocusNode();
}
