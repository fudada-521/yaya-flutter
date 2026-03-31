import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/growth_record.dart';
import '../models/solid_food_record.dart';

/// 记录数据状态管理类
///
/// 使用 Provider 模式管理所有记录类型的全局状态。
/// 支持五种记录类型：喂养、睡眠、尿布、成长、辅食。
/// 提供筛选功能（按宝宝、日期范围）和数据统计。
class RecordsProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 记录列表
  List<FeedingRecord> _feedingRecords = [];
  List<SleepRecord> _sleepRecords = [];
  List<DiaperRecord> _diaperRecords = [];
  List<GrowthRecord> _growthRecords = [];
  List<SolidFoodRecord> _solidFoodRecords = [];

  // 当前筛选条件
  String? _currentBabyId;
  DateTime? _startDate;
  DateTime? _endDate;

  // 加载状态
  bool _isLoading = false;

  RecordsProvider() {
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    try {
      await _databaseHelper.database;
      await loadAllRecords();
    } catch (e) {
      debugPrint('初始化记录数据失败: $e');
    }
  }

  // Getters
  List<FeedingRecord> get feedingRecords => _filteredFeedingRecords;
  List<SleepRecord> get sleepRecords => _filteredSleepRecords;
  List<DiaperRecord> get diaperRecords => _filteredDiaperRecords;
  List<GrowthRecord> get growthRecords => _filteredGrowthRecords;
  List<SolidFoodRecord> get solidFoodRecords => _filteredSolidFoodRecords;

  List<FeedingRecord> get _filteredFeedingRecords {
    var records = _feedingRecords;
    if (_currentBabyId != null) {
      records = records.where((r) => r.babyId == _currentBabyId).toList();
    }
    if (_startDate != null) {
      records = records.where((r) => r.feedTime.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      records = records.where((r) => r.feedTime.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }
    return records;
  }

  List<SleepRecord> get _filteredSleepRecords {
    var records = _sleepRecords;
    if (_currentBabyId != null) {
      records = records.where((r) => r.babyId == _currentBabyId).toList();
    }
    if (_startDate != null) {
      records = records.where((r) => r.startTime.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      records = records.where((r) => r.startTime.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }
    return records;
  }

  List<DiaperRecord> get _filteredDiaperRecords {
    var records = _diaperRecords;
    if (_currentBabyId != null) {
      records = records.where((r) => r.babyId == _currentBabyId).toList();
    }
    if (_startDate != null) {
      records = records.where((r) => r.changeTime.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      records = records.where((r) => r.changeTime.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }
    return records;
  }

  List<GrowthRecord> get _filteredGrowthRecords {
    var records = _growthRecords;
    if (_currentBabyId != null) {
      records = records.where((r) => r.babyId == _currentBabyId).toList();
    }
    if (_startDate != null) {
      records = records.where((r) => r.recordDate.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      records = records.where((r) => r.recordDate.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }
    return records;
  }

  List<SolidFoodRecord> get _filteredSolidFoodRecords {
    var records = _solidFoodRecords;
    if (_currentBabyId != null) {
      records = records.where((r) => r.babyId == _currentBabyId).toList();
    }
    if (_startDate != null) {
      records = records.where((r) => r.mealTime.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      records = records.where((r) => r.mealTime.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }
    return records;
  }

  bool get isLoading => _isLoading;

  // 加载所有记录
  Future<void> loadAllRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      _feedingRecords = await _databaseHelper.getFeedingRecords();
      _sleepRecords = await _databaseHelper.getSleepRecords();
      _diaperRecords = await _databaseHelper.getDiaperRecords();
      _growthRecords = await _databaseHelper.getGrowthRecords();
      _solidFoodRecords = await _databaseHelper.getSolidFoodRecords();
    } catch (e) {
      debugPrint('加载记录失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 设置筛选条件
  void setFilter({String? babyId, DateTime? startDate, DateTime? endDate}) {
    _currentBabyId = babyId;
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }

  // 清除筛选条件
  void clearFilter() {
    _currentBabyId = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // Feeding record operations
  Future<void> addFeedingRecord(FeedingRecord record) async {
    try {
      await _databaseHelper.insertFeedingRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('添加喂养记录失败: $e');
    }
  }

  Future<void> updateFeedingRecord(FeedingRecord record) async {
    try {
      await _databaseHelper.updateFeedingRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('更新喂养记录失败: $e');
    }
  }

  Future<void> deleteFeedingRecord(String recordId) async {
    try {
      await _databaseHelper.deleteFeedingRecord(recordId);
      await loadAllRecords();
    } catch (e) {
      debugPrint('删除喂养记录失败: $e');
    }
  }

  // Sleep record operations
  Future<void> addSleepRecord(SleepRecord record) async {
    try {
      await _databaseHelper.insertSleepRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('添加睡眠记录失败: $e');
    }
  }

  Future<void> updateSleepRecord(SleepRecord record) async {
    try {
      await _databaseHelper.updateSleepRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('更新睡眠记录失败: $e');
    }
  }

  Future<void> deleteSleepRecord(String recordId) async {
    try {
      await _databaseHelper.deleteSleepRecord(recordId);
      await loadAllRecords();
    } catch (e) {
      debugPrint('删除睡眠记录失败: $e');
    }
  }

  // Diaper record operations
  Future<void> addDiaperRecord(DiaperRecord record) async {
    try {
      await _databaseHelper.insertDiaperRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('添加换尿布记录失败: $e');
    }
  }

  Future<void> updateDiaperRecord(DiaperRecord record) async {
    try {
      await _databaseHelper.updateDiaperRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('更新换尿布记录失败: $e');
    }
  }

  Future<void> deleteDiaperRecord(String recordId) async {
    try {
      await _databaseHelper.deleteDiaperRecord(recordId);
      await loadAllRecords();
    } catch (e) {
      debugPrint('删除换尿布记录失败: $e');
    }
  }

  // Growth record operations
  Future<void> addGrowthRecord(GrowthRecord record) async {
    try {
      await _databaseHelper.insertGrowthRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('添加成长记录失败: $e');
    }
  }

  Future<void> updateGrowthRecord(GrowthRecord record) async {
    try {
      await _databaseHelper.updateGrowthRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('更新成长记录失败: $e');
    }
  }

  Future<void> deleteGrowthRecord(String recordId) async {
    try {
      await _databaseHelper.deleteGrowthRecord(recordId);
      await loadAllRecords();
    } catch (e) {
      debugPrint('删除成长记录失败: $e');
    }
  }

  // Solid food record operations (辅食记录)
  Future<void> addSolidFoodRecord(SolidFoodRecord record) async {
    try {
      await _databaseHelper.insertSolidFoodRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('添加辅食记录失败: $e');
    }
  }

  Future<void> updateSolidFoodRecord(SolidFoodRecord record) async {
    try {
      await _databaseHelper.updateSolidFoodRecord(record);
      await loadAllRecords();
    } catch (e) {
      debugPrint('更新辅食记录失败: $e');
    }
  }

  Future<void> deleteSolidFoodRecord(String recordId) async {
    try {
      await _databaseHelper.deleteSolidFoodRecord(recordId);
      await loadAllRecords();
    } catch (e) {
      debugPrint('删除辅食记录失败: $e');
    }
  }

  // 清空所有记录
  Future<void> clearAllRecords() async {
    try {
      await _databaseHelper.clearAllData();
      _feedingRecords = [];
      _sleepRecords = [];
      _diaperRecords = [];
      _growthRecords = [];
      _solidFoodRecords = [];
      notifyListeners();
    } catch (e) {
      debugPrint('清空所有记录失败: $e');
    }
  }

  // 统计方法
  Map<String, dynamic> getTodayStats() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final todayFeeding = _filteredFeedingRecords.where((r) => r.feedTime.isAfter(todayStart)).toList();
    final todaySleep = _filteredSleepRecords.where((r) => r.startTime.isAfter(todayStart)).toList();
    final todayDiaper = _filteredDiaperRecords.where((r) => r.changeTime.isAfter(todayStart)).toList();

    return {
      'feedingCount': todayFeeding.length,
      'totalFeedingAmount': todayFeeding.fold(0.0, (sum, r) => sum + (r.amount ?? 0)),
      'totalSleepDuration': todaySleep.fold<Duration>(
        Duration.zero,
        (sum, r) => sum + (r.duration ?? Duration.zero),
      ),
      'diaperCount': todayDiaper.length,
    };
  }

  // 获取最近记录
  List<dynamic> getRecentRecords({int limit = 10}) {
    final allRecords = <dynamic>[];
    allRecords.addAll(_filteredFeedingRecords);
    allRecords.addAll(_filteredSleepRecords);
    allRecords.addAll(_filteredDiaperRecords);
    allRecords.addAll(_filteredGrowthRecords);
    allRecords.addAll(_filteredSolidFoodRecords);

    // 按时间排序
    allRecords.sort((a, b) {
      DateTime aTime;
      DateTime bTime;

      if (a is FeedingRecord) {
        aTime = a.feedTime;
      } else if (a is SleepRecord) {
        aTime = a.startTime;
      } else if (a is DiaperRecord) {
        aTime = a.changeTime;
      } else if (a is GrowthRecord) {
        aTime = a.recordDate;
      } else if (a is SolidFoodRecord) {
        aTime = a.mealTime;
      } else {
        return 0;
      }

      if (b is FeedingRecord) {
        bTime = b.feedTime;
      } else if (b is SleepRecord) {
        bTime = b.startTime;
      } else if (b is DiaperRecord) {
        bTime = b.changeTime;
      } else if (b is GrowthRecord) {
        bTime = b.recordDate;
      } else if (b is SolidFoodRecord) {
        bTime = b.mealTime;
      } else {
        return 0;
      }

      return bTime.compareTo(aTime);
    });

    return allRecords.take(limit).toList();
  }
}