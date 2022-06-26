import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/tag_chip.dart';
import '../database/model/quote.dart';
import '../database/model/author.dart';
import '../database/model/tag.dart';
import 'base_quote_card.dart';
import 'display_card.dart';
import 'quote_actions.dart';
import 'quote_service.dart';

class QuoteCard extends StatelessWidget implements BaseQuoteCard {
  @override
  final Quote quote;

  const QuoteCard({Key? key, required this.quote}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return DisplayCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Quote(quote: quote.quote),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: _Author(author: quote.author),
          ),
          _Actions(quote: quote),
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Divider(color: Colors.black)
          ),
          _Tags(tags: quote.tags)
        ]
      )
    );
  }
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
        onPressed: () => Navigator.pushNamed(context, QuoteService.routeAuthor, arguments: author),
        child: Text('-- ${author.name}',
          textAlign: TextAlign.end,
          style: const TextStyle(
            color: Colors.blueAccent,
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
          onPressed: () => Navigator.pushNamed(context, QuoteService.routeTag, arguments: t)
        )).toList()
      )
    );
  }
}

class _Actions extends StatelessWidget {
  final Quote quote;

  const _Actions({required this.quote});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: quote,
      builder: (context, _) => Row(
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