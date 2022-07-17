import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import "database_connector.dart";

Future<DatabaseConnector> openExistingDb() async {
  final conn = DatabaseConnector();
  if (conn.isOpened) return conn;

  final dbPath = await _getDbPath();
  await conn.open(dbPath);
  return conn;
}

Future<DatabaseConnector> setupDb() async {
  final conn = DatabaseConnector();
  if (conn.isOpened) return conn;

  final dbPath = await _getDbPath();

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
    var data = await rootBundle.load(join('assets', _dbName));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(dbPath).writeAsBytes(bytes, flush: true);
  } finally {
    await conn.open(dbPath);
  }

  return conn;
}

Future<String> _getDbPath() async {
  final appDir = await getApplicationSupportDirectory();
  return join(appDir.path, _dbName);
}

const _dbName = 'quotes.db';