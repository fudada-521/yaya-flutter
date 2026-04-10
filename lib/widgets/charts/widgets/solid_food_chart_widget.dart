import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../chart_type.dart';
import '../chart_theme.dart';
import '../chart_data_helper.dart';
import '../base_chart_widget.dart';
import '../../../providers/records_provider.dart';

/// 辅食统计图表组件
/// 展示各质地类型次数的柱状图
class SolidFoodChartWidget extends BaseChartWidget {
  const SolidFoodChartWidget({
    super.key,
    required super.timeRange,
  }) : super(chartType: ChartType.solidFood);

  @override
  Widget buildChart(BuildContext context, ChartThemeConfig theme, TimeRange timeRange) {
    return Consumer<RecordsProvider>(
      builder: (context, provider, child) {
        final records = provider.solidFoodRecords;
        final chartData = _processData(records, timeRange);

        return Column(
          children: [
            // 图表
            Expanded(
              child: chartData.textureCounts.isEmpty
                  ? _buildEmptyState()
                  : _buildBarChart(chartData, theme),
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
          Icon(Icons.set_meal, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text('暂无辅食记录', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 4),
          Text('切换时间范围查看更多数据', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBarChart(_SolidFoodData chartData, ChartThemeConfig theme) {
    final maxCount = chartData.maxCount > 0 ? chartData.maxCount.toDouble() : 1;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxCount * 1.3,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => theme.primaryColor.withAlpha((0.8 * 255).round()),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final texture = chartData.textureCounts.keys.elementAt(group.x.toInt());
              final count = chartData.textureCounts[texture]!;
              final emoji = _getTextureEmoji(texture);
              return BarTooltipItem(
                '$emoji ${_getTextureName(texture)}\n$count 次',
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
                if (value.toInt() >= chartData.textureCounts.length) {
                  return const SizedBox();
                }
                final texture = chartData.textureCounts.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(_getTextureEmoji(texture), style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(height: 2),
                      Flexible(
                        child: Text(
                          _getTextureName(texture),
                          style: TextStyle(color: Colors.grey[500], fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
              reservedSize: 45,
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
              reservedSize: 25,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxCount / 3,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData.textureCounts.entries.toList().asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.lightColor],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 28,
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

  _SolidFoodData _processData(List<dynamic> records, TimeRange range) {
    // 1. 根据时间范围过滤
    final filteredRecords = ChartDataHelper.filterByTimeRange(
      records,
      range,
      (record) => record.mealTime,
    );

    // 2. 统计各质地类型次数
    final Map<String, int> textureCounts = {};
    for (var record in filteredRecords) {
      final texture = record.texture;
      textureCounts[texture] = (textureCounts[texture] ?? 0) + 1;
    }

    // 3. 找出使用最多的质地
    String mostUsedTexture = 'puree';
    int maxCount = 0;
    textureCounts.forEach((texture, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsedTexture = texture;
      }
    });

    return _SolidFoodData(
      textureCounts: textureCounts,
      totalCount: filteredRecords.length,
      mostUsedTexture: mostUsedTexture,
    );
  }

  String _getTextureName(String texture) {
    switch (texture) {
      case 'puree':
        return '泥糊';
      case 'soft':
        return '软烂';
      case 'piece':
        return '小块';
      case 'solid':
        return '固体';
      default:
        return texture;
    }
  }

  String _getTextureEmoji(String texture) {
    switch (texture) {
      case 'puree':
        return '🫧';
      case 'soft':
        return '🥣';
      case 'piece':
        return '🍖';
      case 'solid':
        return '🍽️';
      default:
        return '🍽️';
    }
  }
}

class _SolidFoodData {
  final Map<String, int> textureCounts;
  final int totalCount;
  final String mostUsedTexture;

  _SolidFoodData({
    required this.textureCounts,
    required this.totalCount,
    required this.mostUsedTexture,
  });

  int get maxCount {
    if (textureCounts.isEmpty) return 0;
    return textureCounts.values.reduce((a, b) => a > b ? a : b);
  }
}
