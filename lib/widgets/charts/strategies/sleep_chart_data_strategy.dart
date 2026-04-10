import '../chart_type.dart';
import 'chart_data_strategy.dart';

/// 睡眠数据策略实现
/// 策略模式的具体策略类
class SleepChartDataStrategy extends ChartDataStrategy<SleepChartData> {
  @override
  String get title => '睡眠趋势';

  @override
  ChartType get type => ChartType.sleep;

  @override
  SleepChartData getChartData(List<dynamic> records, TimeRange range) {
    // 筛选时间范围内的记录
    final filteredRecords = filterByTimeRange(records, range);

    // 按日期分组统计
    final Map<String, List<dynamic>> groupedByDate = {};
    for (var record in filteredRecords) {
      final dateKey = _getDateKey((record as HasDateTime).dateTime);
      groupedByDate.putIfAbsent(dateKey, () => []).add(record);
    }

    // 转换为每日数据
    final dailySleeps = <DailySleep>[];
    double maxDuration = 0;
    double totalDuration = 0;

    // 按日期排序
    final sortedKeys = groupedByDate.keys.toList()..sort();
    for (var dateKey in sortedKeys) {
      final dayRecords = groupedByDate[dateKey]!;
      double dayDuration = 0;
      for (var record in dayRecords) {
        final sleep = record as SleepRecord;
        if (sleep.endTime != null) {
          // 计算睡眠时长（小时）
          final duration = sleep.endTime!.difference(sleep.startTime).inMinutes / 60.0;
          dayDuration += duration;
        }
      }
      dailySleeps.add(DailySleep(
        date: _parseDate(dateKey),
        duration: dayDuration,
      ));
      if (dayDuration > maxDuration) maxDuration = dayDuration;
      totalDuration += dayDuration;
    }

    return SleepChartData(
      dailySleeps: dailySleeps,
      maxDuration: maxDuration > 0 ? maxDuration : 24,
      totalDuration: totalDuration,
    );
  }

  String _getDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  DateTime _parseDate(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

/// 简化的睡眠记录访问接口
class SleepRecord {
  final DateTime startTime;
  final DateTime? endTime;

  SleepRecord({
    required this.startTime,
    this.endTime,
  });
}
