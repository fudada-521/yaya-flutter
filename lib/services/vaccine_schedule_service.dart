import '../models/baby.dart';
import '../models/vaccine_plan.dart';

/// 疫苗计划计算服务
///
/// 提供中国国家免疫规划疫苗的接种时间计算功能。
/// 根据宝宝的出生日期，自动计算各疫苗的应接种时间。
class VaccineScheduleService {
  VaccineScheduleService._();

  static final VaccineScheduleService _instance = VaccineScheduleService._internal();
  factory VaccineScheduleService() => _instance;
  VaccineScheduleService._internal();

  /// 根据宝宝出生日期计算所有疫苗的应接种时间
  ///
  /// 返回按接种日期排序的疫苗接种计划列表
  List<VaccineScheduleItem> calculateSchedule(Baby baby) {
    final List<VaccineScheduleItem> schedule = [];

    for (final vaccine in VaccinePlanData.nationalVaccines) {
      for (int i = 0; i < vaccine.recommendedMonths.length; i++) {
        final month = vaccine.recommendedMonths[i];
        final scheduledDate = vaccine.calculateDate(baby.birthDate, month);

        schedule.add(VaccineScheduleItem(
          vaccine: vaccine,
          scheduledDate: scheduledDate,
          doseNumber: i + 1,
          doseMonth: month,
        ));
      }
    }

    // 按日期排序
    schedule.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return schedule;
  }

  /// 获取已到期的疫苗（当前日期之前的）
  ///
  /// [baby] - 宝宝信息
  /// [completedVaccines] - 已完成的疫苗代码列表
  List<VaccineScheduleItem> getOverdueVaccines(
    Baby baby,
    Set<String> completedVaccines,
  ) {
    final schedule = calculateSchedule(baby);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return schedule.where((item) {
      // 只看当前日期之前的
      if (item.scheduledDate.isAfter(today)) return false;
      // 排除已完成的
      final vaccineKey = '${item.vaccine.code}_${item.doseNumber}';
      if (completedVaccines.contains(vaccineKey)) return false;
      return true;
    }).toList();
  }

  /// 获取即将到期的疫苗（未来30天内）
  ///
  /// [baby] - 宝宝信息
  /// [completedVaccines] - 已完成的疫苗代码列表
  /// [daysAhead] - 提前多少天，默认30天
  List<VaccineScheduleItem> getUpcomingVaccines(
    Baby baby,
    Set<String> completedVaccines, {
    int daysAhead = 30,
  }) {
    final schedule = calculateSchedule(baby);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final threshold = today.add(Duration(days: daysAhead));

    return schedule.where((item) {
      // 只看今天之后、threshold之前的
      if (item.scheduledDate.isBefore(today) || item.scheduledDate.isAfter(threshold)) {
        return false;
      }
      // 排除已完成的
      final vaccineKey = '${item.vaccine.code}_${item.doseNumber}';
      if (completedVaccines.contains(vaccineKey)) return false;
      return true;
    }).toList();
  }

  /// 获取待接种疫苗（已过期的 + 即将到期的）
  ///
  /// [baby] - 宝宝信息
  /// [completedVaccines] - 已完成的疫苗代码列表
  List<VaccineScheduleItem> getPendingVaccines(
    Baby baby,
    Set<String> completedVaccines,
  ) {
    final overdue = getOverdueVaccines(baby, completedVaccines);
    final upcoming = getUpcomingVaccines(baby, completedVaccines);

    // 合并并去重
    final combined = <String, VaccineScheduleItem>{};
    for (final item in overdue) {
      combined['${item.vaccine.code}_${item.doseNumber}'] = item;
    }
    for (final item in upcoming) {
      combined['${item.vaccine.code}_${item.doseNumber}'] = item;
    }

    final result = combined.values.toList();
    result.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return result;
  }

  /// 获取所有未完成的疫苗
  ///
  /// [baby] - 宝宝信息
  /// [completedVaccines] - 已完成的疫苗代码列表
  List<VaccineScheduleItem> getAllPendingVaccines(
    Baby baby,
    Set<String> completedVaccines,
  ) {
    final schedule = calculateSchedule(baby);

    return schedule.where((item) {
      final vaccineKey = '${item.vaccine.code}_${item.doseNumber}';
      return !completedVaccines.contains(vaccineKey);
    }).toList();
  }

  /// 获取已完成接种的疫苗数量
  int getCompletedCount(Set<String> completedVaccines) {
    return completedVaccines.length;
  }

  /// 获取疫苗接种进度描述
  String getProgressDescription(Set<String> completedVaccines) {
    final total = VaccinePlanData.totalDoses;
    final completed = completedVaccines.length;
    return '$completed / $total';
  }

  /// 根据疫苗代码和剂次查找疫苗计划项
  VaccineScheduleItem? findScheduleItem(
    Baby baby,
    String vaccineCode,
    int doseNumber,
  ) {
    final schedule = calculateSchedule(baby);
    try {
      return schedule.firstWhere(
        (item) => item.vaccine.code == vaccineCode && item.doseNumber == doseNumber,
      );
    } catch (_) {
      return null;
    }
  }
}
