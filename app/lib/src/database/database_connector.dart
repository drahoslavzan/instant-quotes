import 'dart:async';
import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';

class DatabaseConnector {
  var migrateVer = 1;

  bool get isOpened => _db != null;

  factory DatabaseConnector() => _instance;

  Database get db {
    assert(_db != null);
    return _db!;
  }

  Future<void> open(String path) async {
    if (_db != null) return;
    _db = await openDatabase(path,
      version: 1,
      onConfigure: _configureDatabase,
      onOpen: _createIndexes
    );
  }

  Future<void> _configureDatabase(Database db) async {
    final batch = db.batch();

    batch.rawQuery('PRAGMA foreign_keys = ON');
    batch.rawQuery('PRAGMA case_sensitive_like = OFF');

    await batch.commit(noResult: true);
  }

  Future<void> _createIndexes(Database db) async {
    const last = 'idx_quotes_seen_id';
    final data = await db.rawQuery("PRAGMA INDEX_INFO('$last')");
    if (data.isNotEmpty) {
      developer.log('=== DB ALREADY INSTALLED ===');
      return;
    }

    await _removeAllIndexes(db);

    developer.log('=== INSTALL DB (ver. $migrateVer) ===');

    final batch = db.batch();

    if (migrateVer > 0) {
      batch.rawQuery('ALTER TABLE quotes ADD seen INTEGER DEFAULT 0');
      batch.rawQuery('ALTER TABLE quotes ADD favorite INTEGER DEFAULT 0');

      // NOTE: tables are without ROWID
      batch.rawQuery('CREATE UNIQUE INDEX idx_authors_id ON authors (id ASC)');
      batch.rawQuery('CREATE UNIQUE INDEX idx_quotes_id ON quotes (id ASC)');
      batch.rawQuery('CREATE UNIQUE INDEX idx_tags_id ON tags (id ASC)');
    }

    batch.rawQuery('ALTER TABLE quotes ADD shuffle_idx INTEGER');
    batch.rawQuery('UPDATE quotes SET shuffle_idx = random()');

    batch.rawQuery('CREATE INDEX idx_authors_name ON authors (name COLLATE NOCASE)');
    batch.rawQuery('CREATE INDEX idx_authors_profession ON authors (profession COLLATE NOCASE)');
    batch.rawQuery('CREATE UNIQUE INDEX idx_tags_name ON tags (name COLLATE NOCASE)');
    batch.rawQuery('CREATE INDEX idx_quote_tags_quote_id ON quote_tags (quote_id ASC)');
    batch.rawQuery('CREATE INDEX idx_quote_tags_tag_id ON quote_tags (tag_id ASC)');
    batch.rawQuery('CREATE INDEX idx_quotes_author_id ON quotes (author_id ASC)');
    batch.rawQuery('CREATE INDEX idx_quotes_seen ON quotes (seen ASC)');
    batch.rawQuery('CREATE INDEX idx_quotes_favorite ON quotes (favorite ASC)');
    batch.rawQuery('CREATE UNIQUE INDEX idx_quotes_shuffle_idx ON quotes (shuffle_idx ASC)');
    batch.rawQuery('CREATE UNIQUE INDEX idx_quotes_seen_shuffle_idx ON quotes (seen, shuffle_idx ASC)');
    batch.rawQuery('CREATE UNIQUE INDEX $last ON quotes (seen, id ASC)');

    await batch.commit(noResult: true);

    developer.log('=== DB INSTALLED ===');
  }

  Future<void> _removeAllIndexes(Database db) async {
    developer.log('=== REMOVE INDEXES ===');

    const query = '''
      SELECT name
        FROM sqlite_master
        WHERE type == 'index' AND name NOT LIKE 'sqlite_%'
    ''';

    final idxs = await db.rawQuery(query);
    final batch = db.batch();
    for (var idx in idxs) {
      batch.rawQuery('DROP INDEX ${idx['name']}');
    }

    await batch.commit(noResult: true);
  }

  DatabaseConnector._internal();

  static Database? _db;
  static final _instance = DatabaseConnector._internal();
}
