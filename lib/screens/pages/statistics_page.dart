import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/records_provider.dart';
import '../../widgets/charts/chart_type.dart';
import '../../widgets/charts/time_range_notifier.dart';
import '../../widgets/charts/widgets/feeding_chart_widget.dart';
import '../../widgets/charts/widgets/sleep_chart_widget.dart';
import '../../widgets/charts/widgets/diaper_pie_chart_widget.dart';
import '../../widgets/charts/widgets/growth_chart_widget.dart';
import '../../widgets/charts/widgets/solid_food_chart_widget.dart';

/// 统计分析页面
///
/// 采用观察者模式：页面监听时间范围变化，当用户切换时间范围时自动刷新图表数据
/// 使用工厂模式：通过 ChartWidgetFactory 创建各类图表组件
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // 时间范围通知器（观察者模式），默认今日
  final TimeRangeNotifier _timeRangeNotifier = TimeRangeNotifier(initialRange: TimeRange.today);

  @override
  void dispose() {
    _timeRangeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _timeRangeNotifier,
      child: ListenableBuilder(
        listenable: _timeRangeNotifier,
        builder: (context, _) {
          final currentRange = _timeRangeNotifier.currentRange;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 时间范围选择器（观察者模式）
                _buildTimeRangeSelector(),
                const SizedBox(height: 16),

                // 整体统计卡片
                _buildSummaryCard(currentRange),
                const SizedBox(height: 16),

                // 喂养趋势图
                FeedingChartWidget(timeRange: currentRange),
                const SizedBox(height: 16),

                // 睡眠趋势图
                SleepChartWidget(timeRange: currentRange),
                const SizedBox(height: 16),

                // 尿布分布图（单独一行）
                DiaperPieChartWidget(timeRange: currentRange),
                const SizedBox(height: 16),

                // 辅食统计（单独一行）
                SolidFoodChartWidget(timeRange: currentRange),
                const SizedBox(height: 16),

                // 成长曲线图
                GrowthChartWidget(timeRange: currentRange),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建整体统计卡片
  Widget _buildSummaryCard(TimeRange currentRange) {
    return Consumer<RecordsProvider>(
      builder: (context, provider, child) {
        final feedingRecords = provider.feedingRecords;
        final sleepRecords = provider.sleepRecords;
        final diaperRecords = provider.diaperRecords;
        final solidFoodRecords = provider.solidFoodRecords;

        // ========== 喂养统计 ==========
        int feedingCount = 0;
        int breastCount = 0;
        int bottleCount = 0;
        double totalAmount = 0;
        for (var record in feedingRecords) {
          if (_isInTimeRange(record.feedTime, currentRange)) {
            feedingCount++;
            if (record.type == 'breast') {
              breastCount++;
              totalAmount += record.duration != null ? record.duration! * 10.0 : 60.0;
            } else {
              bottleCount++;
              totalAmount += record.amount ?? 0;
            }
          }
        }

        // ========== 睡眠统计 ==========
        int sleepCount = 0;
        double totalSleepHours = 0;
        final sleepDaysSet = <String>{};
        for (var record in sleepRecords) {
          if (_isInTimeRange(record.startTime, currentRange)) {
            sleepCount++;
            sleepDaysSet.add(_getDateKey(record.startTime));
            if (record.endTime != null) {
              totalSleepHours += record.endTime!.difference(record.startTime).inMinutes / 60.0;
            }
          }
        }
        final sleepDays = sleepDaysSet.length;
        final avgSleepHours = sleepDays > 0 ? totalSleepHours / sleepDays : 0.0;

        // ========== 尿布统计 ==========
        int diaperCount = 0;
        int wetCount = 0;
        int dirtyCount = 0;
        for (var record in diaperRecords) {
          if (_isInTimeRange(record.changeTime, currentRange)) {
            diaperCount++;
            if (record.type == 'wet') {
              wetCount++;
            } else if (record.type == 'dirty') {
              dirtyCount++;
            } else if (record.type == 'mixed') {
              wetCount++;
              dirtyCount++;
            }
          }
        }

        // ========== 辅食统计 ==========
        int solidFoodCount = 0;
        for (var record in solidFoodRecords) {
          if (_isInTimeRange(record.mealTime, currentRange)) {
            solidFoodCount++;
          }
        }

        // ========== 计算每日平均 ==========
        int daysInRange = _getDaysInRange(currentRange);
        final avgFeedingPerDay = daysInRange > 0 ? feedingCount / daysInRange : 0.0;
        final avgAmountPerDay = daysInRange > 0 ? totalAmount / daysInRange : 0.0;
        final avgDiaperPerDay = daysInRange > 0 ? diaperCount / daysInRange : 0.0;
        final avgWetPerDay = daysInRange > 0 ? wetCount / daysInRange : 0.0;
        final avgDirtyPerDay = daysInRange > 0 ? dirtyCount / daysInRange : 0.0;
        final avgSolidFoodPerDay = daysInRange > 0 ? solidFoodCount / daysInRange : 0.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  Icon(Icons.insights, color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '整体统计',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      TimeRangeHelper.getDisplayName(currentRange),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ========== 四列统计 ==========
              Row(
                children: [
                  // 喂养
                  Expanded(
                    child: _buildStatColumn(
                      '🍼',
                      '$feedingCount',
                      '喂养',
                      '母乳$breastCount 瓶喂$bottleCount',
                      const Color(0xFFFF7043),
                    ),
                  ),
                  Container(width: 1, height: 50, color: const Color(0xFFEEEEEE)),
                  // 睡眠
                  Expanded(
                    child: _buildStatColumn(
                      '😴',
                      '$sleepCount',
                      '睡眠',
                      '${totalSleepHours.toStringAsFixed(1)}h',
                      const Color(0xFF42A5F5),
                    ),
                  ),
                  Container(width: 1, height: 50, color: const Color(0xFFEEEEEE)),
                  // 尿布
                  Expanded(
                    child: _buildStatColumn(
                      '🧷',
                      '$diaperCount',
                      '尿布',
                      '小${avgWetPerDay.toStringAsFixed(0)} 大${avgDirtyPerDay.toStringAsFixed(0)}',
                      const Color(0xFF66BB6A),
                    ),
                  ),
                  Container(width: 1, height: 50, color: const Color(0xFFEEEEEE)),
                  // 辅食
                  Expanded(
                    child: _buildStatColumn(
                      '🥣',
                      '$solidFoodCount',
                      '辅食',
                      '日均${avgSolidFoodPerDay.toStringAsFixed(1)}次',
                      const Color(0xFFAB47BC),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ========== 底部详情 ==========
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem('总奶量', '${totalAmount.toStringAsFixed(0)} ml'),
                    _buildDetailItem('日均喂养', '${avgFeedingPerDay.toStringAsFixed(1)} 次'),
                    _buildDetailItem('日均奶量', '${avgAmountPerDay.toStringAsFixed(0)} ml'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建统计列
  Widget _buildStatColumn(String emoji, String value, String title, String sub, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 9,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 构建详情项
  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 获取时间范围内的天数
  int _getDaysInRange(TimeRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (range) {
      case TimeRange.today:
        return 1;
      case TimeRange.week:
        return 7;
      case TimeRange.month:
        return 30;
      case TimeRange.all:
        // 计算所有记录中最早日期到今天的天数
        return today.difference(DateTime(2020, 1, 1)).inDays;
    }
  }

  /// 判断时间是否在范围内
  bool _isInTimeRange(DateTime dateTime, TimeRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (range) {
      case TimeRange.today:
        final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
        return date.isAtSameMomentAs(today);
      case TimeRange.week:
        final weekAgo = today.subtract(const Duration(days: 7));
        return dateTime.isAfter(weekAgo);
      case TimeRange.month:
        final monthAgo = DateTime(today.year, today.month - 1, today.day);
        return dateTime.isAfter(monthAgo);
      case TimeRange.all:
        return true;
    }
  }

  /// 获取日期Key
  String _getDateKey(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  /// 构建时间范围选择器
  Widget _buildTimeRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '时间范围',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // 时间范围选项
          Row(
            mainAxisSize: MainAxisSize.min,
            children: TimeRange.values.map((range) {
              final isSelected = _timeRangeNotifier.currentRange == range;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => _timeRangeNotifier.setRange(range),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      TimeRangeHelper.getDisplayName(range),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
