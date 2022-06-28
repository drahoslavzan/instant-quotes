import 'dart:async';
import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';

class DatabaseConnector {
  factory DatabaseConnector() => _instance;

  Database get db {
    assert(_db != null);
    return _db!;
  }

  bool get isOpened => _db != null;

  Future<void> open(String path) async {
    if (_db != null) return;
    _db = await openDatabase(path,
      version: 1,
      onConfigure: _onConfigure,
      onOpen: _onInstall
    );
  }

  DatabaseConnector._internal();

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onInstall(Database db) async {
    const last = 'idx_quote_tags_tag';
    final data = await db.rawQuery("PRAGMA INDEX_INFO('$last');");
    if (data.isNotEmpty) {
      developer.log('=== DB ALREADY INSTALLED ===');
      return;
    }

    developer.log('=== INSTALL DB ===');

    final batch = db.batch();
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_authors_known ON authors (known ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_authors_profession ON authors (profession ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_quotes_author ON quotes (author_id ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_quotes_seen ON quotes (seen ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_quotes_favorite ON quotes (favorite ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_quote_tags_quote ON quote_tags (quote_id ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS $last ON quote_tags (tag_id ASC);');

    await batch.commit(noResult: true);

    developer.log('=== DB INSTALLED ===');
  }

  static Database? _db;
  static final _instance = DatabaseConnector._internal();
}