import '../chart_type.dart';
import 'chart_data_strategy.dart';

/// 成长数据策略实现
/// 策略模式的具体策略类
class GrowthChartDataStrategy extends ChartDataStrategy<GrowthChartData> {
  @override
  String get title => '成长曲线';

  @override
  ChartType get type => ChartType.growth;

  @override
  GrowthChartData getChartData(List<dynamic> records, TimeRange range) {
    // 筛选时间范围内的记录
    final filteredRecords = filterByTimeRange(records, range);

    final heightPoints = <GrowthPoint>[];
    final weightPoints = <GrowthPoint>[];
    double maxHeight = 0;
    double maxWeight = 0;

    // 按日期排序
    final sortedRecords = filteredRecords.cast<GrowthRecord>()
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

    for (var record in sortedRecords) {
      if (record.height != null && record.height! > 0) {
        heightPoints.add(GrowthPoint(
          date: record.recordDate,
          value: record.height!,
          ageInMonths: record.ageInMonths,
        ));
        if (record.height! > maxHeight) maxHeight = record.height!;
      }
      if (record.weight != null && record.weight! > 0) {
        weightPoints.add(GrowthPoint(
          date: record.recordDate,
          value: record.weight!,
          ageInMonths: record.ageInMonths,
        ));
        if (record.weight! > maxWeight) maxWeight = record.weight!;
      }
    }

    return GrowthChartData(
      heightPoints: heightPoints,
      weightPoints: weightPoints,
      maxHeight: maxHeight > 0 ? maxHeight : 100,
      maxWeight: maxWeight > 0 ? maxWeight : 20,
    );
  }
}

/// 简化的成长记录访问接口
class GrowthRecord {
  final DateTime recordDate;
  final double? height;
  final double? weight;

  GrowthRecord({
    required this.recordDate,
    this.height,
    this.weight,
  });

  int get ageInMonths {
    // 需要根据宝宝出生日期计算，这里简化处理
    return 0;
  }
}
