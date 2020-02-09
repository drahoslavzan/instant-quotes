import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/quote_repository.dart';
import 'database/model/quote.dart';
import 'database/model/author.dart';
import 'database/model/tag.dart';
import 'quote_provider.dart';
import 'quotes_view.dart';

class QuoteCard extends StatelessWidget {
  QuoteCard(this._quote);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20.0),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Quote(_quote.quote),
            _Author(_quote.author),
            _Tags(_quote.tags)
          ]
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
      child: Align(
        alignment: Alignment.centerRight,
        child: FlatButton(
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => 
                QuotesView(quoteProvider: QuoteProvider.fromAuthor(quoteRepository: Provider.of<QuoteRepository>(context), author: _author))
              ),
            );
          },
          child: Text('-- ${_author.name}',
            style: TextStyle(
              color: Colors.deepPurple,
              fontStyle: FontStyle.italic,
              fontSize: 20
            )
          )
        )
      )
    );
  }

  final Author _author;
}

class _Tags extends StatelessWidget {
  _Tags(this._tags);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Center(
        child: Wrap(
          spacing: 10,
          children: _tags.map((t) =>
            ActionChip(
              label: Text(t.name),
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => 
                    QuotesView(quoteProvider: QuoteProvider.fromTag(quoteRepository: Provider.of<QuoteRepository>(context), tag: t))
                  ),
                );
              },
            )).toList()
        )
      )
    );
  }

  final List<Tag> _tags;
}