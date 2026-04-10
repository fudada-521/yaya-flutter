export 'chart_data_helper.dart' show TimeRangeHelper;

/// 图表类型枚举
/// 用于标识不同类型的统计图表
enum ChartType {
  feeding,    // 喂养趋势图
  sleep,      // 睡眠趋势图
  diaper,     // 尿布分布图
  growth,     // 成长曲线图
  solidFood,  // 辅食统计图
}

/// 时间范围枚举
/// 用于筛选图表数据的时间范围
enum TimeRange {
  today,  // 今日
  week,   // 本周
  month,  // 本月
  all,    // 全部
}
