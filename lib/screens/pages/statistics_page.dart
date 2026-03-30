import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/records_provider.dart';

/// 统计分析页面
///
/// 显示今日统计、趋势概览和详细统计数据，
/// 包括累计喂养次数、累计奶量、累计睡眠次数等。
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatisticsCard(context),
          const SizedBox(height: 16),
          _buildTrendOverview(context),
          const SizedBox(height: 16),
          _buildDetailedStats(context),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.orange[400],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '今日统计',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer<RecordsProvider>(
            builder: (context, recordsProvider, child) {
              final todayStats = recordsProvider.getTodayStats();
              return Column(
                children: [
                  _buildStatRow(
                    '今日喂养',
                    '${todayStats['feedingCount']}次',
                    const Color(0xFFFF8A65),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    '今日睡眠',
                    '${todayStats['totalSleepDuration'].inHours}小时',
                    const Color(0xFF64B5F6),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    '今日换尿布',
                    '${todayStats['diaperCount']}次',
                    const Color(0xFF81C784),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendOverview(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.timeline, color: Colors.blue[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '趋势概览',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrendItem(
                context,
                '喂养',
                Icons.restaurant,
                const Color(0xFFFF8A65),
                () {
                  Navigator.pushNamed(context, '/feeding');
                },
              ),
              _buildTrendItem(
                context,
                '睡眠',
                Icons.bedtime,
                const Color(0xFF64B5F6),
                () {
                  Navigator.pushNamed(context, '/sleep');
                },
              ),
              _buildTrendItem(
                context,
                '尿布',
                Icons.baby_changing_station,
                const Color(0xFF81C784),
                () {
                  Navigator.pushNamed(context, '/diaper');
                },
              ),
              _buildTrendItem(
                context,
                '成长',
                Icons.trending_up,
                const Color(0xFFBA68C8),
                () {
                  Navigator.pushNamed(context, '/growth');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.storage, color: Colors.green[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '详细统计',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Consumer<RecordsProvider>(
            builder: (context, recordsProvider, child) {
              final allRecords = recordsProvider.getRecentRecords(limit: 50);
              final feedingRecords = recordsProvider.feedingRecords;
              final totalFeeding = feedingRecords.length;
              final totalFeedingAmount = feedingRecords.fold<double>(
                0,
                (sum, r) => sum + (r.amount ?? 0),
              );
              final sleepRecords = recordsProvider.sleepRecords;
              final totalSleepDuration = sleepRecords.fold<Duration>(
                Duration.zero,
                (sum, r) => sum + (r.duration ?? Duration.zero),
              );
              final diaperRecords = recordsProvider.diaperRecords;
              final totalDiaper = diaperRecords.length;

              return Column(
                children: [
                  _buildDetailStat(
                    '累计喂养次数',
                    '$totalFeeding次',
                    const Color(0xFFFF8A65),
                  ),
                  if (totalFeedingAmount > 0) ...[
                    const SizedBox(height: 10),
                    _buildDetailStat(
                      '累计奶量',
                      '${totalFeedingAmount.toStringAsFixed(0)}ml',
                      const Color(0xFFFF8A65),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _buildDetailStat(
                    '累计睡眠次数',
                    '${sleepRecords.length}次',
                    const Color(0xFF64B5F6),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailStat(
                    '累计睡眠时长',
                    '${totalSleepDuration.inHours}小时',
                    const Color(0xFF64B5F6),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailStat(
                    '累计换尿布次数',
                    '$totalDiaper次',
                    const Color(0xFF81C784),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '数据基于最近${allRecords.length}条记录',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
