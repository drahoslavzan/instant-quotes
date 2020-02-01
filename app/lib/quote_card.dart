import 'package:flutter/material.dart';
import 'package:myapp/database/model/quote.dart';

class QuoteCard extends StatelessWidget {
  QuoteCard(this._quote);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Quote(_quote.quote),
                _Author(_quote.author),
              ]
            )
          )
        )
      )
    );
  }

  final Quote _quote;
}

class _Quote extends StatelessWidget {
  _Quote(this._quote);

  @override
  Widget build(BuildContext context) {
    return Text('„$_quote”',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 30
      )
    );
  }

  final String _quote;
}

class _Author extends StatelessWidget {
  _Author(this._author);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30.0),
      child: Text('-- $_author',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 20
        )
      )
    );
  }

  final String _author;
}
