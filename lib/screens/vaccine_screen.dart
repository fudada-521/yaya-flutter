import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vaccine_provider.dart';
import '../providers/baby_provider.dart';
import '../models/vaccine_record.dart';
import '../models/vaccine_plan.dart';
import 'record_bottom_sheet_helper.dart';
import '../widgets/records/records.dart';
import '../widgets/empty_baby_card.dart';

/// 疫苗接种记录页面
///
/// 显示疫苗接种进度、待接种疫苗列表、已完成接种记录。
/// 可通过底部悬浮按钮添加新记录。
class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  String _filterStatus = 'pending'; // 'pending', 'completed'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VaccineProvider>(context, listen: false).loadVaccineRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Consumer2<VaccineProvider, BabyProvider>(
        builder: (context, vaccineProvider, babyProvider, child) {
          if (vaccineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentBaby = babyProvider.currentBaby;

          if (currentBaby == null) {
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

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildProgressCard(vaccineProvider, currentBaby.id),
              _buildFilterTabs(),
              Expanded(
                child: _buildContent(vaccineProvider, currentBaby),
              ),
            ],
          );
        },
      ),
      floatingActionButton: RecordFab(
        primaryColor: const Color(0xFF26A69A),
        secondaryColor: const Color(0xFF80CBC4),
        onPressed: () => RecordBottomSheetHelper.showAddVaccineRecord(context),
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
              color: const Color(0xFF26A69A).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.vaccines, color: Color(0xFF26A69A), size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            '疫苗接种',
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
            Provider.of<VaccineProvider>(context, listen: false).loadVaccineRecords();
          },
        ),
      ],
    );
  }

  Widget _buildProgressCard(VaccineProvider provider, String babyId) {
    final completedCount = provider.getCompletedCount(babyId);
    final totalCount = VaccinePlanData.totalDoses;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vaccines, color: const Color(0xFF26A69A), size: 24),
              const SizedBox(width: 8),
              const Text(
                '疫苗接种进度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/vaccine-schedule'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A).withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_month, color: const Color(0xFF26A69A), size: 14),
                      const SizedBox(width: 4),
                      const Text(
                        '接种计划',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF26A69A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completedCount / $totalCount',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26A69A),
                      ),
                    ),
                    Text(
                      '已完成剂次',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26A69A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('待接种', 'pending'),
          const SizedBox(width: 8),
          _buildFilterChip('已完成', 'completed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26A69A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(VaccineProvider provider, baby) {
    if (_filterStatus == 'pending') {
      final pendingVaccines = provider.getPendingVaccines(baby);
      if (pendingVaccines.isNotEmpty) {
        return _buildPendingList(pendingVaccines, provider, baby.id);
      }
      return const RecordsEmptyState(
        icon: Icons.check_circle_outline,
        title: '太棒了！',
        subtitle: '所有疫苗都已接种完成',
      );
    }

    if (_filterStatus == 'completed') {
      final completedRecords = provider.getRecordsForBaby(baby.id)
          .where((r) => r.status == VaccineRecord.statusCompleted)
          .toList();
      if (completedRecords.isNotEmpty) {
        return _buildCompletedList(completedRecords);
      }
      return const RecordsEmptyState(
        icon: Icons.vaccines_outlined,
        title: '暂无已完成记录',
        subtitle: '点击右下角按钮添加记录',
      );
    }

    return const RecordsEmptyState(
      icon: Icons.vaccines_outlined,
      title: '暂无疫苗记录',
      subtitle: '点击右下角按钮添加记录',
    );
  }

  Widget _buildPendingList(
    List<VaccineScheduleItem> pendingVaccines,
    VaccineProvider provider,
    String babyId,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 分类：已过期、今天、未来
    final overdue = <VaccineScheduleItem>[];
    final todayList = <VaccineScheduleItem>[];
    final upcoming = <VaccineScheduleItem>[];

    for (final item in pendingVaccines) {
      final scheduledDate = DateTime(
        item.scheduledDate.year,
        item.scheduledDate.month,
        item.scheduledDate.day,
      );
      if (scheduledDate.isBefore(today)) {
        overdue.add(item);
      } else if (scheduledDate.isAtSameMomentAs(today)) {
        todayList.add(item);
      } else {
        upcoming.add(item);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (overdue.isNotEmpty && _filterStatus != 'completed') ...[
          _buildSectionHeader('已过期', Colors.red[400]!),
          ...overdue.map((item) => _buildScheduleCard(item, true)),
        ],
        if (todayList.isNotEmpty && _filterStatus != 'completed') ...[
          _buildSectionHeader('今天', Colors.orange[400]!),
          ...todayList.map((item) => _buildScheduleCard(item, false)),
        ],
        if (upcoming.isNotEmpty && _filterStatus != 'completed') ...[
          _buildSectionHeader('即将到期', Colors.blue[400]!),
          ...upcoming.map((item) => _buildScheduleCard(item, false)),
        ],
        if (_filterStatus == 'all') ...[
          const SizedBox(height: 16),
          _buildSectionHeader('已完成', Color(0xFF26A69A)),
          _buildCompletedSection(provider, babyId),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(VaccineScheduleItem item, bool isOverdue) {
    final color = isOverdue ? Colors.red[400]! : const Color(0xFF26A69A);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue ? Colors.red[200]! : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.schedule, color: color, size: 20),
        ),
        title: Text(
          item.displayName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _formatDate(item.scheduledDate),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: isOverdue
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '已过期',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : null,
        onTap: () => _showAddVaccineSheet(item),
      ),
    );
  }

  Widget _buildCompletedSection(VaccineProvider provider, String babyId) {
    final completedRecords = provider.getRecordsForBaby(babyId)
        .where((r) => r.status == VaccineRecord.statusCompleted)
        .toList();

    if (completedRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: completedRecords
          .map((record) => _buildCompletedCard(record))
          .toList(),
    );
  }

  Widget _buildCompletedList(List<VaccineRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return _buildCompletedCard(records[index]);
      },
    );
  }

  Widget _buildCompletedCard(VaccineRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF26A69A).withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.check_circle, color: Color(0xFF26A69A), size: 20),
        ),
        title: Text(
          record.vaccineName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(record.vaccinationTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (record.hospital != null)
              Text(
                record.hospital!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[400]),
          onSelected: (value) {
            if (value == 'edit') {
              RecordBottomSheetHelper.showEditVaccineRecord(context, record);
            } else if (value == 'delete') {
              _showDeleteConfirmation(record);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('编辑')),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
      ),
    );
  }

  void _showAddVaccineSheet(VaccineScheduleItem item) {
    RecordBottomSheetHelper.showAddVaccineRecord(context, scheduleItem: item);
  }

  void _showDeleteConfirmation(VaccineRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定要删除"${record.vaccineName}"这条疫苗记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<VaccineProvider>(context, listen: false)
                  .deleteVaccineRecord(record.id);
              Navigator.pop(context);
            },
            child: Text('删除', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String prefix;
    if (dateOnly.isAtSameMomentAs(today)) {
      prefix = '今天';
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      prefix = '昨天';
    } else {
      prefix = '${date.month}月${date.day}日';
    }

    return prefix;
  }
}
