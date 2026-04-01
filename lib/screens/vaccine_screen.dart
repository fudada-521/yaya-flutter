import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vaccine_provider.dart';
import '../providers/baby_provider.dart';
import '../models/vaccine_record.dart';
import '../models/vaccine_plan.dart';
import '../models/baby.dart';
import '../widgets/empty_baby_card.dart';
import '../widgets/records/records.dart';
import 'record_bottom_sheet_helper.dart';
import 'vaccine_info_screen.dart';

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

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildProgressCard(vaccineProvider, currentBaby.id),
                      _buildFilterTabs(),
                    ],
                  ),
                ),
              ];
            },
            body: _buildContent(vaccineProvider, currentBaby),
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
        // 科普按钮
        IconButton(
          icon: Icon(Icons.help_outline, color: Colors.grey[600]),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VaccineInfoScreen()),
            );
          },
          tooltip: '疫苗知识科普',
        ),
        // 刷新按钮
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
    // 免疫规划进度
    final nationalCompleted = _getCompletedCountByType(provider, babyId, isFree: true);
    final nationalTotal = VaccinePlanData.nationalVaccines.fold(0, (sum, v) => sum + v.totalDoses);
    final nationalProgress = nationalTotal > 0 ? nationalCompleted / nationalTotal : 0.0;

    // 非免疫规划进度
    final nonNationalCompleted = _getCompletedCountByType(provider, babyId, isFree: false);
    final nonNationalTotal = VaccinePlanData.nonNationalVaccines.fold(0, (sum, v) => sum + v.totalDoses);
    final nonNationalProgress = nonNationalTotal > 0 ? nonNationalCompleted / nonNationalTotal : 0.0;

    // 近期待接种
    final Baby? baby = Provider.of<BabyProvider>(context, listen: false).currentBaby;
    final upcomingVaccines = baby != null ? provider.getUpcomingVaccines(baby) : [];
    final overdueVaccines = baby != null
        ? provider.getAllPendingVaccines(baby).where((item) {
            return item.scheduledDate.isBefore(DateTime.now());
          }).toList()
        : [];

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
              // 接种计划按钮
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
              // 左侧：免疫规划进度
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          '免疫规划',
                          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$nationalCompleted / $nationalTotal',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '剂次完成',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: nationalProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 中间：非免疫规划进度
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.vaccines_outlined, color: Colors.blue, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          '非免疫规划',
                          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$nonNationalCompleted / $nonNationalTotal',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '剂次完成',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: nonNationalProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 近期统计
          Row(
            children: [
              if (overdueVaccines.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red[400], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '已过期 ${overdueVaccines.length} 剂',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (upcomingVaccines.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, color: Colors.orange[400], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '近期待接种 ${upcomingVaccines.length} 剂',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[400],
                          fontWeight: FontWeight.w500,
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

  Widget _buildContent(VaccineProvider provider, Baby baby) {
    if (_filterStatus == 'pending') {
      return _buildPendingContent(provider, baby);
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

  /// 待接种内容
  Widget _buildPendingContent(VaccineProvider provider, Baby baby) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 获取所有待接种疫苗
    final allPending = provider.getAllPendingVaccines(baby, includeNonNational: true);

    // 分类：已过期、今天、未来7天、未来
    final overdue = <VaccineScheduleItem>[];
    final todayList = <VaccineScheduleItem>[];
    final upcoming7Days = <VaccineScheduleItem>[];
    final future = <VaccineScheduleItem>[];

    for (final item in allPending) {
      final scheduledDate = DateTime(item.scheduledDate.year, item.scheduledDate.month, item.scheduledDate.day);
      if (scheduledDate.isBefore(today)) {
        overdue.add(item);
      } else if (scheduledDate.isAtSameMomentAs(today)) {
        todayList.add(item);
      } else if (scheduledDate.difference(today).inDays <= 7) {
        upcoming7Days.add(item);
      } else {
        future.add(item);
      }
    }

    if (allPending.isEmpty) {
      return const RecordsEmptyState(
        icon: Icons.check_circle_outline,
        title: '太棒了！',
        subtitle: '所有疫苗都已接种完成',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (overdue.isNotEmpty) ...[
          _buildSectionHeader('已过期', Colors.red[400]!),
          ...overdue.map((item) => _buildPendingCard(item, true)),
        ],
        if (todayList.isNotEmpty) ...[
          _buildSectionHeader('今天', Colors.orange[400]!),
          ...todayList.map((item) => _buildPendingCard(item, false)),
        ],
        if (upcoming7Days.isNotEmpty) ...[
          _buildSectionHeader('即将到期（7天内）', Colors.blue[400]!),
          ...upcoming7Days.map((item) => _buildPendingCard(item, false)),
        ],
        if (future.isNotEmpty) ...[
          _buildSectionHeader('未来待接种', const Color(0xFF26A69A)),
          ..._buildFutureList(future, baby),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  /// 构建未来待接种列表（按月龄分组）
  List<Widget> _buildFutureList(List<VaccineScheduleItem> items, Baby baby) {
    final Map<int, List<VaccineScheduleItem>> byMonth = {};
    for (final item in items) {
      byMonth.putIfAbsent(item.doseMonth, () => []).add(item);
    }

    final sortedMonths = byMonth.keys.toList()..sort();
    final List<Widget> result = [];

    for (final month in sortedMonths) {
      final monthItems = byMonth[month]!;
      result.add(_buildMonthSection(month, monthItems));
    }

    return result;
  }

  Widget _buildMonthSection(int month, List<VaccineScheduleItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            _formatMonth(month),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...items.map((item) => _buildPendingCard(item, false)),
      ],
    );
  }

  String _formatMonth(int month) {
    if (month == 0) return '出生时';
    if (month < 12) return '$month 月龄';
    final years = month ~/ 12;
    final remaining = month % 12;
    if (remaining == 0) return '$years 岁';
    return '$years 岁 $remaining 月';
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

  Widget _buildPendingCard(VaccineScheduleItem item, bool isOverdue) {
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: item.vaccine.isFree ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.vaccine.isFree ? '免费' : '自费',
                style: TextStyle(
                  fontSize: 10,
                  color: item.vaccine.isFree ? Colors.green[600] : Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                record.vaccineName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '已完成',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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

  /// 获取已完成数量（按类型）
  int _getCompletedCountByType(VaccineProvider provider, String babyId, {required bool isFree}) {
    final records = provider.getRecordsForBaby(babyId)
        .where((r) => r.status == VaccineRecord.statusCompleted)
        .toList();

    int count = 0;
    for (final record in records) {
      final vaccine = VaccinePlanData.findByName(record.vaccineName);
      if (vaccine != null && vaccine.isFree == isFree) {
        count++;
      }
    }
    return count;
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
