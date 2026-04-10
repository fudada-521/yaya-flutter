import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../chart_type.dart';
import '../chart_theme.dart';
import '../chart_data_helper.dart';
import '../base_chart_widget.dart';
import '../../../providers/records_provider.dart';

/// 喂养趋势图表组件
/// 展示每日喂养量的柱状图
class FeedingChartWidget extends BaseChartWidget {
  const FeedingChartWidget({
    super.key,
    required super.timeRange,
  }) : super(chartType: ChartType.feeding);

  @override
  Widget buildChart(BuildContext context, ChartThemeConfig theme, TimeRange timeRange) {
    return Consumer<RecordsProvider>(
      builder: (context, provider, child) {
        final records = provider.feedingRecords;
        final chartData = _processData(records, timeRange);

        return Column(
          children: [
            // 图表
            Expanded(
              child: chartData.dailyFeedings.isEmpty
                  ? _buildEmptyState()
                  : _buildBarChart(chartData, theme),
            ),
          ],
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            '暂无喂养记录',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '切换时间范围查看更多数据',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 构建柱状图
  Widget _buildBarChart(_FeedingData chartData, ChartThemeConfig theme) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartData.maxAmount * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => theme.primaryColor.withAlpha((0.8 * 255).round()),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final feeding = chartData.dailyFeedings[group.x.toInt()];
              return BarTooltipItem(
                '${feeding.dateLabel}\n${feeding.amount.toStringAsFixed(0)}ml',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= chartData.dailyFeedings.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    chartData.dailyFeedings[value.toInt()].dateLabel,
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                );
              },
              reservedSize: 35,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartData.maxAmount / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData.dailyFeedings.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.amount,
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.lightColor],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 处理喂养记录数据
  _FeedingData _processData(List<dynamic> records, TimeRange range) {
    // 1. 根据时间范围过滤
    final filteredRecords = ChartDataHelper.filterByTimeRange(
      records,
      range,
      (record) => record.feedTime,
    );

    // 2. 按日期分组
    final grouped = ChartDataHelper.groupByDate(
      filteredRecords.cast(),
      (record) => record.feedTime,
    );

    // 3. 转换为每日数据
    final dailyFeedings = <_DailyFeeding>[];
    double maxAmount = 0;
    double totalAmount = 0;

    final sortedKeys = ChartDataHelper.getSortedDateKeys(grouped);
    for (var dateKey in sortedKeys) {
      final dayRecords = grouped[dateKey]!;
      double dayAmount = 0;
      for (var record in dayRecords) {
        // 母乳亲喂按每次60ml估算
        if (record.type == 'breast') {
          dayAmount += record.duration != null ? record.duration! * 10.0 : 60.0;
        } else {
          dayAmount += record.amount ?? 0;
        }
      }
      dailyFeedings.add(_DailyFeeding(
        date: ChartDataHelper.parseDate(dateKey),
        amount: dayAmount,
      ));
      if (dayAmount > maxAmount) maxAmount = dayAmount;
      totalAmount += dayAmount;
    }

    return _FeedingData(
      dailyFeedings: dailyFeedings,
      maxAmount: maxAmount > 0 ? maxAmount : 100,
      totalAmount: totalAmount,
      totalCount: filteredRecords.length,
    );
  }
}

class _FeedingData {
  final List<_DailyFeeding> dailyFeedings;
  final double maxAmount;
  final double totalAmount;
  final int totalCount;

  _FeedingData({
    required this.dailyFeedings,
    required this.maxAmount,
    required this.totalAmount,
    required this.totalCount,
  });
}

class _DailyFeeding {
  final DateTime date;
  final double amount;

  _DailyFeeding({required this.date, required this.amount});

  String get dateLabel => '${date.month}/${date.day}';
}
