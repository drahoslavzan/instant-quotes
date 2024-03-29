import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../components/tag_chip.dart';
import '../database/model/quote.dart';
import '../database/model/author.dart';
import '../database/model/tag.dart';
import '../app_theme.dart';
import '../app_icons.dart';
import 'base_quote_card.dart';
import 'display_card.dart';
import 'quote_actions.dart';
import 'quote_service.dart';

class QuoteCard extends StatelessWidget implements BaseQuoteCard {
  @override
  final Quote quote;

  QuoteCard({required this.quote}): super(key: ValueKey(quote.id));

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
          if (quote.tags.isNotEmpty) const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Divider(color: Colors.black)
          ),
          if (quote.tags.isNotEmpty) _Tags(tags: quote.tags)
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
    final theme = AppTheme.of(context);

    return Text(quote,
      textAlign: TextAlign.center,
      style: theme.quoteStyle,
    );
  }
}

class _Author extends StatelessWidget {
  final Author author;

  const _Author({Key? key, required this.author}):
    super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: PlatformTextButton(
        onPressed: () {
          if (author.selected) return;
          Navigator.pushNamed(context, QuoteService.routeAuthor, arguments: author);
        },
        child: Text('-- ${author.name}'.toUpperCase(),
          textAlign: TextAlign.end,
          style: theme.authorStyle,
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
    final theme = AppTheme.of(context);

    return Center(
      child: Wrap(
        spacing: 10,
        children: tags.map((t) => TagChip(
          background: t.selected ? theme.colorScheme.onSurface : theme.colorScheme.tertiary,
          color: t.selected ? theme.disabledColor : theme.colorScheme.onTertiary,
          name: t.name,
          onPressed: () {
            if (t.selected) return;
            Navigator.pushNamed(context, QuoteService.routeTag, arguments: t);
          }
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
    final theme = AppTheme.of(context);
    final icons = AppIcons.of(context);
    final size = theme.titleStyle.fontSize!;

    return AnimatedBuilder(
      animation: quote,
      builder: (context, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PlatformIconButton(
            icon: Icon(icons.copy, size: size),
            onPressed: () {
              final actions = Provider.of<QuoteActions>(context, listen: false);
              actions.copy2clipboard(context, quote);
            },
          ),
          SizedBox(width: size / 2),
          PlatformIconButton(
            icon: Icon(icons.share, size: size),
            onPressed: () {
              final actions = Provider.of<QuoteActions>(context, listen: false);
              actions.share(context, quote);
            },
          ),
          SizedBox(width: size / 2),
          PlatformIconButton(
            icon: Icon(icons.favorite,
              size: size,
              color: quote.favorite ? theme.favoriteColor : theme.noFavoriteColor
            ),
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