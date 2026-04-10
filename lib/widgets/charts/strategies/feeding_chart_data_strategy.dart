import '../chart_type.dart';
import 'chart_data_strategy.dart';

/// 喂养数据策略实现
/// 策略模式的具体策略类
class FeedingChartDataStrategy extends ChartDataStrategy<FeedingChartData> {
  @override
  String get title => '喂养趋势';

  @override
  ChartType get type => ChartType.feeding;

  @override
  FeedingChartData getChartData(List<dynamic> records, TimeRange range) {
    // 筛选时间范围内的记录
    final filteredRecords = filterByTimeRange(records, range);

    // 按日期分组统计
    final Map<String, List<dynamic>> groupedByDate = {};
    for (var record in filteredRecords) {
      final dateKey = _getDateKey((record as HasDateTime).dateTime);
      groupedByDate.putIfAbsent(dateKey, () => []).add(record);
    }

    // 转换为每日数据
    final dailyFeedings = <DailyFeeding>[];
    double maxAmount = 0;
    double totalAmount = 0;
    int totalCount = 0;

    // 按日期排序
    final sortedKeys = groupedByDate.keys.toList()..sort();
    for (var dateKey in sortedKeys) {
      final dayRecords = groupedByDate[dateKey]!;
      double dayAmount = 0;
      for (var record in dayRecords) {
        final feeding = record as FeedingRecord;
        // 母乳亲喂按每次60ml估算
        if (feeding.type == 'breast') {
          dayAmount += feeding.duration != null ? feeding.duration! * 10.0 : 60.0;
        } else {
          dayAmount += feeding.amount ?? 0;
        }
      }
      final count = dayRecords.length;
      dailyFeedings.add(DailyFeeding(
        date: _parseDate(dateKey),
        amount: dayAmount,
        count: count,
      ));
      if (dayAmount > maxAmount) maxAmount = dayAmount;
      totalAmount += dayAmount;
      totalCount += count;
    }

    return FeedingChartData(
      dailyFeedings: dailyFeedings,
      maxAmount: maxAmount > 0 ? maxAmount : 100,
      totalAmount: totalAmount,
      totalCount: totalCount,
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

/// 简化的喂养记录访问接口
class FeedingRecord {
  final DateTime feedTime;
  final double? amount;
  final String type;
  final int? duration;

  FeedingRecord({
    required this.feedTime,
    this.amount,
    required this.type,
    this.duration,
  });
}
