import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vaccine_provider.dart';
import '../providers/baby_provider.dart';
import '../models/vaccine_record.dart';
import '../models/vaccine_plan.dart';
import '../models/baby.dart';
import '../widgets/empty_baby_card.dart';
import 'record_bottom_sheet_helper.dart';

/// 疫苗筛选类型
enum VaccineFilter { all, national, nonNational }

/// 疫苗接种计划页面
///
/// 使用时间轴形式展示疫苗接种时间（1月龄～6岁）
/// 疫苗卡片显示：疫苗名称、针次、预防的疾病、接种方式、推荐接种时间
class VaccineScheduleScreen extends StatefulWidget {
  const VaccineScheduleScreen({super.key});

  @override
  State<VaccineScheduleScreen> createState() => _VaccineScheduleScreenState();
}

class _VaccineScheduleScreenState extends State<VaccineScheduleScreen> {
  VaccineFilter _selectedFilter = VaccineFilter.national; // 默认只显示免疫规划

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
              _buildFilterTabs(),
              Expanded(child: _buildTimelineView(vaccineProvider, currentBaby)),
            ],
          );
        },
      ),
    );
  }

  /// 构建筛选 Tab
  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(VaccineFilter.national, '免疫规划', Icons.shield_outlined),
          const SizedBox(width: 8),
          _buildFilterChip(VaccineFilter.nonNational, '非免疫规划', Icons.paid_outlined),
          const SizedBox(width: 8),
          _buildFilterChip(VaccineFilter.all, '全部', Icons.list),
        ],
      ),
    );
  }

  Widget _buildFilterChip(VaccineFilter filter, String label, IconData icon) {
    final isSelected = _selectedFilter == filter;
    final color = isSelected ? const Color(0xFF26A69A) : Colors.grey[400]!;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26A69A).withAlpha(25) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF26A69A) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
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
            child: const Icon(Icons.calendar_month, color: Color(0xFF26A69A), size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            '疫苗接种计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建时间轴视图
  Widget _buildTimelineView(VaccineProvider provider, baby) {
    // 获取所有疫苗接种时间点（0月龄出生到72月龄6岁）
    final List<int> allMonths = List.generate(73, (i) => i); // 0-72月龄

    // 获取已完成疫苗记录
    final completedRecords = provider.getRecordsForBaby(baby.id)
        .where((r) => r.status == VaccineRecord.statusCompleted)
        .toList();

    // 创建已完成记录的索引：vaccineCode_doseNumber -> record
    final Map<String, VaccineRecord> completedIndex = {};
    for (final record in completedRecords) {
      if (record.vaccineCode != null) {
        // 优先使用记录中存储的 doseNumber
        if (record.doseNumber != null) {
          final key = '${record.vaccineCode}_${record.doseNumber}';
          completedIndex[key] = record;
        } else {
          // 回退到日期匹配逻辑（兼容旧数据）
          final vaccine = VaccinePlanData.findByName(record.vaccineName);
          if (vaccine != null) {
            for (int i = 0; i < vaccine.recommendedMonths.length; i++) {
              final doseMonth = vaccine.recommendedMonths[i];
              final doseDate = vaccine.calculateDate(baby.birthDate, doseMonth);
              if (doseDate.year == record.vaccinationTime.year &&
                  doseDate.month == record.vaccinationTime.month &&
                  doseDate.day == record.vaccinationTime.day) {
                final key = '${record.vaccineCode}_${i + 1}';
                completedIndex[key] = record;
              }
            }
          }
        }
      }
    }

    // 是否包含非免疫规划疫苗
    final includeNonNational = _selectedFilter != VaccineFilter.national;

    // 按月龄分组待接种疫苗（排除已完成的）
    final Map<int, List<VaccineScheduleItem>> pendingByMonth = {};
    final pendingSchedule = provider.getAllPendingVaccines(baby, includeNonNational: includeNonNational);
    for (final item in pendingSchedule) {
      // 根据筛选条件过滤
      if (_selectedFilter == VaccineFilter.national && !item.vaccine.isFree) continue;
      if (_selectedFilter == VaccineFilter.nonNational && item.vaccine.isFree) continue;

      final key = '${item.vaccine.code}_${item.doseNumber}';
      // 跳过已完成的
      if (completedIndex.containsKey(key)) continue;
      pendingByMonth.putIfAbsent(item.doseMonth, () => []).add(item);
    }

    // 按推荐接种月龄分组已完成疫苗（而非实际接种时间）
    final Map<int, List<VaccineRecord>> completedByMonth = {};
    for (final record in completedRecords) {
      final vaccine = VaccinePlanData.findByName(record.vaccineName);
      if (vaccine == null) continue;

      // 根据筛选条件过滤
      if (_selectedFilter == VaccineFilter.national && !vaccine.isFree) continue;
      if (_selectedFilter == VaccineFilter.nonNational && vaccine.isFree) continue;

      // 找到该记录的推荐月龄
      final recommendedMonth = _getRecommendedMonth(baby, record, provider);
      completedByMonth.putIfAbsent(recommendedMonth, () => []).add(record);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allMonths.length,
      itemBuilder: (context, index) {
        final month = allMonths[index];
        final pending = pendingByMonth[month] ?? [];
        final completed = completedByMonth[month] ?? [];

        // 只显示有疫苗的月份或出生月份
        if (pending.isEmpty && completed.isEmpty && month != 0) {
          return const SizedBox.shrink();
        }

        return _buildTimelineItem(month, pending, completed, baby);
      },
    );
  }

  /// 获取疫苗实际接种的月龄
  int _getVaccinationMonth(Baby baby, VaccineRecord record) {
    final vaccine = VaccinePlanData.findByName(record.vaccineName);
    if (vaccine == null) return 0;

    for (int i = 0; i < vaccine.recommendedMonths.length; i++) {
      final doseMonth = vaccine.recommendedMonths[i];
      final doseDate = vaccine.calculateDate(baby.birthDate, doseMonth);
      if (doseDate.year == record.vaccinationTime.year &&
          doseDate.month == record.vaccinationTime.month &&
          doseDate.day == record.vaccinationTime.day) {
        return doseMonth;
      }
    }
    // 如果找不到匹配，按日期计算月龄差
    final monthsDiff = (record.vaccinationTime.year - baby.birthDate.year) * 12 +
        (record.vaccinationTime.month - baby.birthDate.month);
    return monthsDiff.clamp(0, 72).toInt();
  }

  /// 获取疫苗推荐接种月龄（用于排序，不随实际接种时间变化）
  int _getRecommendedMonth(Baby baby, VaccineRecord record, VaccineProvider provider) {
    final vaccine = VaccinePlanData.findByName(record.vaccineName);
    if (vaccine == null) return 0;

    // 优先使用记录中存储的 doseNumber
    if (record.doseNumber != null && record.doseNumber! >= 1 && record.doseNumber! <= vaccine.recommendedMonths.length) {
      return vaccine.recommendedMonths[record.doseNumber! - 1];
    }

    // 使用与 _getDoseInfo 相同的逻辑确定剂次
    for (int i = 0; i < vaccine.recommendedMonths.length; i++) {
      final doseMonth = vaccine.recommendedMonths[i];
      final doseDate = vaccine.calculateDate(baby.birthDate, doseMonth);
      if (doseDate.year == record.vaccinationTime.year &&
          doseDate.month == record.vaccinationTime.month &&
          doseDate.day == record.vaccinationTime.day) {
        // 找到匹配的推荐月龄
        return doseMonth;
      }
    }

    // 如果找不到精确匹配（接种日期与推荐日期不同），按剂次顺序推断
    // 假设用户按时接种，剂次按推荐月龄顺序
    final doseNumber = _getDoseNumberFromRecord(record, vaccine, baby, provider);
    if (doseNumber >= 1 && doseNumber <= vaccine.recommendedMonths.length) {
      return vaccine.recommendedMonths[doseNumber - 1];
    }

    // 如果无法确定，按日期计算月龄差
    final monthsDiff = (record.vaccinationTime.year - baby.birthDate.year) * 12 +
        (record.vaccinationTime.month - baby.birthDate.month);
    return monthsDiff.clamp(0, 72).toInt();
  }

  /// 从记录中获取剂次号
  int _getDoseNumberFromRecord(VaccineRecord record, VaccinePlanItem vaccine, Baby baby, VaccineProvider provider) {
    // 统计同一疫苗在此时之前已完成的剂次
    final records = provider.getRecordsForBaby(baby.id)
        .where((r) => r.status == VaccineRecord.statusCompleted &&
                      r.vaccineName == record.vaccineName &&
                      r.vaccinationTime.isBefore(record.vaccinationTime))
        .toList();
    return records.length + 1;
  }

  /// 构建时间轴单项
  Widget _buildTimelineItem(int month, List<VaccineScheduleItem> pending, List<VaccineRecord> completed, baby) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthDate = DateTime(baby.birthDate.year, baby.birthDate.month + month, baby.birthDate.day);
    final isPast = monthDate.isBefore(today);

    // 时间轴节点颜色
    Color nodeColor;
    if (completed.isNotEmpty && pending.isEmpty) {
      nodeColor = Colors.green;
    } else if (pending.isNotEmpty) {
      nodeColor = isPast ? Colors.red : const Color(0xFF26A69A);
    } else {
      nodeColor = Colors.grey;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间轴左侧
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 8),
                Text(
                  _formatMonth(month),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPast && pending.isNotEmpty ? Colors.red[400] : (isPast ? Colors.grey[500] : const Color(0xFF26A69A)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(monthDate),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          // 时间轴中间线
          SizedBox(
            width: 30,
            child: Column(
              children: [
                // 连接线（上）
                if (month > 0)
                  Container(
                    width: 2,
                    height: 8,
                    color: Colors.grey[300],
                  ),
                // 节点圆点
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // 连接线（下）
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          // 疫苗卡片
          Expanded(
            child: _buildVaccineCards(pending, completed, baby, isPast),
          ),
        ],
      ),
    );
  }

  /// 构建疫苗卡片列表
  Widget _buildVaccineCards(List<VaccineScheduleItem> pending, List<VaccineRecord> completed, Baby baby, bool isPast) {
    final List<Widget> cards = [];

    // 添加已完成疫苗卡片
    for (final record in completed) {
      cards.add(_buildCompletedCard(record, baby));
    }

    // 添加待接种疫苗卡片
    for (final item in pending) {
      cards.add(_buildPendingCard(item, isPast));
    }

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: cards.map((card) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: card,
      )).toList(),
    );
  }

  /// 构建已完成疫苗卡片（无图标版）
  Widget _buildCompletedCard(VaccineRecord record, Baby baby) {
    final vaccine = VaccinePlanData.findByName(record.vaccineName);
    final doseInfo = _getDoseInfo(record, vaccine, baby);
    final isFree = vaccine?.isFree ?? true;

    return GestureDetector(
      onTap: () => _showVaccineDetailFromRecord(record, baby),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：免费/自费标签 + 疫苗名称 + 针次 + 状态
            Row(
              children: [
                // 免费/自费标签 + 图标
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFree ? Colors.green[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFree ? Icons.shield_outlined : Icons.paid_outlined,
                        size: 10,
                        color: isFree ? Colors.green[600] : Colors.blue[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        isFree ? '免费' : '自费',
                        style: TextStyle(
                          fontSize: 10,
                          color: isFree ? Colors.green[600] : Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.vaccineName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                Text(
                  doseInfo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '已完成',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 第二行：预防疾病
            if (vaccine != null)
              Text(
                '预防 ${vaccine.disease}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 4),
            // 第三行：接种方式 + 接种日期
            Row(
              children: [
                if (vaccine != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getVaccineMethod(vaccine),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  '接种日期：${_formatDateFull(record.vaccinationTime)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 第四行：查看接种记录按钮（图标+文字，绿色）
            GestureDetector(
              onTap: () => RecordBottomSheetHelper.showEditVaccineRecord(context, record),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_outlined, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      '查看接种记录',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 从已完成记录获取剂次信息
  String _getDoseInfo(VaccineRecord record, VaccinePlanItem? vaccine, Baby baby) {
    if (vaccine == null) return '';
    // 优先使用记录中存储的 doseNumber
    if (record.doseNumber != null && record.doseNumber! >= 1 && record.doseNumber! <= vaccine.totalDoses) {
      return '第${record.doseNumber}/${vaccine.totalDoses}针';
    }
    // 回退到日期匹配逻辑（兼容旧数据）
    for (int i = 0; i < vaccine.recommendedMonths.length; i++) {
      final doseMonth = vaccine.recommendedMonths[i];
      final doseDate = vaccine.calculateDate(baby.birthDate, doseMonth);
      if (doseDate.year == record.vaccinationTime.year &&
          doseDate.month == record.vaccinationTime.month &&
          doseDate.day == record.vaccinationTime.day) {
        return '第${i + 1}/${vaccine.totalDoses}针';
      }
    }
    return '第1/${vaccine.totalDoses}针';
  }

  /// 从已完成记录显示疫苗详情
  void _showVaccineDetailFromRecord(VaccineRecord record, Baby baby) {
    final vaccine = VaccinePlanData.findByName(record.vaccineName);
    if (vaccine == null) return;

    // 优先使用记录中存储的 doseNumber
    int doseNumber = record.doseNumber ?? 1;
    if (record.doseNumber == null) {
      // 回退到日期匹配逻辑（兼容旧数据）
      for (int i = 0; i < vaccine.recommendedMonths.length; i++) {
        final doseMonth = vaccine.recommendedMonths[i];
        final doseDate = vaccine.calculateDate(baby.birthDate, doseMonth);
        if (doseDate.year == record.vaccinationTime.year &&
            doseDate.month == record.vaccinationTime.month &&
            doseDate.day == record.vaccinationTime.day) {
          doseNumber = i + 1;
          break;
        }
      }
    }

    final scheduleItem = VaccineScheduleItem(
      vaccine: vaccine,
      scheduledDate: record.vaccinationTime,
      doseNumber: doseNumber,
      doseMonth: _getVaccinationMonth(baby, record),
    );
    _showVaccineDetail(scheduleItem);
  }

  /// 构建待接种疫苗卡片（无图标版）
  Widget _buildPendingCard(VaccineScheduleItem item, bool isPast) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = item.scheduledDate.isBefore(today);
    final isFuture = item.scheduledDate.isAfter(today);

    // 状态颜色定义
    final Color borderColor;
    final Color statusBgColor;
    final Color statusTextColor;
    final Color buttonColor;

    if (isOverdue) {
      // 已过期
      borderColor = Colors.red[200]!;
      statusBgColor = Colors.red[100]!;
      statusTextColor = Colors.red;
      buttonColor = Colors.red[400]!;
    } else if (isFuture) {
      // 未到接种时间 - 疫苗主题色
      borderColor = const Color(0xFF26A69A).withAlpha(77);
      statusBgColor = const Color(0xFF26A69A).withAlpha(25);
      statusTextColor = const Color(0xFF26A69A);
      buttonColor = const Color(0xFF26A69A);
    } else {
      // 待接种
      borderColor = Colors.orange[200]!;
      statusBgColor = Colors.orange[100]!;
      statusTextColor = Colors.orange[700]!;
      buttonColor = Colors.orange[400]!;
    }

    return GestureDetector(
      onTap: () => _showVaccineDetail(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：免费/自费标签 + 疫苗名称 + 针次 + 状态
            Row(
              children: [
                // 免费/自费标签 + 图标
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.vaccine.isFree ? Colors.green[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.vaccine.isFree ? Icons.shield_outlined : Icons.paid_outlined,
                        size: 10,
                        color: item.vaccine.isFree ? Colors.green[600] : Colors.blue[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.vaccine.isFree ? '免费' : '自费',
                        style: TextStyle(
                          fontSize: 10,
                          color: item.vaccine.isFree ? Colors.green[600] : Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.vaccine.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? Colors.red[700] : const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                Text(
                  item.doseDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isOverdue ? '已过期' : (isFuture ? '未到时间' : '待接种'),
                    style: TextStyle(
                      fontSize: 10,
                      color: statusTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 第二行：预防疾病
            Text(
              '预防 ${item.vaccine.disease}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            // 第三行：接种方式 + 推荐接种时间
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getVaccineMethod(item.vaccine),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '推荐接种时间：${_formatDateFull(item.scheduledDate)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isOverdue ? Colors.red[400] : Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 第四行：记录接种按钮（图标+文字，颜色与状态一致）
            GestureDetector(
              onTap: () => RecordBottomSheetHelper.showAddVaccineRecord(context, scheduleItem: item),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: buttonColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 16, color: buttonColor),
                    const SizedBox(width: 4),
                    Text(
                      '记录接种',
                      style: TextStyle(
                        fontSize: 12,
                        color: buttonColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取疫苗接种方式
  String _getVaccineMethod(VaccinePlanItem vaccine) {
    if (vaccine.code == 'OPV' || vaccine.code == 'HepA') {
      return '口服';
    } else if (vaccine.code == 'BCG') {
      return '皮内注射';
    }
    return '肌肉注射';
  }

  void _showVaccineDetail(VaccineScheduleItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _VaccineDetailSheet(item: item),
    );
  }

  String _formatMonth(int month) {
    if (month == 0) return '出生时';
    if (month < 12) return '$month月龄';
    final years = month ~/ 12;
    final remainingMonths = month % 12;
    if (remainingMonths == 0) {
      return '$years岁';
    }
    return '$years岁零$remainingMonths月';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _formatDateFull(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}

/// 疫苗详情底部弹窗
class _VaccineDetailSheet extends StatelessWidget {
  final VaccineScheduleItem item;

  const _VaccineDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final vaccine = item.vaccine;

    // 判断接种方式
    String method = '肌肉注射';
    if (vaccine.code == 'OPV' || vaccine.code == 'HepA') {
      method = '口服';
    } else if (vaccine.code == 'BCG') {
      method = '皮内注射';
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vaccine.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (vaccine.englishName != null)
                            Text(
                              vaccine.englishName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 疫苗信息
                _buildInfoRow('疫苗名称', vaccine.name),
                _buildInfoRow('疫苗代码', vaccine.code),
                _buildInfoRow('接种剂次', item.doseDisplay),
                _buildInfoRow('预防疾病', vaccine.disease),
                _buildInfoRow('接种方式', method),
                _buildInfoRow('费用', vaccine.isFree ? '免费（国家免疫规划）' : '自费'),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[400], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '按照国家免疫规划，${vaccine.name}应在宝宝${_formatMonth(item.doseMonth)}时接种。',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(int month) {
    if (month == 0) return '出生';
    if (month < 12) return '$month 月龄';
    final years = month ~/ 12;
    final remainingMonths = month % 12;
    if (remainingMonths == 0) {
      return '$years 岁';
    }
    return '$years 岁零$remainingMonths 月';
  }
}