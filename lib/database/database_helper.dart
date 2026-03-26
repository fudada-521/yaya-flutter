import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/baby.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/growth_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'yaya_diary.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 婴儿档案表
    await db.execute('''
      CREATE TABLE babies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar TEXT,
        birthDate TEXT NOT NULL,
        gender TEXT NOT NULL,
        birthWeight REAL,
        birthHeight REAL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // 喂养记录表
    await db.execute('''
      CREATE TABLE feeding_records (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        feedTime TEXT NOT NULL,
        amount REAL,
        type TEXT NOT NULL,
        method TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');

    // 睡眠记录表
    await db.execute('''
      CREATE TABLE sleep_records (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        quality INTEGER,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');

    // 换尿布记录表
    await db.execute('''
      CREATE TABLE diaper_records (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        changeTime TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');

    // 成长记录表
    await db.execute('''
      CREATE TABLE growth_records (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        recordDate TEXT NOT NULL,
        height REAL,
        weight REAL,
        headCircumference REAL,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');
  }

  // Baby operations
  Future<List<Baby>> getBabies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('babies');
    return List.generate(maps.length, (i) => Baby.fromMap(maps[i]));
  }

  Future<void> insertBaby(Baby baby) async {
    final db = await database;
    await db.insert('babies', baby.toMap());
  }

  Future<void> updateBaby(Baby baby) async {
    final db = await database;
    await db.update(
      'babies',
      baby.toMap(),
      where: 'id = ?',
      whereArgs: [baby.id],
    );
  }

  Future<void> deleteBaby(String babyId) async {
    final db = await database;
    await db.delete(
      'babies',
      where: 'id = ?',
      whereArgs: [babyId],
    );
  }

  // Feeding record operations
  Future<List<FeedingRecord>> getFeedingRecords([String? babyId]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = babyId == null
        ? await db.query('feeding_records', orderBy: 'feedTime DESC')
        : await db.query(
            'feeding_records',
            where: 'babyId = ?',
            whereArgs: [babyId],
            orderBy: 'feedTime DESC',
          );
    return List.generate(maps.length, (i) => FeedingRecord.fromMap(maps[i]));
  }

  Future<void> insertFeedingRecord(FeedingRecord record) async {
    final db = await database;
    await db.insert('feeding_records', record.toMap());
  }

  Future<void> updateFeedingRecord(FeedingRecord record) async {
    final db = await database;
    await db.update(
      'feeding_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteFeedingRecord(String recordId) async {
    final db = await database;
    await db.delete(
      'feeding_records',
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  // Sleep record operations
  Future<List<SleepRecord>> getSleepRecords([String? babyId]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = babyId == null
        ? await db.query('sleep_records', orderBy: 'startTime DESC')
        : await db.query(
            'sleep_records',
            where: 'babyId = ?',
            whereArgs: [babyId],
            orderBy: 'startTime DESC',
          );
    return List.generate(maps.length, (i) => SleepRecord.fromMap(maps[i]));
  }

  Future<void> insertSleepRecord(SleepRecord record) async {
    final db = await database;
    await db.insert('sleep_records', record.toMap());
  }

  Future<void> updateSleepRecord(SleepRecord record) async {
    final db = await database;
    await db.update(
      'sleep_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteSleepRecord(String recordId) async {
    final db = await database;
    await db.delete(
      'sleep_records',
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  // Diaper record operations
  Future<List<DiaperRecord>> getDiaperRecords([String? babyId]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = babyId == null
        ? await db.query('diaper_records', orderBy: 'changeTime DESC')
        : await db.query(
            'diaper_records',
            where: 'babyId = ?',
            whereArgs: [babyId],
            orderBy: 'changeTime DESC',
          );
    return List.generate(maps.length, (i) => DiaperRecord.fromMap(maps[i]));
  }

  Future<void> insertDiaperRecord(DiaperRecord record) async {
    final db = await database;
    await db.insert('diaper_records', record.toMap());
  }

  Future<void> updateDiaperRecord(DiaperRecord record) async {
    final db = await database;
    await db.update(
      'diaper_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteDiaperRecord(String recordId) async {
    final db = await database;
    await db.delete(
      'diaper_records',
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  // Growth record operations
  Future<List<GrowthRecord>> getGrowthRecords([String? babyId]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = babyId == null
        ? await db.query('growth_records', orderBy: 'recordDate DESC')
        : await db.query(
            'growth_records',
            where: 'babyId = ?',
            whereArgs: [babyId],
            orderBy: 'recordDate DESC',
          );
    return List.generate(maps.length, (i) => GrowthRecord.fromMap(maps[i]));
  }

  Future<void> insertGrowthRecord(GrowthRecord record) async {
    final db = await database;
    await db.insert('growth_records', record.toMap());
  }

  Future<void> updateGrowthRecord(GrowthRecord record) async {
    final db = await database;
    await db.update(
      'growth_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteGrowthRecord(String recordId) async {
    final db = await database;
    await db.delete(
      'growth_records',
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }
}