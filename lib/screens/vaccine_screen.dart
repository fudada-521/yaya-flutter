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

/// 疫苗接种综合页面
///
/// 显示整体接种进度、近期待接种疫苗、已完成记录。
/// 整合了免疫规划和非免疫规划疫苗的展示。
class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VaccineProvider>(context, listen: false).loadVaccineRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              // 顶部进度卡片
              _buildProgressCard(vaccineProvider, currentBaby),
              // Tab 栏
              _buildTabBar(),
              // Tab 内容
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 近期待接种
                    _buildPendingTab(vaccineProvider, currentBaby),
                    // 已完成记录
                    _buildCompletedTab(vaccineProvider, currentBaby),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => RecordBottomSheetHelper.showAddVaccineRecord(context),
        backgroundColor: const Color(0xFF26A69A),
        child: const Icon(Icons.add, color: Colors.white),
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
        // 接种计划入口
        IconButton(
          icon: Icon(Icons.calendar_month, color: Colors.grey[600]),
          onPressed: () => Navigator.pushNamed(context, '/vaccine-schedule'),
          tooltip: '接种计划',
        ),
      ],
    );
  }

  /// 构建进度卡片
  Widget _buildProgressCard(VaccineProvider provider, Baby baby) {
    // 免疫规划进度
    final nationalCompleted = _getCompletedCountByType(provider, baby.id, isFree: true);
    final nationalTotal = VaccinePlanData.nationalVaccines.fold(0, (sum, v) => sum + v.totalDoses);
    final nationalProgress = nationalTotal > 0 ? nationalCompleted / nationalTotal : 0.0;

    // 非免疫规划进度
    final nonNationalCompleted = _getCompletedCountByType(provider, baby.id, isFree: false);
    final nonNationalTotal = VaccinePlanData.nonNationalVaccines.fold(0, (sum, v) => sum + v.totalDoses);
    final nonNationalProgress = nonNationalTotal > 0 ? nonNationalCompleted / nonNationalTotal : 0.0;

    // 近期待接种
    final upcomingVaccines = provider.getUpcomingVaccines(baby);
    final overdueVaccines = provider.getAllPendingVaccines(baby).where((item) {
      return item.scheduledDate.isBefore(DateTime.now());
    }).toList();

    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          // 第一行：免疫规划进度
          _buildProgressRow(
            '免疫规划',
            nationalCompleted,
            nationalTotal,
            nationalProgress,
            Colors.green,
            Icons.shield_outlined,
          ),
          const SizedBox(height: 12),
          // 第二行：非免疫规划进度
          _buildProgressRow(
            '非免疫规划',
            nonNationalCompleted,
            nonNationalTotal,
            nonNationalProgress,
            Colors.blue,
            Icons.vaccines_outlined,
          ),
          const Divider(height: 24),
          // 第三行：近期统计
          Row(
            children: [
              _buildStatChip(
                '已过期',
                overdueVaccines.length.toString(),
                Colors.red[400]!,
                overdueVaccines.isNotEmpty,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                '近期待接种',
                upcomingVaccines.length.toString(),
                Colors.orange[400]!,
                upcomingVaccines.isNotEmpty,
              ),
              const Spacer(),
              // 接种计划按钮
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/vaccine-schedule'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A).withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
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
        ],
      ),
    );
  }

  /// 构建单个进度行
  Widget _buildProgressRow(
    String title,
    int completed,
    int total,
    double progress,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  Text(
                    '$completed / $total 剂',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 构建统计标签
  Widget _buildStatChip(String label, String value, Color color, bool hasData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasData ? color.withAlpha(25) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasData ? color.withAlpha(50) : Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: hasData ? color : Colors.grey[500],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: hasData ? color : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建 Tab 栏
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF26A69A),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF26A69A),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: '待接种'),
          Tab(text: '已完成'),
        ],
      ),
    );
  }

  /// 待接种 Tab
  Widget _buildPendingTab(VaccineProvider provider, Baby baby) {
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

    // 合并近期列表（已过期 + 今天 + 7天内）
    final recentItems = [...overdue, ...todayList, ...upcoming7Days];

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
        // 近期应接种（过期 + 今天 + 7天内）
        if (recentItems.isNotEmpty) ...[
          _buildSectionHeader('近期应接种', Colors.orange[400]!),
          ...recentItems.map((item) => _buildPendingCard(item, overdue.contains(item))),
          const SizedBox(height: 16),
        ],
        // 未来待接种（按月龄分组）
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
    // 按月龄分组
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

  /// 构建月龄分组
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

  /// 构建待接种卡片
  Widget _buildPendingCard(VaccineScheduleItem item, bool isOverdue) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = item.scheduledDate.year == today.year &&
        item.scheduledDate.month == today.month &&
        item.scheduledDate.day == today.day;

    Color statusColor;
    String statusText;
    if (isOverdue) {
      statusColor = Colors.red[400]!;
      statusText = '已过期';
    } else if (isToday) {
      statusColor = Colors.orange[400]!;
      statusText = '今天';
    } else {
      statusColor = const Color(0xFF26A69A);
      statusText = _formatDateShort(item.scheduledDate);
    }

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.vaccine.isFree ? Icons.shield_outlined : Icons.vaccines_outlined,
            color: statusColor,
            size: 18,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.vaccine.name,
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
        subtitle: Row(
          children: [
            Text(
              item.doseDisplay,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 8),
            Text(
              '预防 ${item.vaccine.disease}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => _showAddVaccineSheet(item),
      ),
    );
  }

  /// 已完成 Tab
  Widget _buildCompletedTab(VaccineProvider provider, Baby baby) {
    final completedRecords = provider.getRecordsForBaby(baby.id)
        .where((r) => r.status == VaccineRecord.statusCompleted)
        .toList();

    if (completedRecords.isEmpty) {
      return const RecordsEmptyState(
        icon: Icons.vaccines_outlined,
        title: '暂无已完成记录',
        subtitle: '点击右下角按钮添加记录',
      );
    }

    // 按疫苗类型分组
    final Map<String, List<VaccineRecord>> byVaccine = {};
    for (final record in completedRecords) {
      byVaccine.putIfAbsent(record.vaccineName, () => []).add(record);
    }

    // 按时间倒序排列
    completedRecords.sort((a, b) => b.vaccinationTime.compareTo(a.vaccinationTime));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: completedRecords.length,
      itemBuilder: (context, index) {
        return _buildCompletedCard(completedRecords[index]);
      },
    );
  }

  /// 构建已完成卡片
  Widget _buildCompletedCard(VaccineRecord record) {
    final vaccine = VaccinePlanData.findByName(record.vaccineName);
    final isFree = vaccine?.isFree ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
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
                color: isFree ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isFree ? '免费' : '自费',
                style: TextStyle(
                  fontSize: 10,
                  color: isFree ? Colors.green[600] : Colors.blue[600],
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
              _formatDateFull(record.vaccinationTime),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (record.hospital != null)
              Text(
                record.hospital!,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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

  /// 构建 Section 标题
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

  String _formatDateShort(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(today).inDays;

    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == -1) return '昨天';
    if (diff > 0 && diff <= 7) return '$diff天后';
    if (diff < 0) return '${-diff}天前';

    return '${date.month}/${date.day}';
  }

  String _formatDateFull(DateTime date) {
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

    return '$prefix ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
