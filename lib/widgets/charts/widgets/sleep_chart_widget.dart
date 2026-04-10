import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../chart_type.dart';
import '../chart_theme.dart';
import '../chart_data_helper.dart';
import '../base_chart_widget.dart';
import '../../../providers/records_provider.dart';

/// 睡眠趋势图表组件
/// 展示每日睡眠时长的折线图
class SleepChartWidget extends BaseChartWidget {
  const SleepChartWidget({
    super.key,
    required super.timeRange,
  }) : super(chartType: ChartType.sleep);

  @override
  Widget buildChart(BuildContext context, ChartThemeConfig theme, TimeRange timeRange) {
    return Consumer<RecordsProvider>(
      builder: (context, provider, child) {
        final records = provider.sleepRecords;
        final chartData = _processData(records, timeRange);

        return Column(
          children: [
            // 图表
            Expanded(
              child: chartData.dailySleeps.isEmpty
                  ? _buildEmptyState()
                  : _buildLineChart(chartData, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bedtime, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text('暂无睡眠记录', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 4),
          Text('切换时间范围查看更多数据', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLineChart(_SleepData chartData, ChartThemeConfig theme) {
    final lightColorWithAlpha = theme.lightColor.withAlpha(255);
    final lightColorTransparent = theme.lightColor.withAlpha(0);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: chartData.maxDuration > 0 ? chartData.maxDuration * 1.2 : 24,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => theme.primaryColor.withAlpha((0.8 * 255).round()),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${chartData.dailySleeps[spot.x.toInt()].dateLabel}\n${spot.y.toStringAsFixed(1)}小时',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= chartData.dailySleeps.length || value.toInt() < 0) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    chartData.dailySleeps[value.toInt()].dateLabel,
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
                  '${value.toInt()}h',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartData.maxDuration / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: chartData.dailySleeps.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.duration);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.3,
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.lightColor],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: theme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [lightColorWithAlpha.withAlpha(77), lightColorTransparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _SleepData _processData(List<dynamic> records, TimeRange range) {
    // 1. 根据时间范围过滤
    final filteredRecords = ChartDataHelper.filterByTimeRange(
      records,
      range,
      (record) => record.startTime,
    );

    // 2. 按日期分组
    final grouped = ChartDataHelper.groupByDate(
      filteredRecords.cast(),
      (record) => record.startTime,
    );

    // 3. 转换为每日数据
    final dailySleeps = <_DailySleep>[];
    double maxDuration = 0;
    double totalHours = 0;

    final sortedKeys = ChartDataHelper.getSortedDateKeys(grouped);
    for (var dateKey in sortedKeys) {
      final dayRecords = grouped[dateKey]!;
      double dayDuration = 0;
      for (var record in dayRecords) {
        if (record.endTime != null) {
          final duration = record.endTime!.difference(record.startTime).inMinutes / 60.0;
          dayDuration += duration;
        }
      }
      dailySleeps.add(_DailySleep(
        date: ChartDataHelper.parseDate(dateKey),
        duration: dayDuration,
      ));
      if (dayDuration > maxDuration) maxDuration = dayDuration;
      totalHours += dayDuration;
    }

    return _SleepData(
      dailySleeps: dailySleeps,
      maxDuration: maxDuration > 0 ? maxDuration : 16,
      totalHours: totalHours,
    );
  }
}

class _SleepData {
  final List<_DailySleep> dailySleeps;
  final double maxDuration;
  final double totalHours;

  _SleepData({
    required this.dailySleeps,
    required this.maxDuration,
    required this.totalHours,
  });

  double get avgHours => dailySleeps.isNotEmpty ? totalHours / dailySleeps.length : 0;
}

class _DailySleep {
  final DateTime date;
  final double duration;

  _DailySleep({required this.date, required this.duration});

  String get dateLabel => '${date.month}/${date.day}';
}
