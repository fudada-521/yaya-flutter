import '../chart_type.dart';
import 'chart_data_strategy.dart';

/// 尿布数据策略实现
/// 策略模式的具体策略类
class DiaperChartDataStrategy extends ChartDataStrategy<DiaperChartData> {
  @override
  String get title => '尿布分布';

  @override
  ChartType get type => ChartType.diaper;

  @override
  DiaperChartData getChartData(List<dynamic> records, TimeRange range) {
    // 筛选时间范围内的记录
    final filteredRecords = filterByTimeRange(records, range);

    int wetCount = 0;
    int dirtyCount = 0;
    int mixedCount = 0;

    for (var record in filteredRecords) {
      final diaper = record as DiaperRecord;
      switch (diaper.type) {
        case 'wet':
          wetCount++;
          break;
        case 'dirty':
          dirtyCount++;
          break;
        case 'mixed':
          mixedCount++;
          break;
      }
    }

    return DiaperChartData(
      wetCount: wetCount,
      dirtyCount: dirtyCount,
      mixedCount: mixedCount,
      totalCount: wetCount + dirtyCount + mixedCount,
    );
  }
}

/// 简化的尿布记录访问接口
class DiaperRecord {
  final DateTime changeTime;
  final String type;

  DiaperRecord({
    required this.changeTime,
    required this.type,
  });
}
