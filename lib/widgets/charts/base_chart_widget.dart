import 'package:flutter/material.dart';
import 'chart_type.dart';
import 'chart_theme.dart';

/// 图表组件基类
/// 采用模板方法模式：定义图表组件的共同骨架
/// 子类通过覆盖 buildChart() 方法提供具体的图表实现
abstract class BaseChartWidget extends StatefulWidget {
  final ChartType chartType;
  final TimeRange timeRange;

  const BaseChartWidget({
    super.key,
    required this.chartType,
    required this.timeRange,
  });

  /// 构建具体图表（子类必须实现此方法）
  Widget buildChart(BuildContext context, ChartThemeConfig theme, TimeRange timeRange);

  @override
  State<BaseChartWidget> createState() => _BaseChartWidgetState();
}

class _BaseChartWidgetState extends State<BaseChartWidget> {
  @override
  void didUpdateWidget(BaseChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当时间范围变化时刷新数据
    if (oldWidget.timeRange != widget.timeRange) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ChartTheme.getConfig(widget.chartType);

    return Container(
      decoration: ChartTheme.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          _buildHeader(theme),
          // 图表内容（无固定高度，由子类决定）
          _buildChartContent(theme),
        ],
      ),
    );
  }

  /// 构建标题栏（模板方法 - 共同实现）
  Widget _buildHeader(ChartThemeConfig theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: theme.gradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(theme.title, style: ChartTheme.titleStyle),
          const Spacer(),
          if (widget.timeRange == TimeRange.all)
            Text(
              '全部历史',
              style: ChartTheme.subtitleStyle,
            )
          else
            Text(
              TimeRangeHelper.getDisplayName(widget.timeRange),
              style: ChartTheme.subtitleStyle,
            ),
        ],
      ),
    );
  }

  /// 构建图表内容（模板方法 - 调用子类的 buildChart）
  Widget _buildChartContent(ChartThemeConfig theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 220,
        child: widget.buildChart(context, theme, widget.timeRange),
      ),
    );
  }
}

/// 简化的图表包装组件（用于不需要复杂状态管理的场景）
class SimpleChartWidget extends StatelessWidget {
  final ChartType chartType;
  final TimeRange timeRange;
  final Widget chartContent;

  const SimpleChartWidget({
    super.key,
    required this.chartType,
    required this.timeRange,
    required this.chartContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ChartTheme.getConfig(chartType);

    return Container(
      decoration: ChartTheme.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: theme.gradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(theme.title, style: ChartTheme.titleStyle),
                const Spacer(),
                Text(
                  TimeRangeHelper.getDisplayName(timeRange),
                  style: ChartTheme.subtitleStyle,
                ),
              ],
            ),
          ),
          // 图表内容
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: chartContent,
            ),
          ),
        ],
      ),
    );
  }
}
