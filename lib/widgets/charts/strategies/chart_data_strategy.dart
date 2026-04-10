import '../chart_type.dart';

/// 图表数据策略抽象接口
/// 定义所有图表数据策略的共同接口
/// 采用策略模式：将数据处理逻辑封装到独立策略类中
abstract class ChartDataStrategy<T> {
  /// 获取图表标题
  String get title;

  /// 获取图表类型
  ChartType get type;

  /// 获取图表数据
  /// [records] 原始记录列表
  /// [range] 时间范围
  /// 返回处理后的图表数据
  T getChartData(List<dynamic> records, TimeRange range);

  /// 获取时间范围内的过滤后数据
  List<dynamic> filterByTimeRange(List<dynamic> records, TimeRange range) {
    final startDate = TimeRangeHelper.getStartDate(range);
    final endDate = TimeRangeHelper.getEndDate(range);

    return records.where((record) {
      final recordDate = _getRecordDate(record);
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// 从记录中获取日期（模板方法，子类实现）
  DateTime _getRecordDate(dynamic record) {
    if (record is HasDateTime) {
      return record.dateTime;
    }
    throw UnimplementedError('Record must implement HasDateTime');
  }
}

/// 具有日期时间属性的接口
/// 用于策略模式中统一访问记录的日期时间
abstract class HasDateTime {
  DateTime get dateTime;
}

/// 喂养记录数据（柱状图）
class FeedingChartData {
  final List<DailyFeeding> dailyFeedings;
  final double maxAmount;
  final double totalAmount;
  final int totalCount;

  FeedingChartData({
    required this.dailyFeedings,
    required this.maxAmount,
    required this.totalAmount,
    required this.totalCount,
  });
}

class DailyFeeding {
  final DateTime date;
  final double amount; // ml
  final int count;

  DailyFeeding({
    required this.date,
    required this.amount,
    required this.count,
  });

  /// 获取日期标签
  String get dateLabel =>
      '${date.month}/${date.day}';
}

/// 睡眠记录数据（折线图）
class SleepChartData {
  final List<DailySleep> dailySleeps;
  final double maxDuration; // 小时
  final double totalDuration; // 总小时数

  SleepChartData({
    required this.dailySleeps,
    required this.maxDuration,
    required this.totalDuration,
  });
}

class DailySleep {
  final DateTime date;
  final double duration; // 小时

  DailySleep({
    required this.date,
    required this.duration,
  });

  String get dateLabel =>
      '${date.month}/${date.day}';
}

/// 尿布记录数据（饼图）
class DiaperChartData {
  final int wetCount;      // 小便次数
  final int dirtyCount;    // 大便次数
  final int mixedCount;    // 混合次数
  final int totalCount;

  DiaperChartData({
    required this.wetCount,
    required this.dirtyCount,
    required this.mixedCount,
    required this.totalCount,
  });

  double get wetPercent => totalCount > 0 ? wetCount / totalCount : 0;
  double get dirtyPercent => totalCount > 0 ? dirtyCount / totalCount : 0;
  double get mixedPercent => totalCount > 0 ? mixedCount / totalCount : 0;
}

/// 成长记录数据（折线图）
class GrowthChartData {
  final List<GrowthPoint> heightPoints;  // 身高数据点
  final List<GrowthPoint> weightPoints;  // 体重数据点
  final double maxHeight;
  final double maxWeight;

  GrowthChartData({
    required this.heightPoints,
    required this.weightPoints,
    required this.maxHeight,
    required this.maxWeight,
  });
}

class GrowthPoint {
  final DateTime date;
  final double value;     // 身高(cm)或体重(kg)
  final int ageInMonths;  // 月龄

  GrowthPoint({
    required this.date,
    required this.value,
    required this.ageInMonths,
  });

  String get dateLabel => '${date.month}/${date.day}';
}

/// 辅食记录数据（柱状图）
class SolidFoodChartData {
  final Map<String, int> textureCounts; // 各质地类型次数
  final int totalCount;
  final String mostUsedTexture;

  SolidFoodChartData({
    required this.textureCounts,
    required this.totalCount,
    required this.mostUsedTexture,
  });
}
