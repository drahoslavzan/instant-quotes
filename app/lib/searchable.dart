import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Searchable extends StatelessWidget {
  final String title;
  final Widget child;
  final Function onSearch;
  final String searchValue;
  final int records;

  Searchable({@required this.title, @required this.child, @required this.onSearch, @required this.searchValue, this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            onChanged: onSearch,
            initialValue: searchValue,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: records == null ? null : '$records records',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)))
              ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: child
        )
      ]
    );
  }
}
