import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../chart_type.dart';
import '../chart_theme.dart';
import '../chart_data_helper.dart';
import '../base_chart_widget.dart';
import '../../../providers/records_provider.dart';

/// 尿布分布图表组件
/// 展示尿布类型分布的饼图
class DiaperPieChartWidget extends BaseChartWidget {
  const DiaperPieChartWidget({
    super.key,
    required super.timeRange,
  }) : super(chartType: ChartType.diaper);

  @override
  Widget buildChart(BuildContext context, ChartThemeConfig theme, TimeRange timeRange) {
    return Consumer<RecordsProvider>(
      builder: (context, provider, child) {
        final records = provider.diaperRecords;
        final chartData = _processData(records, timeRange);

        return Column(
          children: [
            // 图表
            Expanded(
              child: chartData.totalCount == 0
                  ? _buildEmptyState()
                  : _buildPieChart(chartData, theme),
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
          Icon(Icons.baby_changing_station, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text('暂无尿布记录', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 4),
          Text('切换时间范围查看更多数据', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPieChart(_DiaperData chartData, ChartThemeConfig theme) {
    return Row(
      children: [
        // 饼图
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 35,
              sections: [
                if (chartData.wetCount > 0)
                  PieChartSectionData(
                    value: chartData.wetPercent * 100,
                    title: '${(chartData.wetPercent * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    color: const Color(0xFF4CAF50),
                    radius: 50,
                  ),
                if (chartData.dirtyCount > 0)
                  PieChartSectionData(
                    value: chartData.dirtyPercent * 100,
                    title: '${(chartData.dirtyPercent * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    color: const Color(0xFF8D6E63),
                    radius: 50,
                  ),
                if (chartData.mixedCount > 0)
                  PieChartSectionData(
                    value: chartData.mixedPercent * 100,
                    title: '${(chartData.mixedPercent * 100).toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    color: const Color(0xFFFFB74D),
                    radius: 50,
                  ),
              ],
            ),
          ),
        ),
        // 图例
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('小便', chartData.wetCount, const Color(0xFF4CAF50)),
              const SizedBox(height: 8),
              _buildLegendItem('大便', chartData.dirtyCount, const Color(0xFF8D6E63)),
              const SizedBox(height: 8),
              _buildLegendItem('混合', chartData.mixedCount, const Color(0xFFFFB74D)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $count',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  _DiaperData _processData(List<dynamic> records, TimeRange range) {
    // 1. 根据时间范围过滤
    final filteredRecords = ChartDataHelper.filterByTimeRange(
      records,
      range,
      (record) => record.changeTime,
    );

    // 2. 统计各类型数量
    int wetCount = 0;
    int dirtyCount = 0;
    int mixedCount = 0;

    for (var record in filteredRecords) {
      switch (record.type) {
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

    return _DiaperData(
      wetCount: wetCount,
      dirtyCount: dirtyCount,
      mixedCount: mixedCount,
    );
  }
}

class _DiaperData {
  final int wetCount;
  final int dirtyCount;
  final int mixedCount;

  _DiaperData({
    required this.wetCount,
    required this.dirtyCount,
    required this.mixedCount,
  });

  int get totalCount => wetCount + dirtyCount + mixedCount;

  double get wetPercent => totalCount > 0 ? wetCount / totalCount : 0;
  double get dirtyPercent => totalCount > 0 ? dirtyCount / totalCount : 0;
  double get mixedPercent => totalCount > 0 ? mixedCount / totalCount : 0;
}
