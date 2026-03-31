import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/solid_food_record.dart';
import 'record_bottom_sheet_helper.dart';
import '../widgets/records/records.dart';
import '../widgets/empty_baby_card.dart';

/// 辅食记录页面
///
/// 显示今日辅食统计、辅食记录列表。
/// 可通过底部悬浮按钮添加新记录。
class SolidFoodScreen extends StatefulWidget {
  const SolidFoodScreen({super.key});

  @override
  State<SolidFoodScreen> createState() => _SolidFoodScreenState();
}

class _SolidFoodScreenState extends State<SolidFoodScreen> {
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
          final solidFoodRecords = recordsProvider.solidFoodRecords;

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildTodayStatsCard(recordsProvider),
              if (currentBaby == null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyBabyCard(
                    title: '还没有添加宝宝信息哦~',
                    subtitle: '点击下方按钮添加宝宝档案',
                    buttonText: '添加宝宝信息',
                    onButtonPressed: () => RecordBottomSheetHelper.showAddBaby(context),
                  ),
                )
              else
                Expanded(
                  child: _buildRecordsList(solidFoodRecords),
                ),
            ],
          );
        },
      ),
      floatingActionButton: RecordFab(
        primaryColor: const Color(0xFFFFB74D),
        secondaryColor: const Color(0xFFFFCC80),
        onPressed: () => RecordBottomSheetHelper.showAddSolidFoodRecord(context),
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
              color: const Color(0xFFFFB74D).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.icecream, color: Color(0xFFFFB74D), size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            '辅食记录',
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
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayRecords = recordsProvider.solidFoodRecords
        .where((r) => r.mealTime.isAfter(todayStart))
        .toList();

    int totalAmount = 0;
    for (final record in todayRecords) {
      if (record.amount != null) {
        totalAmount += record.amount!.toInt();
      }
    }

    return RecordStatsCard(
      title: '今日辅食统计',
      icon: Icons.analytics_outlined,
      iconColor: Colors.orange[400]!,
      stats: [
        StatItem(label: '次数', value: '${todayRecords.length}次', color: const Color(0xFFFFB74D)),
        StatItem(label: '总量', value: '${totalAmount}g', color: const Color(0xFF64B5F6)),
      ],
    );
  }

  Widget _buildRecordsList(List<SolidFoodRecord> records) {
    if (records.isEmpty) {
      return const RecordsEmptyState(
        icon: Icons.icecream_outlined,
        title: '暂无辅食记录',
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

  Widget _buildRecordCard(SolidFoodRecord record) {
    final title = record.foodName != null && record.foodName!.isNotEmpty
        ? record.foodName!
        : '辅食';

    final notesParts = <String>[];
    if (record.amount != null) {
      notesParts.add('${record.amount!.toStringAsFixed(0)}g');
    }
    notesParts.add(record.textureDisplayName);
    if (record.ingredients != null && record.ingredients!.isNotEmpty) {
      notesParts.add(record.ingredientsDisplay);
    }
    final notesText = notesParts.join(' | ');
    final notes = record.notes != null && record.notes!.isNotEmpty
        ? '${record.notes} | $notesText'
        : notesText;

    return RecordListCard(
      title: title,
      time: _formatTime(record.mealTime),
      icon: Icons.icecream,
      iconColor: const Color(0xFFFFB74D),
      notes: notes.isNotEmpty ? notes : null,
      onTap: () => RecordBottomSheetHelper.showEditSolidFoodRecord(context, record),
      onEdit: () => RecordBottomSheetHelper.showEditSolidFoodRecord(context, record),
      onDelete: () => RecordBottomSheetHelper.showDeleteConfirm(
        context,
        title: '确认删除',
        message: '确定要删除这条辅食记录吗？',
        onConfirm: () => Provider.of<RecordsProvider>(context, listen: false).deleteSolidFoodRecord(record.id),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
