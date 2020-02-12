import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
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
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: ChangeNotifierProvider.value(
          value: _quote,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Quote(_quote.quote),
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: _Author(_quote.author),
              ),
              _Actions(),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Divider(color: Colors.black)
              ),
              _Tags(_quote.tags)
            ]
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
        fontSize: 25
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
            textAlign: TextAlign.end,
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

class _Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Quote>(
      builder: (context, quote, child) =>
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                _shareText(quote);
              },
            ),
            SizedBox(width: 15),
            IconButton(
              icon: Icon(Icons.favorite),
              color: quote.favorite ? Colors.red : Colors.black,
              onPressed: () async {
                final repo = Provider.of<QuoteProvider>(context, listen: false).quoteRepository;
                final nfav = !quote.favorite;
                await repo.markFavorite(quote, nfav);
                quote.favorite = nfav;
              },
            ),
          ]
        )
    );
  }

  void _shareText(Quote quote) {
    Share.text('Quote', '${quote.quote}\n\n    --${quote.author.name}', 'text/plain');
  }
}