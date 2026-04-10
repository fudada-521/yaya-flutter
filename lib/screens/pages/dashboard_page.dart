import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/baby_provider.dart';
import '../../providers/records_provider.dart';
import '../../models/feeding_record.dart';
import '../../models/sleep_record.dart';
import '../../models/diaper_record.dart';
import '../../models/growth_record.dart';
import '../../models/solid_food_record.dart';
import '../../widgets/empty_baby_card.dart';
import '../../widgets/records/timeline_widget.dart';
import '../record_bottom_sheet_helper.dart';

/// 仪表盘页面
///
/// 显示欢迎卡片（宝宝头像、姓名、出生天数）、
/// 今日统计（喂养次数、睡眠时长、尿布次数）、
/// 最近记录时间轴。
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 20),
          _buildTodaySummary(context),
          const SizedBox(height: 20),
          _buildRecentRecords(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Consumer<BabyProvider>(
      builder: (context, babyProvider, child) {
        final currentBaby = babyProvider.currentBaby;
        if (currentBaby == null) {
          return _buildEmptyBabyCard(context);
        }

        final babyColor = currentBaby.gender == 'male'
            ? const Color(0xFF64B5F6)
            : const Color(0xFFF48FB1);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [babyColor.withAlpha(200), babyColor.withAlpha(150)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(100),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withAlpha(50),
                  child: Text(
                    currentBaby.name[0],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '你好，${currentBaby.name}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '第${currentBaby.ageInDays}天',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.waving_hand,
                color: Colors.white.withAlpha(200),
                size: 32,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyBabyCard(BuildContext context) {
    return EmptyBabyCard(
      title: '还没有添加宝宝信息哦~',
      subtitle: '点击下方按钮添加宝宝档案',
      buttonText: '添加宝宝信息',
      onButtonPressed: () => RecordBottomSheetHelper.showAddBaby(context),
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    return Consumer<RecordsProvider>(
      builder: (context, recordsProvider, child) {
        final todayStats = recordsProvider.getTodayStats();
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final todaySolidFood = recordsProvider.solidFoodRecords
            .where((r) => r.mealTime.isAfter(todayStart))
            .toList();

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
                      Icons.today,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '喂养',
                    '${todayStats['feedingCount']}次',
                    const Color(0xFFFF8A65),
                    Icons.restaurant,
                  ),
                  _buildStatItem(
                    '睡眠',
                    '${todayStats['totalSleepDuration'].inHours}小时',
                    const Color(0xFF64B5F6),
                    Icons.bedtime,
                  ),
                  _buildStatItem(
                    '换尿布',
                    '${todayStats['diaperCount']}次',
                    const Color(0xFF81C784),
                    Icons.baby_changing_station,
                  ),
                  _buildStatItem(
                    '辅食',
                    '${todaySolidFood.length}次',
                    const Color(0xFFFFB74D),
                    Icons.blender,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildRecentRecords(BuildContext context) {
    return Consumer<RecordsProvider>(
      builder: (context, recordsProvider, child) {
        final recentRecords = recordsProvider.getRecentRecords(limit: 10);

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
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.history,
                      color: Colors.purple[400],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '最近记录',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TimelineWidget(
                records: recentRecords,
                onRecordTap: (record) => _onRecordTap(context, record),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onRecordTap(BuildContext context, dynamic record) {
    if (record is FeedingRecord) {
      RecordBottomSheetHelper.showEditFeedingRecord(context, record);
    } else if (record is SleepRecord) {
      RecordBottomSheetHelper.showEditSleepRecord(context, record);
    } else if (record is DiaperRecord) {
      RecordBottomSheetHelper.showEditDiaperRecord(context, record);
    } else if (record is GrowthRecord) {
      RecordBottomSheetHelper.showEditGrowthRecord(context, record);
    } else if (record is SolidFoodRecord) {
      RecordBottomSheetHelper.showEditSolidFoodRecord(context, record);
    }
  }
}
