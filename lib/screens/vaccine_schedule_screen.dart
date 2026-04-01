import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vaccine_provider.dart';
import '../providers/baby_provider.dart';
import '../models/vaccine_record.dart';
import '../models/vaccine_plan.dart';
import '../widgets/empty_baby_card.dart';
import 'record_bottom_sheet_helper.dart';

/// 疫苗接种计划页面
///
/// 按月龄显示所有疫苗的接种安排，包括：
/// - 疫苗名称、剂次、接种方式（注射/口服）
/// - 接种时间（预计日期）
/// - 接种状态（已完成/待接种）
class VaccineScheduleScreen extends StatefulWidget {
  const VaccineScheduleScreen({super.key});

  @override
  State<VaccineScheduleScreen> createState() => _VaccineScheduleScreenState();
}

class _VaccineScheduleScreenState extends State<VaccineScheduleScreen> {
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

          return _buildScheduleList(vaccineProvider, currentBaby);
        },
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

  Widget _buildScheduleList(VaccineProvider provider, baby) {
    final schedule = provider.getAllPendingVaccines(baby);
    final completedRecords = provider.getRecordsForBaby(baby.id)
        .where((r) => r.status == VaccineRecord.statusCompleted)
        .toList();

    // 按月龄分组
    final Map<int, List<VaccineScheduleItem>> groupedByMonth = {};
    for (final item in schedule) {
      groupedByMonth.putIfAbsent(item.doseMonth, () => []).add(item);
    }

    // 已完成的按月龄分组
    final Map<int, List<VaccineRecord>> completedByMonth = {};
    for (final record in completedRecords) {
      final vaccine = VaccinePlanData.findByName(record.vaccineName);
      if (vaccine != null) {
        for (int i = 0; i < vaccine.recommendedMonths.length; i++) {
          final doseMonth = vaccine.recommendedMonths[i];
          final doseDate = vaccine.calculateDate(baby.birthDate, doseMonth);
          if (doseDate.year == record.vaccinationTime.year &&
              doseDate.month == record.vaccinationTime.month &&
              doseDate.day == record.vaccinationTime.day) {
            completedByMonth.putIfAbsent(doseMonth, () => []).add(record);
          }
        }
      }
    }

    // 合并所有月龄并排序
    final allMonths = <int>{
      ...groupedByMonth.keys,
      ...completedByMonth.keys,
    }.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allMonths.length,
      itemBuilder: (context, index) {
        final month = allMonths[index];
        final pending = groupedByMonth[month] ?? [];
        final completed = completedByMonth[month] ?? [];

        return _buildMonthSection(month, pending, completed, baby);
      },
    );
  }

  Widget _buildMonthSection(int month, List<VaccineScheduleItem> pending, List<VaccineRecord> completed, baby) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthDate = DateTime(baby.birthDate.year, baby.birthDate.month + month, baby.birthDate.day);
    final isPast = monthDate.isBefore(today);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 月龄标题
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isPast ? Colors.grey[100] : const Color(0xFF26A69A).withAlpha(25),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPast ? Colors.grey[400] : const Color(0xFF26A69A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatMonth(month),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getMonthLabel(month),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPast ? Colors.grey[600] : const Color(0xFF26A69A),
                  ),
                ),
                const Spacer(),
                if (pending.isEmpty && completed.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '已完成',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 疫苗列表
          if (completed.isNotEmpty)
            ...completed.map((record) => _buildCompletedItem(record, baby)),
          if (pending.isNotEmpty)
            ...pending.map((item) => _buildPendingItem(item)),
          if (pending.isEmpty && completed.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '暂无接种安排',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedItem(VaccineRecord record, baby) {
    // 查找对应的疫苗信息
    final vaccine = VaccinePlanData.findByName(record.vaccineName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle, color: Colors.green[400], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.vaccineName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildVaccineTag(vaccine),
                    const SizedBox(width: 8),
                    if (record.hospital != null)
                      Expanded(
                        child: Text(
                          record.hospital!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(record.vaccinationTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '已完成',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingItem(VaccineScheduleItem item) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = item.scheduledDate.isBefore(today);

    return GestureDetector(
      onTap: () => _showVaccineDetail(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[100]!),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isOverdue ? Colors.red[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isOverdue ? Icons.warning : Icons.schedule,
                color: isOverdue ? Colors.red[400] : Colors.orange[400],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildVaccineTag(item.vaccine),
                      const SizedBox(width: 8),
                      Text(
                        isOverdue ? '已过期' : '预计接种',
                        style: TextStyle(
                          fontSize: 11,
                          color: isOverdue ? Colors.red[400] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(item.scheduledDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOverdue ? Colors.red[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => RecordBottomSheetHelper.showAddVaccineRecord(context, scheduleItem: item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF26A69A).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '记录接种',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.teal[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineTag(VaccinePlanItem? vaccine) {
    if (vaccine == null) return const SizedBox.shrink();

    // 判断接种方式
    String method = '注射';
    if (vaccine.code == 'OPV' || vaccine.code == 'HepB' || vaccine.code == 'HepA') {
      method = '口服';
    } else if (vaccine.code == 'BCG') {
      method = '皮内注射';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        method,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showVaccineDetail(VaccineScheduleItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _VaccineDetailSheet(item: item),
    );
  }

  String _formatMonth(int month) {
    if (month == 0) return '出生';
    if (month < 12) {
      return '${month}月龄';
    } else {
      final years = month ~/ 12;
      final remainingMonths = month % 12;
      if (remainingMonths == 0) {
        return '${years}岁';
      }
      return '${years}岁零${remainingMonths}月';
    }
  }

  String _getMonthLabel(int month) {
    if (month == 0) return '出生时';
    if (month < 12) return '$month 月龄';
    final years = month ~/ 12;
    final remainingMonths = month % 12;
    if (remainingMonths == 0) {
      return '$years 岁';
    }
    return '$years 岁 $remainingMonths 月';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
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
    String method = '注射';
    String methodDetail = '肌肉注射';
    if (vaccine.code == 'OPV') {
      method = '口服';
      methodDetail = '脊髓灰质炎减毒活疫苗（滴剂）';
    } else if (vaccine.code == 'HepB') {
      method = '肌注+口服';
      methodDetail = '乙肝疫苗（注射）+ 卡介苗（皮内注射）';
    } else if (vaccine.code == 'BCG') {
      method = '皮内注射';
      methodDetail = '卡介苗';
    } else if (vaccine.code == 'HepA') {
      method = '注射';
      methodDetail = '甲肝减毒活疫苗';
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26A69A).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.vaccines, color: Color(0xFF26A69A), size: 28),
                    ),
                    const SizedBox(width: 16),
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

                // 疫苗信息卡片
                _buildInfoRow('疫苗代码', vaccine.code),
                _buildInfoRow('接种剂次', item.doseDisplay),
                _buildInfoRow('接种方式', method),
                _buildInfoRow('费用', vaccine.isFree ? '免费（国家免疫规划）' : '自费'),
                if (vaccine.notes != null)
                  _buildInfoRow('备注', vaccine.notes!),

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
