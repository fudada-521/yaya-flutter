import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/vaccine_record.dart';
import '../models/vaccine_plan.dart';
import '../models/baby.dart';
import '../services/vaccine_schedule_service.dart';
import '../services/notification_service.dart';

/// 疫苗记录状态管理类
///
/// 使用 Provider 模式管理疫苗接种记录的全局状态。
/// 提供疫苗记录CRUD、接种计划计算、提醒管理等功能。
class VaccineProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final VaccineScheduleService _scheduleService = VaccineScheduleService();
  final NotificationService _notificationService = NotificationService();

  // 疫苗记录列表
  List<VaccineRecord> _vaccineRecords = [];

  // 加载状态
  bool _isLoading = false;

  VaccineProvider() {
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    try {
      await _databaseHelper.database;
      await loadVaccineRecords();
    } catch (e) {
      debugPrint('初始化疫苗数据失败: $e');
    }
  }

  // Getters
  List<VaccineRecord> get vaccineRecords => _vaccineRecords;
  bool get isLoading => _isLoading;

  /// 加载所有疫苗记录
  Future<void> loadVaccineRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      _vaccineRecords = await _databaseHelper.getVaccineRecords();
    } catch (e) {
      debugPrint('加载疫苗记录失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 根据宝宝ID筛选已完成的疫苗记录
  Set<String> _getCompletedVaccineKeys(String babyId) {
    final completedRecords = _vaccineRecords
        .where((r) => r.babyId == babyId && r.status == VaccineRecord.statusCompleted)
        .toList();

    return completedRecords.map((r) {
      // 查找对应的剂次
      final vaccine = VaccinePlanData.findByName(r.vaccineName);
      if (vaccine != null) {
        final doseIndex = vaccine.recommendedMonths.indexWhere((m) {
          final doseDate = vaccine.calculateDate(
            _getBabyBirthDate(babyId),
            m,
          );
          return doseDate.year == r.vaccinationTime.year &&
              doseDate.month == r.vaccinationTime.month &&
              doseDate.day == r.vaccinationTime.day;
        });
        if (doseIndex >= 0) {
          return '${r.vaccineName}_${doseIndex + 1}';
        }
      }
      return '${r.vaccineName}_1';
    }).toSet();
  }

  DateTime _getBabyBirthDate(String babyId) {
    // 这是一个简化实现，实际应该从 BabyProvider 获取
    // 暂时返回一个默认日期
    return DateTime.now().subtract(const Duration(days: 180));
  }

  /// 根据宝宝ID筛选记录
  List<VaccineRecord> getRecordsForBaby(String babyId) {
    return _vaccineRecords.where((r) => r.babyId == babyId).toList();
  }

  /// 获取宝宝的已完成疫苗集合（用于计划计算）
  Set<String> getCompletedVaccineKeys(String babyId) {
    return _getCompletedVaccineKeys(babyId);
  }

  /// 获取待接种疫苗（已过期 + 未来30天）
  List<VaccineScheduleItem> getPendingVaccines(Baby baby) {
    final completedKeys = _getCompletedVaccineKeys(baby.id);
    return _scheduleService.getPendingVaccines(baby, completedKeys);
  }

  /// 获取即将到期的疫苗（未来30天）
  List<VaccineScheduleItem> getUpcomingVaccines(Baby baby) {
    final completedKeys = _getCompletedVaccineKeys(baby.id);
    return _scheduleService.getUpcomingVaccines(baby, completedKeys);
  }

  /// 获取所有未完成的疫苗
  List<VaccineScheduleItem> getAllPendingVaccines(Baby baby) {
    final completedKeys = _getCompletedVaccineKeys(baby.id);
    return _scheduleService.getAllPendingVaccines(baby, completedKeys);
  }

  /// 获取已完成接种的数量
  int getCompletedCount(String babyId) {
    return _vaccineRecords
        .where((r) => r.babyId == babyId && r.status == VaccineRecord.statusCompleted)
        .length;
  }

  /// 获取疫苗接种进度描述
  String getProgressDescription(String babyId) {
    final completed = getCompletedCount(babyId);
    final total = VaccinePlanData.totalDoses;
    return '$completed / $total';
  }

  /// 添加疫苗接种记录
  Future<void> addVaccineRecord(VaccineRecord record) async {
    try {
      await _databaseHelper.insertVaccineRecord(record);
      await loadVaccineRecords();
    } catch (e) {
      debugPrint('添加疫苗记录失败: $e');
      rethrow;
    }
  }

  /// 更新疫苗接种记录
  Future<void> updateVaccineRecord(VaccineRecord record) async {
    try {
      await _databaseHelper.updateVaccineRecord(record);
      await loadVaccineRecords();
    } catch (e) {
      debugPrint('更新疫苗记录失败: $e');
      rethrow;
    }
  }

  /// 删除疫苗接种记录
  Future<void> deleteVaccineRecord(String recordId) async {
    try {
      await _databaseHelper.deleteVaccineRecord(recordId);
      await loadVaccineRecords();
    } catch (e) {
      debugPrint('删除疫苗记录失败: $e');
      rethrow;
    }
  }

  /// 为宝宝安排所有待接种疫苗的提醒
  Future<void> scheduleRemindersForBaby(Baby baby) async {
    // 先取消现有提醒
    await _notificationService.cancelAllVaccineReminders(baby.id);

    final pendingVaccines = getPendingVaccines(baby);

    for (final vaccine in pendingVaccines) {
      // 只为未来的疫苗设置提醒
      if (vaccine.scheduledDate.isAfter(DateTime.now())) {
        await _notificationService.scheduleVaccineReminder(
          babyId: baby.id,
          vaccineName: vaccine.vaccine.name,
          scheduledDate: vaccine.scheduledDate,
          babyName: baby.name,
        );
      }
    }
  }

  /// 刷新提醒（取消并重新设置）
  Future<void> refreshReminders(Baby baby) async {
    await scheduleRemindersForBaby(baby);
  }
}
