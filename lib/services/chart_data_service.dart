import '../widgets/charts/chart_type.dart';
import '../widgets/charts/strategies/chart_data_strategy.dart';
import '../widgets/charts/strategies/diaper_chart_data_strategy.dart';
import '../widgets/charts/strategies/feeding_chart_data_strategy.dart';
import '../widgets/charts/strategies/growth_chart_data_strategy.dart';
import '../widgets/charts/strategies/sleep_chart_data_strategy.dart';
import '../widgets/charts/strategies/solid_food_chart_data_strategy.dart';

/// 图表数据服务单例类
/// 采用单例模式：全局唯一实例，管理图表数据的获取和缓存
class ChartDataService {
  // 单例实例
  static final ChartDataService _instance = ChartDataService._internal();
  factory ChartDataService() => _instance;
  ChartDataService._internal();

  // 数据缓存（预留）
  final Map<String, dynamic> _cache = {};

  /// 清理缓存
  void clearCache() {
    _cache.clear();
  }

  /// 获取喂养图表数据
  FeedingChartData getFeedingData(
    List<dynamic> records,
    TimeRange range,
  ) {
    final strategy = FeedingChartDataStrategy();
    return strategy.getChartData(records, range);
  }

  /// 获取睡眠图表数据
  SleepChartData getSleepData(
    List<dynamic> records,
    TimeRange range,
  ) {
    final strategy = SleepChartDataStrategy();
    return strategy.getChartData(records, range);
  }

  /// 获取尿布图表数据
  DiaperChartData getDiaperData(
    List<dynamic> records,
    TimeRange range,
  ) {
    final strategy = DiaperChartDataStrategy();
    return strategy.getChartData(records, range);
  }

  /// 获取成长图表数据
  GrowthChartData getGrowthData(
    List<dynamic> records,
    TimeRange range,
  ) {
    final strategy = GrowthChartDataStrategy();
    return strategy.getChartData(records, range);
  }

  /// 获取辅食图表数据
  SolidFoodChartData getSolidFoodData(
    List<dynamic> records,
    TimeRange range,
  ) {
    final strategy = SolidFoodChartDataStrategy();
    return strategy.getChartData(records, range);
  }
}

/// 图表数据上下文
/// 采用策略模式：持有策略引用，根据图表类型使用对应策略处理数据
class ChartDataContext {
  final ChartDataStrategy _strategy;

  ChartDataContext(this._strategy);

  /// 设置策略
  set strategy(ChartDataStrategy strategy) {
    // 策略不可动态更改，创建新的上下文
    throw UnsupportedError('Strategy cannot be changed after creation');
  }

  /// 获取图表数据
  dynamic getChartData(List<dynamic> records, TimeRange range) {
    return _strategy.getChartData(records, range);
  }

  /// 获取图表标题
  String get title => _strategy.title;

  /// 获取图表类型
  ChartType get type => _strategy.type;
}
