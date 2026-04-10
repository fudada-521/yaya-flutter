import 'chart_type.dart';

/// 图表数据辅助类
/// 统一处理数据过滤、聚合等通用逻辑
/// 采用辅助类模式：提供静态方法复用数据处理逻辑
class ChartDataHelper {
  /// 根据时间范围过滤记录
  /// [records] 原始记录列表，每条记录需要有 dateTime 属性
  /// [range] 时间范围
  /// [getDateTime] 从记录中获取日期时间的函数
  static List<T> filterByTimeRange<T>(
    List<T> records,
    TimeRange range,
    DateTime Function(T) getDateTime,
  ) {
    final startDate = TimeRangeHelper.getStartDate(range);
    final endDate = TimeRangeHelper.getEndDate(range);

    return records.where((record) {
      final recordDate = getDateTime(record);
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// 按日期分组统计
  /// 返回 Map，key 为日期字符串 "yyyy-MM-dd"，value 为该日期的记录列表
  static Map<String, List<T>> groupByDate<T>(
    List<T> records,
    DateTime Function(T) getDateTime,
  ) {
    final Map<String, List<T>> grouped = {};
    for (var record in records) {
      final dateKey = _getDateKey(getDateTime(record));
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }
    return grouped;
  }

  /// 获取排序后的日期键列表
  static List<String> getSortedDateKeys(Map<String, List<dynamic>> grouped) {
    return grouped.keys.toList()..sort();
  }

  /// 生成日期标签
  static String formatDateLabel(DateTime date) {
    return '${date.month}/${date.day}';
  }

  /// 日期转字符串 key
  static String _getDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// 解析日期字符串为 DateTime
  static DateTime parseDate(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

/// 时间范围辅助类
class TimeRangeHelper {
  /// 获取时间范围的显示名称
  static String getDisplayName(TimeRange range) {
    switch (range) {
      case TimeRange.today:
        return '今日';
      case TimeRange.week:
        return '本周';
      case TimeRange.month:
        return '本月';
      case TimeRange.all:
        return '全部';
    }
  }

  /// 根据时间范围获取开始日期
  static DateTime getStartDate(TimeRange range) {
    final now = DateTime.now();
    switch (range) {
      case TimeRange.today:
        return DateTime(now.year, now.month, now.day);
      case TimeRange.week:
        return DateTime(now.year, now.month, now.day - now.weekday + 1);
      case TimeRange.month:
        return DateTime(now.year, now.month, 1);
      case TimeRange.all:
        return DateTime(1970);
    }
  }

  /// 根据时间范围获取结束日期
  static DateTime getEndDate(TimeRange range) {
    final now = DateTime.now();
    switch (range) {
      case TimeRange.today:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case TimeRange.week:
        return DateTime(now.year, now.month, now.day + (7 - now.weekday), 23, 59, 59);
      case TimeRange.month:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case TimeRange.all:
        return now;
    }
  }
}
