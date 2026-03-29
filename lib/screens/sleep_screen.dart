import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/sleep_record.dart';
import 'record_bottom_sheet_helper.dart';
import '../widgets/records/records.dart';
import '../widgets/empty_baby_card.dart';

/// 睡眠记录页面
///
/// 记录宝宝的睡眠时间、结束时间（可选）和睡眠质量评分（1-5分）。
/// 支持午睡和夜间睡眠两种快速记录。
/// 显示今日睡眠统计和睡眠记录列表。
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecordsProvider>(context, listen: false).loadAllRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Consumer2<RecordsProvider, BabyProvider>(
        builder: (context, recordsProvider, babyProvider, child) {
          if (recordsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentBaby = babyProvider.currentBaby;
          final sleepRecords = recordsProvider.sleepRecords;

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildTodayStatsCard(recordsProvider),
              _buildQuickRecordArea(context, currentBaby?.id),
              Expanded(
                child: _buildRecordsList(sleepRecords),
              ),
            ],
          );
        },
      ),
      floatingActionButton: RecordFab(
        primaryColor: const Color(0xFF64B5F6),
        secondaryColor: const Color(0xFF90CAF9),
        onPressed: () => RecordBottomSheetHelper.showAddSleepRecord(context),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF64B5F6).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.bedtime, color: Color(0xFF64B5F6), size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            '睡眠记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.grey[600]),
          onPressed: () {
            Provider.of<RecordsProvider>(context, listen: false).loadAllRecords();
          },
        ),
      ],
    );
  }

  Widget _buildTodayStatsCard(RecordsProvider recordsProvider) {
    final todaySleep = recordsProvider.sleepRecords
        .where((r) => r.startTime.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    final totalDuration = todaySleep.fold<Duration>(
      Duration.zero,
      (sum, r) => sum + (r.duration ?? Duration.zero),
    );

    return RecordStatsCard(
      title: '今日睡眠统计',
      icon: Icons.analytics_outlined,
      iconColor: Colors.blue[400]!,
      stats: [
        StatItem(label: '次数', value: '${todaySleep.length}次', color: const Color(0xFF64B5F6)),
        StatItem(label: '总时长', value: _formatDuration(totalDuration), color: const Color(0xFF81C784)),
        StatItem(label: '平均质量', value: _calculateAverageQuality(todaySleep), color: const Color(0xFFBA68C8)),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) return '$minutes分钟';
    return '${hours}h${minutes}m';
  }

  String _calculateAverageQuality(List<SleepRecord> records) {
    if (records.isEmpty) return '暂无数据';
    final average = records.fold<int>(0, (sum, r) => sum + (r.quality ?? 0)) ~/ records.length;
    switch (average) {
      case 1: return '很差';
      case 2: return '较差';
      case 3: return '一般';
      case 4: return '良好';
      case 5: return '优秀';
      default: return '$average分';
    }
  }

  Widget _buildQuickRecordArea(BuildContext context, String? babyId) {
    if (babyId == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: EmptyBabyCard(
          title: '还没有添加宝宝信息哦~',
          subtitle: '点击下方按钮添加宝宝档案',
          buttonText: '添加宝宝信息',
          onButtonPressed: () => RecordBottomSheetHelper.showAddBaby(context),
        ),
      );
    }

    return QuickRecordArea(
      primaryColor: const Color(0xFF64B5F6),
      buttons: [
        QuickRecordButton(
          label: '午睡',
          icon: Icons.wb_sunny,
          color: const Color(0xFFFFB74D),
          onTap: () => _quickRecord(babyId),
        ),
        QuickRecordButton(
          label: '夜间',
          icon: Icons.nightlight_round,
          color: const Color(0xFF64B5F6),
          onTap: () => _quickRecord(babyId),
        ),
      ],
    );
  }

  Widget _buildRecordsList(List<SleepRecord> records) {
    if (records.isEmpty) {
      return const RecordsEmptyState(
        icon: Icons.bedtime_outlined,
        title: '暂无睡眠记录',
        subtitle: '点击右下角按钮添加记录',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(SleepRecord record) {
    final isNightSleep = record.type == '夜间';
    final typeColor = isNightSleep ? const Color(0xFF64B5F6) : const Color(0xFFFFB74D);

    return RecordListCard(
      title: '${record.type} ${record.durationString ?? '未结束'}',
      time: '${_formatTime(record.startTime)}${record.endTime != null ? ' - ${_formatTime(record.endTime!)}' : ''}',
      icon: Icons.nightlight,
      iconColor: typeColor,
      notes: record.notes,
      onTap: () => RecordBottomSheetHelper.showEditSleepRecord(context, record),
      onEdit: () => RecordBottomSheetHelper.showEditSleepRecord(context, record),
      onDelete: () => RecordBottomSheetHelper.showDeleteConfirm(
        context,
        title: '确认删除',
        message: '确定要删除这条睡眠记录吗？',
        onConfirm: () => Provider.of<RecordsProvider>(context, listen: false).deleteSleepRecord(record.id),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _quickRecord(String babyId) {
    final record = SleepRecord(
      babyId: babyId,
      startTime: DateTime.now(),
    );
    Provider.of<RecordsProvider>(context, listen: false).addSleepRecord(record);
  }
}
