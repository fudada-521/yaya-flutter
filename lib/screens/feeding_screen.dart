import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/feeding_record.dart';
import 'package:intl/intl.dart';
import 'record_bottom_sheet_helper.dart';
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
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
      ),
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
              _buildTodayStatsCard(recordsProvider, currentBaby?.id),
              _buildQuickRecordArea(context, currentBaby?.id),
              Expanded(
                child: _buildRecordsList(feedingRecords),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF8A65), const Color(0xFFFFAB91)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => RecordBottomSheetHelper.showAddFeedingRecord(context),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStatsCard(RecordsProvider recordsProvider, String? babyId) {
    final todayFeeding = recordsProvider.feedingRecords
        .where((r) => r.feedTime.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();
    final todayStats = recordsProvider.getTodayStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                child: Icon(Icons.analytics_outlined, color: Colors.orange[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '今日喂养统计',
                style: TextStyle(
                  fontSize: 16,
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
              _buildStatItem('次数', '${todayFeeding.length}次', const Color(0xFFFF8A65)),
              _buildStatItem('总量', '${todayStats['totalFeedingAmount'].toStringAsFixed(1)}ml', const Color(0xFF64B5F6)),
              _buildStatItem('平均间隔', _calculateAverageInterval(todayFeeding), const Color(0xFF81C784)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
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
      return _buildNoBabyCard(context);
    }

    return Container(
      margin: const EdgeInsets.all(16),
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
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt, color: Colors.pink[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '快速记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickButton('母乳亲喂', Icons.favorite, const Color(0xFFF48FB1), () => _quickRecord('breast', babyId)),
              _buildQuickButton('母乳瓶喂', Icons.local_drink, const Color(0xFFE91E63), () => _quickRecord('pumped', babyId)),
              _buildQuickButton('奶粉', Icons.local_dining, const Color(0xFFFF8A65), () => _quickRecord('bottle', babyId)),
              _buildQuickButton('辅食', Icons.restaurant, const Color(0xFF81C784), () => _quickRecord('solid', babyId)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoBabyCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: EmptyBabyCard(
        title: '还没有添加宝宝信息哦~',
        subtitle: '点击下方按钮添加宝宝档案',
        buttonText: '添加宝宝信息',
        onButtonPressed: () => Navigator.pushNamed(context, '/baby-profile'),
      ),
    );
  }

  Widget _buildQuickButton(String label, IconData icon, Color color, VoidCallback onTap) {
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
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRecordsList(List<FeedingRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('暂无喂养记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text('点击右下角按钮添加记录', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => RecordBottomSheetHelper.showEditFeedingRecord(context, record),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.restaurant, color: typeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.type == 'breast'
                            ? '${record.typeDisplayName}${record.durationDisplayName.isNotEmpty ? ' ${record.durationDisplayName}' : ''}'
                            : '${record.typeDisplayName}${record.amount != null ? ' ${record.amount}ml' : ''}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.type == 'breast'
                            ? '${DateFormat('MM-dd HH:mm').format(record.feedTime)}${record.method != null ? ' | ${record.methodDisplayName}' : ''}'
                            : DateFormat('MM-dd HH:mm').format(record.feedTime),
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                      if (record.notes != null && record.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          record.notes!,
                          style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  onSelected: (value) {
                    if (value == 'edit') {
                      RecordBottomSheetHelper.showEditFeedingRecord(context, record);
                    } else if (value == 'delete') {
                      RecordBottomSheetHelper.showDeleteConfirm(
                        context,
                        title: '确认删除',
                        message: '确定要删除这条喂养记录吗？',
                        onConfirm: () => Provider.of<RecordsProvider>(context, listen: false).deleteFeedingRecord(record.id),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 10),
                          const Text('编辑', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                          const SizedBox(width: 10),
                          Text('删除', style: TextStyle(fontSize: 14, color: Colors.red[400])),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
