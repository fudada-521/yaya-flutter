import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../chart_type.dart';
import '../chart_theme.dart';
import '../chart_data_helper.dart';
import '../base_chart_widget.dart';
import '../../../providers/records_provider.dart';

/// 成长曲线图表组件
/// 展示身高和体重双线图
class GrowthChartWidget extends BaseChartWidget {
  const GrowthChartWidget({
    super.key,
    required super.timeRange,
  }) : super(chartType: ChartType.growth);

  @override
  Widget buildChart(BuildContext context, ChartThemeConfig theme, TimeRange timeRange) {
    return Consumer<RecordsProvider>(
      builder: (context, provider, child) {
        final records = provider.growthRecords;
        final chartData = _processData(records, timeRange);

        return Column(
          children: [
            // 图表
            Expanded(
              child: (chartData.heightPoints.isEmpty && chartData.weightPoints.isEmpty && chartData.headCircumferencePoints.isEmpty)
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
          Icon(Icons.trending_up, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text('暂无成长记录', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 4),
          Text('切换时间范围查看更多数据', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLineChart(_GrowthData chartData, ChartThemeConfig theme) {
    return Column(
      children: [
        // 图例
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('身高', const Color(0xFF9C27B0)),
            const SizedBox(width: 20),
            _buildLegendItem('体重', const Color(0xFF2196F3)),
            const SizedBox(width: 20),
            _buildLegendItem('头围', const Color(0xFFFF7043)),
          ],
        ),
        const SizedBox(height: 8),
        // 图表
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.black87,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      String label;
                      Color color;
                      if (spot.barIndex == 0) {
                        label = "身高";
                        color = const Color(0xFF9C27B0);
                      } else if (spot.barIndex == 1) {
                        label = "体重";
                        color = const Color(0xFF2196F3);
                      } else {
                        label = "头围";
                        color = const Color(0xFFFF7043);
                      }
                      return LineTooltipItem(
                        '$label: ${spot.y.toStringAsFixed(1)}${spot.barIndex == 1 ? "kg" : "cm"}',
                        TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
                      final index = value.toInt();
                      if (index < 0 || index >= chartData.labels.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          chartData.labels[index],
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
                    reservedSize: 30,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // 身高线
                if (chartData.heightPoints.isNotEmpty)
                  LineChartBarData(
                    spots: chartData.heightPoints,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF9C27B0),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF9C27B0),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color.fromRGBO(156, 39, 176, 0.1),
                    ),
                  ),
                // 体重线
                if (chartData.weightPoints.isNotEmpty)
                  LineChartBarData(
                    spots: chartData.weightPoints,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF2196F3),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF2196F3),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color.fromRGBO(33, 150, 243, 0.1),
                    ),
                  ),
                // 头围线
                if (chartData.headCircumferencePoints.isNotEmpty)
                  LineChartBarData(
                    spots: chartData.headCircumferencePoints,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFFFF7043),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFFFF7043),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color.fromRGBO(255, 112, 67, 0.1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  _GrowthData _processData(List<dynamic> records, TimeRange range) {
    // 1. 根据时间范围过滤
    final filteredRecords = ChartDataHelper.filterByTimeRange(
      records,
      range,
      (record) => record.recordDate,
    );

    if (filteredRecords.isEmpty) {
      return _GrowthData(heightPoints: [], weightPoints: [], headCircumferencePoints: [], labels: [], totalCount: 0);
    }

    // 2. 按日期排序
    final sortedRecords = List<dynamic>.from(filteredRecords)
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

    final heightPoints = <FlSpot>[];
    final weightPoints = <FlSpot>[];
    final headCircumferencePoints = <FlSpot>[];
    final labels = <String>[];

    for (var i = 0; i < sortedRecords.length; i++) {
      final record = sortedRecords[i];
      labels.add(ChartDataHelper.formatDateLabel(record.recordDate));

      if (record.height != null && record.height! > 0) {
        heightPoints.add(FlSpot(i.toDouble(), record.height!));
      }
      if (record.weight != null && record.weight! > 0) {
        weightPoints.add(FlSpot(i.toDouble(), record.weight! * 5));
      }
      if (record.headCircumference != null && record.headCircumference! > 0) {
        // 头围约30-60cm，缩放到50-80范围显示
        headCircumferencePoints.add(FlSpot(i.toDouble(), record.headCircumference! + 20));
      }
    }

    return _GrowthData(
      heightPoints: heightPoints,
      weightPoints: weightPoints,
      headCircumferencePoints: headCircumferencePoints,
      labels: labels,
      totalCount: sortedRecords.length,
    );
  }
}

class _GrowthData {
  final List<FlSpot> heightPoints;
  final List<FlSpot> weightPoints;
  final List<FlSpot> headCircumferencePoints;
  final List<String> labels;
  final int totalCount;

  _GrowthData({
    required this.heightPoints,
    required this.weightPoints,
    required this.headCircumferencePoints,
    required this.labels,
    required this.totalCount,
  });

  double? get latestHeight => heightPoints.isNotEmpty ? heightPoints.last.y : null;
  double? get latestWeight => weightPoints.isNotEmpty ? weightPoints.last.y / 5 : null;
  double? get latestHeadCircumference => headCircumferencePoints.isNotEmpty ? headCircumferencePoints.last.y - 20 : null;
}
