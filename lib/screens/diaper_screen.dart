import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/diaper_record.dart';
import 'record_bottom_sheet_helper.dart';
import '../widgets/records/records.dart';
import '../widgets/empty_baby_card.dart';

class DiaperScreen extends StatefulWidget {
  const DiaperScreen({super.key});

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
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
          final diaperRecords = recordsProvider.diaperRecords;

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildTodayStatsCard(recordsProvider),
              _buildQuickRecordArea(context, currentBaby?.id),
              Expanded(
                child: _buildRecordsList(diaperRecords),
              ),
            ],
          );
        },
      ),
      floatingActionButton: RecordFab(
        primaryColor: const Color(0xFF81C784),
        secondaryColor: const Color(0xFFA5D6A7),
        onPressed: () => RecordBottomSheetHelper.showAddDiaperRecord(context),
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
              color: const Color(0xFF81C784).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.baby_changing_station, color: Color(0xFF81C784), size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            '换尿布记录',
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
    final todayDiaper = recordsProvider.diaperRecords
        .where((r) => r.changeTime.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    return RecordStatsCard(
      title: '今日尿布统计',
      icon: Icons.analytics_outlined,
      iconColor: Colors.green[400]!,
      stats: [
        StatItem(label: '次数', value: '${todayDiaper.length}次', color: const Color(0xFF81C784)),
        StatItem(label: '小便', value: '${todayDiaper.where((r) => r.type == 'wet').length}次', color: const Color(0xFF64B5F6)),
        StatItem(label: '大便', value: '${todayDiaper.where((r) => r.type == 'dirty').length}次', color: const Color(0xFFFF8A65)),
      ],
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
      primaryColor: const Color(0xFF81C784),
      buttons: [
        QuickRecordButton(
          label: '小便',
          icon: Icons.water_drop,
          color: const Color(0xFF64B5F6),
          onTap: () => _quickRecord(babyId, 'wet'),
        ),
        QuickRecordButton(
          label: '大便',
          icon: Icons.wc,
          color: const Color(0xFFFF8A65),
          onTap: () => _quickRecord(babyId, 'dirty'),
        ),
        QuickRecordButton(
          label: '混合',
          icon: Icons.badge,
          color: const Color(0xFFBA68C8),
          onTap: () => _quickRecord(babyId, 'both'),
        ),
      ],
    );
  }

  Widget _buildRecordsList(List<DiaperRecord> records) {
    if (records.isEmpty) {
      return const RecordsEmptyState(
        icon: Icons.baby_changing_station,
        title: '暂无换尿布记录',
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

  Widget _buildRecordCard(DiaperRecord record) {
    final typeColor = record.type == 'dirty'
        ? const Color(0xFFFF8A65)
        : record.type == 'both'
            ? const Color(0xFFBA68C8)
            : const Color(0xFF64B5F6);

    return RecordListCard(
      title: '${record.typeDisplayName} ${record.statusDisplayName}',
      time: '${record.changeTime.month.toString().padLeft(2, '0')}-${record.changeTime.day.toString().padLeft(2, '0')} ${record.changeTime.hour.toString().padLeft(2, '0')}:${record.changeTime.minute.toString().padLeft(2, '0')}',
      icon: record.type == 'dirty' ? Icons.wc : Icons.water_drop,
      iconColor: typeColor,
      notes: record.notes,
      onTap: () => RecordBottomSheetHelper.showEditDiaperRecord(context, record),
      onEdit: () => RecordBottomSheetHelper.showEditDiaperRecord(context, record),
      onDelete: () => RecordBottomSheetHelper.showDeleteConfirm(
        context,
        title: '确认删除',
        message: '确定要删除这条尿布记录吗？',
        onConfirm: () => Provider.of<RecordsProvider>(context, listen: false).deleteDiaperRecord(record.id),
      ),
    );
  }

  void _quickRecord(String babyId, String type) {
    final record = DiaperRecord(
      babyId: babyId,
      changeTime: DateTime.now(),
      type: type,
      status: 'normal',
    );
    Provider.of<RecordsProvider>(context, listen: false).addDiaperRecord(record);
  }
}
