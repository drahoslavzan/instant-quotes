import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseConnector {
  Future<Database> get db async {
    if (_db == null) await initDb();
    return _db;
  }

  factory DatabaseConnector() => _instance;

  DatabaseConnector._internal();

  Future<void> initDb() async {
    if (_db != null) return;

    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, _dbName);
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      var data = await rootBundle.load(join('assets', _dbName));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    _db = await openDatabase(path, version: 1, onConfigure: _onConfigure);
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  static Database _db;
  static const _dbName = 'database.db';
  static final _instance = DatabaseConnector._internal();
}