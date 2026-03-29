import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/growth_record.dart';
import 'record_bottom_sheet_helper.dart';
import '../widgets/records/records.dart';
import '../widgets/empty_baby_card.dart';

/// 成长记录页面
///
/// 记录宝宝的身高（cm）、体重（kg）和头围（cm）。
/// 支持身高、体重、头围三种快速单独记录。
/// 显示最新成长数据和成长记录列表。
class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
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
          final growthRecords = recordsProvider.growthRecords;

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildLatestStatsCard(recordsProvider),
              _buildQuickRecordArea(context, currentBaby?.id),
              Expanded(
                child: _buildRecordsList(growthRecords),
              ),
            ],
          );
        },
      ),
      floatingActionButton: RecordFab(
        primaryColor: const Color(0xFFBA68C8),
        secondaryColor: const Color(0xFFCE93D8),
        onPressed: () => RecordBottomSheetHelper.showAddGrowthRecord(context),
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
              color: const Color(0xFFBA68C8).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.trending_up, color: Color(0xFFBA68C8), size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            '成长记录',
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

  Widget _buildLatestStatsCard(RecordsProvider recordsProvider) {
    final growthRecords = recordsProvider.growthRecords;
    final latestRecord = growthRecords.isNotEmpty ? growthRecords.first : null;

    return RecordStatsCard(
      title: latestRecord != null ? '最新记录' : '今日成长记录',
      icon: Icons.analytics_outlined,
      iconColor: Colors.purple[400]!,
      stats: latestRecord != null
          ? [
              if (latestRecord.height != null)
                StatItem(label: '身高', value: '${latestRecord.height}cm', color: const Color(0xFF64B5F6)),
              if (latestRecord.weight != null)
                StatItem(label: '体重', value: '${latestRecord.weight}kg', color: const Color(0xFFBA68C8)),
              if (latestRecord.headCircumference != null)
                StatItem(label: '头围', value: '${latestRecord.headCircumference}cm', color: const Color(0xFFFF8A65)),
            ]
          : [StatItem(label: '暂无记录', value: '--', color: Colors.grey[400]!)],
    );
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
      primaryColor: const Color(0xFFBA68C8),
      buttons: [
        QuickRecordButton(
          label: '量身高',
          icon: Icons.straighten,
          color: const Color(0xFF64B5F6),
          onTap: () => RecordBottomSheetHelper.showQuickHeightRecord(context),
        ),
        QuickRecordButton(
          label: '称体重',
          icon: Icons.scale,
          color: const Color(0xFFBA68C8),
          onTap: () => RecordBottomSheetHelper.showQuickWeightRecord(context),
        ),
        QuickRecordButton(
          label: '量头围',
          icon: Icons.circle_outlined,
          color: const Color(0xFFFF8A65),
          onTap: () => RecordBottomSheetHelper.showQuickHeadCircumferenceRecord(context),
        ),
      ],
    );
  }

  Widget _buildRecordsList(List<GrowthRecord> records) {
    if (records.isEmpty) {
      return const RecordsEmptyState(
        icon: Icons.trending_up,
        title: '暂无成长记录',
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

  Widget _buildRecordCard(GrowthRecord record) {
    return RecordListCard(
      title: _formatDate(record.recordDate),
      time: '记录时间: ${_formatTime(record.createdAt)}',
      icon: Icons.child_care,
      iconColor: const Color(0xFFBA68C8),
      notes: record.notes,
      onTap: () => RecordBottomSheetHelper.showEditGrowthRecord(context, record),
      onEdit: () => RecordBottomSheetHelper.showEditGrowthRecord(context, record),
      onDelete: () => RecordBottomSheetHelper.showDeleteConfirm(
        context,
        title: '确认删除',
        message: '确定要删除这条成长记录吗？',
        onConfirm: () => Provider.of<RecordsProvider>(context, listen: false).deleteGrowthRecord(record.id),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
