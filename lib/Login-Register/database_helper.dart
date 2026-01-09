import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {

    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'moods.db');



    bool dbExists = await databaseExists(path);


    if (!dbExists) {
      try {

        await Directory(dirname(path)).create(recursive: true);

        ByteData data = await rootBundle.load(join('database', 'moods.db'));
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        await File(path).writeAsBytes(bytes, flush: true);
        print("Veritabanı assets'ten başarıyla kopyalandı.");
      } catch (e) {
        print("Veritabanı kopyalanırken hata oluştu: $e");
      }
    }

    return await openDatabase(
      path,
      version: 2,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }


  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }


  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _updateTablesToV2(db);
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT,
        emoji TEXT,
        mood TEXT,
        note TEXT,
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      );
    ''');
  }

  Future<void> _updateTablesToV2(Database db) async {
    try {
      await db.execute(
        'ALTER TABLE moods ADD COLUMN userId INTEGER REFERENCES users(id) ON DELETE CASCADE',
      );
      print("userId sütunu 'moods' tablosuna başarıyla eklendi.");
    } catch (e) {

      print("Bilgi: userId sütunu zaten mevcut veya bir hata oluştu: $e");
    }
  }

  // --- KULLANICI İŞLEMLERİ ---

  Future<int> registerUser(String name, String email, String password) async {
    final db = await database;
    try {
      return await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
      }, conflictAlgorithm: ConflictAlgorithm.fail);
    } catch (e) {
      print("Kayıt hatası: $e");
      return -1;
    }
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // --- RUH HALİ İŞLEMLERİ ---

  Future<void> insertMood(Map<String, dynamic> moodData, int userId) async {
    final db = await database;
    // Gelen veri haritasına `userId`'yi de ekle
    final dataToInsert = Map<String, dynamic>.from(moodData);
    dataToInsert['userId'] = userId;
    await db.insert(
      'moods',
      dataToInsert,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMoodsForUser(int userId) async {
    final db = await database;
    return await db.query(
      'moods',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: "dateTime DESC",
    );
  }
}
