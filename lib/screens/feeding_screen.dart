import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/feeding_record.dart';
import 'record_bottom_sheet_helper.dart';
import '../widgets/records/records.dart';
import '../widgets/empty_baby_card.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
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
          final feedingRecords = recordsProvider.feedingRecords;

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildTodayStatsCard(recordsProvider),
              _buildQuickRecordArea(context, currentBaby?.id),
              Expanded(
                child: _buildRecordsList(feedingRecords),
              ),
            ],
          );
        },
      ),
      floatingActionButton: RecordFab(
        primaryColor: const Color(0xFFFF8A65),
        secondaryColor: const Color(0xFFFFAB91),
        onPressed: () => RecordBottomSheetHelper.showAddFeedingRecord(context),
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
              color: const Color(0xFFFF8A65).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: Color(0xFFFF8A65), size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            '喂养记录',
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
    final todayFeeding = recordsProvider.feedingRecords
        .where((r) => r.feedTime.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();
    final todayStats = recordsProvider.getTodayStats();

    return RecordStatsCard(
      title: '今日喂养统计',
      icon: Icons.analytics_outlined,
      iconColor: Colors.orange[400]!,
      stats: [
        StatItem(label: '次数', value: '${todayFeeding.length}次', color: const Color(0xFFFF8A65)),
        StatItem(label: '总量', value: '${todayStats['totalFeedingAmount'].toStringAsFixed(1)}ml', color: const Color(0xFF64B5F6)),
        StatItem(label: '平均间隔', value: _calculateAverageInterval(todayFeeding), color: const Color(0xFF81C784)),
      ],
    );
  }

  String _calculateAverageInterval(List<FeedingRecord> records) {
    if (records.length < 2) return '暂无数据';
    records.sort((a, b) => b.feedTime.compareTo(a.feedTime));
    final intervals = <Duration>[];
    for (int i = 0; i < records.length - 1; i++) {
      intervals.add(records[i].feedTime.difference(records[i + 1].feedTime));
    }
    final averageMinutes = intervals.fold<int>(0, (sum, interval) => sum + interval.inMinutes) ~/ intervals.length;
    if (averageMinutes < 60) {
      return '$averageMinutes分钟';
    } else {
      final hours = averageMinutes ~/ 60;
      final minutes = averageMinutes % 60;
      return '${hours}h${minutes}m';
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
      primaryColor: const Color(0xFFFF8A65),
      buttons: [
        QuickRecordButton(
          label: '母乳亲喂',
          icon: Icons.favorite,
          color: const Color(0xFFF48FB1),
          onTap: () => _quickRecord('breast', babyId),
        ),
        QuickRecordButton(
          label: '母乳瓶喂',
          icon: Icons.local_drink,
          color: const Color(0xFFE91E63),
          onTap: () => _quickRecord('pumped', babyId),
        ),
        QuickRecordButton(
          label: '奶粉',
          icon: Icons.local_dining,
          color: const Color(0xFFFF8A65),
          onTap: () => _quickRecord('bottle', babyId),
        ),
        QuickRecordButton(
          label: '辅食',
          icon: Icons.restaurant,
          color: const Color(0xFF81C784),
          onTap: () => _quickRecord('solid', babyId),
        ),
      ],
    );
  }

  Widget _buildRecordsList(List<FeedingRecord> records) {
    if (records.isEmpty) {
      return const RecordsEmptyState(
        icon: Icons.restaurant_menu,
        title: '暂无喂养记录',
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

  Widget _buildRecordCard(FeedingRecord record) {
    final typeColor = record.type == 'breast'
        ? const Color(0xFFF48FB1)
        : record.type == 'pumped'
            ? const Color(0xFFE91E63)
            : record.type == 'bottle'
                ? const Color(0xFFFF8A65)
                : const Color(0xFF81C784);

    final title = record.type == 'breast'
        ? '${record.typeDisplayName}${record.durationDisplayName.isNotEmpty ? ' ${record.durationDisplayName}' : ''}'
        : '${record.typeDisplayName}${record.amount != null ? ' ${record.amount}ml' : ''}';

    final time = record.type == 'breast'
        ? '${_formatTime(record.feedTime)}${record.method != null ? ' | ${record.methodDisplayName}' : ''}'
        : _formatTime(record.feedTime);

    return RecordListCard(
      title: title,
      time: time,
      icon: Icons.restaurant,
      iconColor: typeColor,
      notes: record.notes,
      onTap: () => RecordBottomSheetHelper.showEditFeedingRecord(context, record),
      onEdit: () => RecordBottomSheetHelper.showEditFeedingRecord(context, record),
      onDelete: () => RecordBottomSheetHelper.showDeleteConfirm(
        context,
        title: '确认删除',
        message: '确定要删除这条喂养记录吗？',
        onConfirm: () => Provider.of<RecordsProvider>(context, listen: false).deleteFeedingRecord(record.id),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _quickRecord(String type, String babyId) {
    final record = FeedingRecord(
      babyId: babyId,
      feedTime: DateTime.now(),
      type: type,
    );
    Provider.of<RecordsProvider>(context, listen: false).addFeedingRecord(record);
  }
}
