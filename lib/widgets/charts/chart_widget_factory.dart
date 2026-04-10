import 'package:flutter/material.dart';
import 'chart_type.dart';
import 'widgets/feeding_chart_widget.dart';
import 'widgets/sleep_chart_widget.dart';
import 'widgets/diaper_pie_chart_widget.dart';
import 'widgets/growth_chart_widget.dart';
import 'widgets/solid_food_chart_widget.dart';

/// 图表组件工厂类
/// 采用工厂模式：根据图表类型创建对应的图表组件
class ChartWidgetFactory {
  /// 创建图表组件
  /// [type] 图表类型
  /// [timeRange] 时间范围
  /// 返回对应类型的图表组件
  static Widget createChart({
    required ChartType type,
    required TimeRange timeRange,
  }) {
    switch (type) {
      case ChartType.feeding:
        return FeedingChartWidget(timeRange: timeRange);
      case ChartType.sleep:
        return SleepChartWidget(timeRange: timeRange);
      case ChartType.diaper:
        return DiaperPieChartWidget(timeRange: timeRange);
      case ChartType.growth:
        return GrowthChartWidget(timeRange: timeRange);
      case ChartType.solidFood:
        return SolidFoodChartWidget(timeRange: timeRange);
    }
  }

  /// 创建所有图表列表
  static List<Widget> createAllCharts(TimeRange timeRange) {
    return [
      FeedingChartWidget(timeRange: timeRange),
      SleepChartWidget(timeRange: timeRange),
      DiaperPieChartWidget(timeRange: timeRange),
      SolidFoodChartWidget(timeRange: timeRange),
      GrowthChartWidget(timeRange: timeRange),
    ];
  }

  /// 获取图表类型对应的标题
  static String getChartTitle(ChartType type) {
    switch (type) {
      case ChartType.feeding:
        return '喂养趋势';
      case ChartType.sleep:
        return '睡眠趋势';
      case ChartType.diaper:
        return '尿布分布';
      case ChartType.growth:
        return '成长曲线';
      case ChartType.solidFood:
        return '辅食统计';
    }
  }

  /// 获取图表类型对应的图标
  static IconData getChartIcon(ChartType type) {
    switch (type) {
      case ChartType.feeding:
        return Icons.restaurant;
      case ChartType.sleep:
        return Icons.bedtime;
      case ChartType.diaper:
        return Icons.baby_changing_station;
      case ChartType.growth:
        return Icons.trending_up;
      case ChartType.solidFood:
        return Icons.set_meal;
    }
  }
}
