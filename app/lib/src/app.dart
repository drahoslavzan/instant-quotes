import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'components/modal.dart';
import 'database/database_connector.dart';
import 'database/quote_repository.dart';
import 'database/author_repository.dart';
import 'database/model/author.dart';
import 'database/model/tag.dart';
import 'quote/quote_actions.dart';
import 'quote/quotes_view.dart';
import 'quote/quote_service.dart';
import 'quote/quote_card.dart';
import 'quote/quote_changed_notifier.dart';
import 'quote/quote_list_loader.dart';
import 'home_screen.dart';
import 'themed_app.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DatabaseConnector>(
      future: _openDB(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const PreparingDBMessage();
        return MultiProvider(
          providers: [
            Provider<QuoteRepository>(
              lazy: false,
              create: (_) => QuoteRepository(connector: snapshot.data!)
            ),
            Provider<AuthorRepository>(
              lazy: false,
              create: (_) => AuthorRepository(connector: snapshot.data!)
            ),
            Provider<QuoteActions>(
              lazy: false,
              create: (_) => QuoteActionsImpl(),
            ),
            ChangeNotifierProvider<QuoteChangedNotifier>(
              lazy: false,
              create: (_) => QuoteChangedNotifier(),
            ),
            ProxyProvider<QuoteRepository, QuoteService>(
              lazy: false,
              update: (_, repo, __) => QuoteService(repo)
            ),
          ],
          builder: (context, _) {
            return ThemedApp(
              routeBuilder: (context, route) {
                final qs = Provider.of<QuoteService>(context, listen: false);
                switch (route) {
                case QuoteService.routeAuthor:
                  final author = ModalRoute.of(context)!.settings.arguments as Author;
                  return Modal(
                    title: author.name,
                    child: QuotesView(
                      loaderFactory: ({pattern}) => QuoteListLoaderImpl(
                        fetch: qs.author(author: author, pattern: pattern).fetch,
                        seen: qs.seen
                      ),
                      quoteFactory: ({ required loader, required quote }) => QuoteCard(quote: quote),
                    )
                  );
                case QuoteService.routeTag:
                  final tag = ModalRoute.of(context)!.settings.arguments as Tag;
                  return Modal(
                    title: tag.name,
                    child: QuotesView(
                      loaderFactory: ({pattern}) => QuoteListLoaderImpl(
                        fetch: qs.tag(tag: tag, pattern: pattern).fetch,
                        seen: qs.seen
                      ),
                      quoteFactory: ({ required loader, required quote }) => QuoteCard(quote: quote),
                    )
                  );
                default:
                  return const HomeScreen();
                }
              }
            );
          }
        );
      }
    );
  }
}

class PreparingDBMessage extends StatelessWidget {
  const PreparingDBMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemedApp(
      routeBuilder: (context, _) {
        return PlatformScaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlatformCircularProgressIndicator(),
                const SizedBox(height: 15),
                PlatformText(AppLocalizations.of(context)!.loadingDb,
                  textAlign: TextAlign.center
                )
              ]
            )
          )
        );
      }
    );
  }
}

Future<DatabaseConnector> _openDB() async {
  const dbName = 'quotes.db';
  final conn = DatabaseConnector();
  if (conn.isOpened) return conn;

  final appDir = await getApplicationSupportDirectory();
  final dbPath = join(appDir.path, dbName);

  try {
    final ft = await FileSystemEntity.type(dbPath);
    if (ft == FileSystemEntityType.file) {
      developer.log('=== OPEN DB ===');
      return conn;
    }

    // NOTE: migrate the db
    if (Platform.isAndroid) {
      final docDir = await getApplicationDocumentsDirectory();
      final path = join(docDir.path, "database.db");
      final ft = await FileSystemEntity.type(path);
      if (ft == FileSystemEntityType.file) {
        developer.log('=== MIGRATE DB ===');
        conn.migrateVer = 0;
        await File(path).copy(dbPath);
        return conn;
      }
    }

    developer.log('=== CREATE DB ===');

    // NOTE: copy from assets
    var data = await rootBundle.load(join('assets', dbName));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes, flush: true);
  } finally {
    await conn.open(dbPath);
  }

  return conn;
}
