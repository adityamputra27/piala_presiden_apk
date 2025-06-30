// local_notif_db.dart
import 'dart:async';
import 'package:piala_presiden_apk/models/local_notification.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalNotificationDb {
  static final LocalNotificationDb _instance = LocalNotificationDb._internal();
  factory LocalNotificationDb() => _instance;
  LocalNotificationDb._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final docsDir = await getApplicationDocumentsDirectory();
    String path = join(docsDir.path, "local_notif.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE notifications (
          id TEXT PRIMARY KEY,
          title TEXT,
          message TEXT,
          sent_at TEXT,
          type TEXT,
          is_read INTEGER DEFAULT 0
        )
      ''');
      },
    );
  }

  Future<void> insertOrIgnore(LocalNotification notif) async {
    final dbClient = await db;
    await dbClient.insert(
      'notifications',
      notif.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<LocalNotification>> getAllNotif() async {
    final dbClient = await db;
    final res = await dbClient.query('notifications', orderBy: 'sent_at DESC');
    return res.map((e) => LocalNotification.fromMap(e)).toList();
  }

  Future<int> getUnreadCount() async {
    final dbClient = await db;
    final res = await dbClient.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE is_read = 0',
    );
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<void> markAsRead(String id) async {
    final dbClient = await db;
    await dbClient.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllAsRead() async {
    final dbClient = await db;
    await dbClient.update('notifications', {
      'is_read': 1,
    }, where: 'is_read = 0');
  }

  Future<void> deleteNotif(String id) async {
    final dbClient = await db;
    await dbClient.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }
}
