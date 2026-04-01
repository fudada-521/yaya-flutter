import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/baby.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/growth_record.dart';
import '../models/solid_food_record.dart';
import '../models/vaccine_record.dart';

/// 数据库管理单例类
///
/// 负责管理 SQLite 数据库的初始化和所有表的 CRUD 操作。
/// 使用单例模式确保全局只有一个数据库实例。
///
/// 数据库版本管理：
/// - v1: 初始版本
/// - v2: 添加 feeding_records 表的 duration 列
/// - v3: 添加左右侧时长列 left_duration, right_duration, mixed_duration
/// - v4: 添加 solid_food_records 表（辅食独立记录）
/// - v5: 添加 vaccine_records 表（疫苗接种记录）
///
/// 支持的表：babies、feeding_records、sleep_records、diaper_records、growth_records、solid_food_records、vaccine_records
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static bool _isInitializing = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (_isInitializing) {
      // 等待初始化完成
      while (_database == null) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _database!;
    }
    _isInitializing = true;
    try {
      _database = await _initDatabase();
      return _database!;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'yaya_diary.db');  // 芽芽日记数据库

    // Web 平台不支持，使用移动端 sqflite
    // Web 平台需要额外的配置，如使用 indexed_db 或 sqflite_common_ffi_web
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform is not supported yet. Please run on iOS or Android.',
      );
    }

    // 移动端使用默认的 sqflite
    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v2: 添加 duration 列到喂养记录表
      await db.execute('''
        ALTER TABLE feeding_records ADD COLUMN duration INTEGER
      ''');
    }
    if (oldVersion < 3) {
      // v3: 添加左右侧时长列
      await db.execute('''
        ALTER TABLE feeding_records ADD COLUMN left_duration INTEGER
      ''');
      await db.execute('''
        ALTER TABLE feeding_records ADD COLUMN right_duration INTEGER
      ''');
      await db.execute('''
        ALTER TABLE feeding_records ADD COLUMN mixed_duration INTEGER
      ''');
    }
    if (oldVersion < 4) {
      // v4: 添加辅食记录表
      await db.execute('''
        CREATE TABLE solid_food_records (
          id TEXT PRIMARY KEY,
          babyId TEXT NOT NULL,
          mealTime TEXT NOT NULL,
          foodName TEXT,
          amount REAL,
          texture TEXT,
          ingredients TEXT,
          notes TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      // v5: 添加疫苗接种记录表
      await db.execute('''
        CREATE TABLE vaccine_records (
          id TEXT PRIMARY KEY,
          babyId TEXT NOT NULL,
          vaccinationTime TEXT NOT NULL,
          vaccineName TEXT NOT NULL,
          vaccineCode TEXT,
          status TEXT NOT NULL DEFAULT 'pending',
          hospital TEXT,
          batchNumber TEXT,
          notes TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 6) {
      // v6: 将 batchNumber 改为 injectionSite
      await db.execute('''
        CREATE TABLE vaccine_records_new (
          id TEXT PRIMARY KEY,
          babyId TEXT NOT NULL,
          vaccinationTime TEXT NOT NULL,
          vaccineName TEXT NOT NULL,
          vaccineCode TEXT,
          status TEXT NOT NULL DEFAULT 'pending',
          hospital TEXT,
          injectionSite TEXT,
          notes TEXT,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        INSERT INTO vaccine_records_new (id, babyId, vaccinationTime, vaccineName, vaccineCode, status, hospital, injectionSite, notes, createdAt)
        SELECT id, babyId, vaccinationTime, vaccineName, vaccineCode, status, hospital, NULL, notes, createdAt FROM vaccine_records
      ''');
      await db.execute('DROP TABLE vaccine_records');
      await db.execute('ALTER TABLE vaccine_records_new RENAME TO vaccine_records');
    }
    if (oldVersion < 7) {
      // v7: 添加 doseNumber 列到疫苗记录表
      await db.execute('''
        ALTER TABLE vaccine_records ADD COLUMN doseNumber INTEGER
      ''');
    }
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
        duration INTEGER,
        left_duration INTEGER,
        right_duration INTEGER,
        mixed_duration INTEGER,
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

    // 辅食记录表
    await db.execute('''
      CREATE TABLE solid_food_records (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        mealTime TEXT NOT NULL,
        foodName TEXT,
        amount REAL,
        texture TEXT,
        ingredients TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');

    // 疫苗接种记录表
    await db.execute('''
      CREATE TABLE vaccine_records (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        vaccinationTime TEXT NOT NULL,
        vaccineName TEXT NOT NULL,
        vaccineCode TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        hospital TEXT,
        injectionSite TEXT,
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
    // 删除宝宝的所有相关记录
    await db.delete('feeding_records', where: 'babyId = ?', whereArgs: [babyId]);
    await db.delete('sleep_records', where: 'babyId = ?', whereArgs: [babyId]);
    await db.delete('diaper_records', where: 'babyId = ?', whereArgs: [babyId]);
    await db.delete('growth_records', where: 'babyId = ?', whereArgs: [babyId]);
    await db.delete('solid_food_records', where: 'babyId = ?', whereArgs: [babyId]);
    await db.delete('vaccine_records', where: 'babyId = ?', whereArgs: [babyId]);
    // 最后删除宝宝本身
    await db.delete('babies', where: 'id = ?', whereArgs: [babyId]);
  }

  // 清空所有数据
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('feeding_records');
    await db.delete('sleep_records');
    await db.delete('diaper_records');
    await db.delete('growth_records');
    await db.delete('solid_food_records');
    await db.delete('vaccine_records');
    await db.delete('babies');
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

  // Solid food record operations (辅食记录)
  Future<List<SolidFoodRecord>> getSolidFoodRecords([String? babyId]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = babyId == null
        ? await db.query('solid_food_records', orderBy: 'mealTime DESC')
        : await db.query(
            'solid_food_records',
            where: 'babyId = ?',
            whereArgs: [babyId],
            orderBy: 'mealTime DESC',
          );
    return List.generate(maps.length, (i) => SolidFoodRecord.fromMap(maps[i]));
  }

  Future<void> insertSolidFoodRecord(SolidFoodRecord record) async {
    final db = await database;
    await db.insert('solid_food_records', record.toMap());
  }

  Future<void> updateSolidFoodRecord(SolidFoodRecord record) async {
    final db = await database;
    await db.update(
      'solid_food_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteSolidFoodRecord(String recordId) async {
    final db = await database;
    await db.delete(
      'solid_food_records',
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  // Vaccine record operations (疫苗接种记录)
  Future<List<VaccineRecord>> getVaccineRecords([String? babyId]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = babyId == null
        ? await db.query('vaccine_records', orderBy: 'vaccinationTime DESC')
        : await db.query(
            'vaccine_records',
            where: 'babyId = ?',
            whereArgs: [babyId],
            orderBy: 'vaccinationTime DESC',
          );
    return List.generate(maps.length, (i) => VaccineRecord.fromMap(maps[i]));
  }

  Future<void> insertVaccineRecord(VaccineRecord record) async {
    final db = await database;
    await db.insert('vaccine_records', record.toMap());
  }

  Future<void> updateVaccineRecord(VaccineRecord record) async {
    final db = await database;
    await db.update(
      'vaccine_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteVaccineRecord(String recordId) async {
    final db = await database;
    await db.delete(
      'vaccine_records',
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }
}