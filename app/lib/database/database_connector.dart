import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseConnector {
  factory DatabaseConnector() => _instance;

  Database get db => _db;

  Future<void> initDb() async {
    if (_db != null) return;

    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, _dbName);
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      var data = await rootBundle.load(join('assets', _dbName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(path, version: 1, onConfigure: _onConfigure, onOpen: _onInstall);
  }

  DatabaseConnector._internal();

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onInstall(Database db) async {
    const last = 'idx_quote_tags_tag';
    final data = await db.rawQuery("PRAGMA INDEX_INFO('$last');");

    if (data.isNotEmpty) return;

    print('=== INSTALL ===');

    var batch = db.batch();

    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_authors_known ON authors (known ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_authors_profession ON authors (profession ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_quotes_author ON quotes (author_id ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_quotes_seen ON quotes (seen ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_quotes_favorite ON quotes (favorite ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS idx_quote_tags_quote ON quote_tags (quote_id ASC);');
    batch.rawQuery('CREATE INDEX IF NOT EXISTS $last ON quote_tags (tag_id ASC);');

    await batch.commit(noResult: true);
  }

  static Database _db;
  static const _dbName = 'database.db';
  static final _instance = DatabaseConnector._internal();
}