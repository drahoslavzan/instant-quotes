import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/model/quote.dart';
import '../database/model/author.dart';
import '../database/model/tag.dart';
import 'tag_chip.dart';
import 'display_card.dart';
import 'quote_actions.dart';
import 'quote_service.dart';
import 'quotes_view.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({Key? key, required Quote quote}):
    _quote = quote, super(key: key);

  @override
  Widget build(BuildContext context) {
    return DisplayCard(
      child: ChangeNotifierProvider.value(
        value: _quote,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Quote(quote: _quote.quote),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: _Author(author: _quote.author),
            ),
            const _Actions(),
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Divider(color: Colors.black)
            ),
            _Tags(tags: _quote.tags)
          ]
        )
      )
    );
  }

  final Quote _quote;
}

class _Quote extends StatelessWidget {
  final String quote;

  const _Quote({Key? key, required this.quote}):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(quote,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 25
      )
    );
  }
}

class _Author extends StatelessWidget {
  final Author author;

  const _Author({Key? key, required this.author}):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => 
              QuotesView(fetch: Provider.of<QuoteService>(context, listen: false).author(author: author))
            ),
          );
        },
        child: Text('-- ${author.name}',
          textAlign: TextAlign.end,
          style: const TextStyle(
            color: Colors.deepPurple,
            fontStyle: FontStyle.italic,
            fontSize: 20
          )
        )
      )
    );
  }
}

class _Tags extends StatelessWidget {
  final List<Tag> tags;

  const _Tags({Key? key, required this.tags}):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 10,
        children: tags.map((t) => TagChip(
          name: t.name,
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => 
                QuotesView(fetch: Provider.of<QuoteService>(context, listen: false).tag(tag: t))
              ),
            );
          },
        )).toList()
      )
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return Consumer<Quote>(
      builder: (context, quote, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final actions = Provider.of<QuoteActions>(context, listen: false);
              actions.share(context, quote);
            },
          ),
          const SizedBox(width: 15),
          IconButton(
            icon: const Icon(Icons.favorite),
            color: quote.favorite ? Colors.red : Colors.black,
            onPressed: () {
              final actions = Provider.of<QuoteActions>(context, listen: false);
              actions.toggleFavorite(context, quote);
            },
          ),
        ]
      )
    );
  }
}