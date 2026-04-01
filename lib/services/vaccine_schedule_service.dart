import '../models/baby.dart';
import '../models/vaccine_plan.dart';
import '../models/vaccine_record.dart';

/// 疫苗计划计算服务
///
/// 提供中国国家免疫规划疫苗的接种时间计算功能。
/// 根据宝宝的出生日期，自动计算各疫苗的应接种时间。
class VaccineScheduleService {
  static final VaccineScheduleService _instance = VaccineScheduleService._internal();
  factory VaccineScheduleService() => _instance;
  VaccineScheduleService._internal();

  /// 根据宝宝出生日期计算所有疫苗的应接种时间
  ///
  /// [baby] - 宝宝信息
  /// [includeNonNational] - 是否包含非免疫规划疫苗，默认 false
  /// 返回按接种日期排序的疫苗接种计划列表
  List<VaccineScheduleItem> calculateSchedule(Baby baby, {bool includeNonNational = false}) {
    final List<VaccineScheduleItem> schedule = [];

    final vaccines = includeNonNational
        ? VaccinePlanData.allVaccines
        : VaccinePlanData.nationalVaccines;

    for (final vaccine in vaccines) {
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
  /// [includeNonNational] - 是否包含非免疫规划疫苗，默认 false
  List<VaccineScheduleItem> getAllPendingVaccines(
    Baby baby,
    Set<String> completedVaccines, {
    bool includeNonNational = false,
  }) {
    final schedule = calculateSchedule(baby, includeNonNational: includeNonNational);

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

  /// 计算自定义疫苗的接种计划
  ///
  /// [baby] - 宝宝信息
  /// [customRecords] - 自定义疫苗已完成记录列表（通常只传第一剂的记录）
  /// 返回按接种日期排序的自定义疫苗待接种计划列表
  List<CustomVaccineScheduleItem> calculateCustomVaccineSchedule(
    Baby baby,
    List<VaccineRecord> customRecords,
  ) {
    final List<CustomVaccineScheduleItem> schedule = [];

    // 按疫苗名称分组，每组取第一条记录（第一剂）作为代表
    final Map<String, VaccineRecord> firstDoseMap = {};
    for (final record in customRecords) {
      if (record.isCustom && record.doseNumber == 1) {
        // 使用疫苗名称作为key
        firstDoseMap[record.vaccineName] = record;
      }
    }

    for (final firstDose in firstDoseMap.values) {
      final totalDoses = firstDose.totalDoses ?? 1;
      final intervalMonths = firstDose.doseIntervalMonths ?? 1;
      final firstDoseMonth = firstDose.firstDoseMonth ?? 0;

      // 计算已接种的剂次数
      final completedDoses = customRecords
          .where((r) => r.vaccineName == firstDose.vaccineName && r.isCustom)
          .length;

      // 如果已完成所有剂次，跳过
      if (completedDoses >= totalDoses) continue;

      // 计算下一剂的信息
      final nextDoseNumber = completedDoses + 1;
      final nextDoseMonth = firstDoseMonth + (nextDoseNumber - 1) * intervalMonths;
      final nextScheduledDate = _calculateDate(baby.birthDate, nextDoseMonth);

      schedule.add(CustomVaccineScheduleItem(
        record: firstDose,
        scheduledDate: nextScheduledDate,
        doseNumber: nextDoseNumber,
        doseMonth: nextDoseMonth,
        isLastDose: nextDoseNumber >= totalDoses,
      ));
    }

    // 按日期排序
    schedule.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return schedule;
  }

  /// 获取自定义疫苗的已过期项
  List<CustomVaccineScheduleItem> getOverdueCustomVaccines(
    Baby baby,
    List<VaccineRecord> customRecords,
  ) {
    final schedule = calculateCustomVaccineSchedule(baby, customRecords);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return schedule.where((item) => item.scheduledDate.isBefore(today)).toList();
  }

  /// 获取自定义疫苗的即将到期项（未来30天）
  List<CustomVaccineScheduleItem> getUpcomingCustomVaccines(
    Baby baby,
    List<VaccineRecord> customRecords, {
    int daysAhead = 30,
  }) {
    final schedule = calculateCustomVaccineSchedule(baby, customRecords);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final threshold = today.add(Duration(days: daysAhead));

    return schedule.where((item) {
      return !item.scheduledDate.isBefore(today) &&
          item.scheduledDate.isAfter(threshold) == false;
    }).toList();
  }

  /// 获取自定义疫苗的待接种项（已过期 + 即将到期）
  List<CustomVaccineScheduleItem> getPendingCustomVaccines(
    Baby baby,
    List<VaccineRecord> customRecords,
  ) {
    final overdue = getOverdueCustomVaccines(baby, customRecords);
    final upcoming = getUpcomingCustomVaccines(baby, customRecords);

    // 合并并去重
    final combined = <String, CustomVaccineScheduleItem>{};
    for (final item in overdue) {
      combined[item.record.vaccineName] = item;
    }
    for (final item in upcoming) {
      combined[item.record.vaccineName] = item;
    }

    final result = combined.values.toList();
    result.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return result;
  }

  /// 根据出生日期和月龄计算实际日期
  DateTime _calculateDate(DateTime birthDate, int months) {
    final targetMonth = birthDate.month + months;
    final targetYear = birthDate.year + (targetMonth - 1) ~/ 12;
    final actualMonth = ((targetMonth - 1) % 12) + 1;

    // 处理月底日期边界情况
    final lastDayOfMonth = DateTime(targetYear, actualMonth + 1, 0).day;
    final targetDay = birthDate.day > lastDayOfMonth ? lastDayOfMonth : birthDate.day;

    return DateTime(targetYear, actualMonth, targetDay);
  }
}
