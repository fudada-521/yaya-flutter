import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/sleep_record.dart';
import 'package:intl/intl.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final _notesController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime? _endTime;
  int _selectedQuality = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecordsProvider>(context, listen: false).loadAllRecords();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
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
                color: const Color(0xFF64B5F6).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bedtime, color: Color(0xFF64B5F6), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              '睡眠记录',
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
          final sleepRecords = recordsProvider.sleepRecords;

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildTodayStatsCard(recordsProvider, currentBaby?.id),
              _buildQuickRecordArea(context, currentBaby?.id),
              Expanded(
                child: _buildRecordsList(sleepRecords),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF90CAF9)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64B5F6).withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAddRecordDialog(context),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStatsCard(RecordsProvider recordsProvider, String? babyId) {
    final todaySleep = recordsProvider.sleepRecords
        .where((r) => r.startTime.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    final totalDuration = todaySleep.fold<Duration>(
      Duration.zero,
      (sum, r) => sum + (r.duration ?? Duration.zero),
    );

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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.analytics_outlined, color: Colors.blue[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '今日睡眠统计',
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
              _buildStatItem('次数', '${todaySleep.length}次', const Color(0xFF64B5F6)),
              _buildStatItem('总时长', _formatDuration(totalDuration), const Color(0xFF81C784)),
              _buildStatItem('平均质量', _calculateAverageQuality(todaySleep), const Color(0xFFBA68C8)),
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) return '$minutes分钟';
    return '${hours}h${minutes}m';
  }

  String _calculateAverageQuality(List<SleepRecord> records) {
    if (records.isEmpty) return '暂无数据';
    final average = records.fold<int>(0, (sum, r) => sum + (r.quality ?? 0)) ~/ records.length;
    switch (average) {
      case 1: return '很差';
      case 2: return '较差';
      case 3: return '一般';
      case 4: return '良好';
      case 5: return '优秀';
      default: return '$average分';
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
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt, color: Colors.indigo[400], size: 20),
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
              _buildQuickButton('午睡', Icons.wb_sunny, const Color(0xFFFFB74D), () => _quickRecord(babyId, false)),
              _buildQuickButton('夜间', Icons.nightlight_round, const Color(0xFF64B5F6), () => _quickRecord(babyId, true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoBabyCard(BuildContext context) {
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.child_care, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('请先添加宝宝档案', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/baby-profile'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF64B5F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('添加宝宝', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
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

  Widget _buildRecordsList(List<SleepRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bedtime_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('暂无睡眠记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
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

  Widget _buildRecordCard(SleepRecord record) {
    final isNightSleep = record.type == '夜间';
    final typeColor = isNightSleep ? const Color(0xFF64B5F6) : const Color(0xFFFFB74D);

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
          onTap: () => _showEditRecordDialog(context, record),
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
                  child: Icon(Icons.nightlight, color: typeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${record.type} ${record.durationString ?? '未结束'}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MM-dd HH:mm').format(record.startTime)}${record.endTime != null ? ' - ${DateFormat('HH:mm').format(record.endTime!)}' : ''}',
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
                if (record.endTime == null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('进行中', style: TextStyle(fontSize: 11, color: Colors.green[600], fontWeight: FontWeight.w500)),
                  ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditRecordDialog(context, record);
                    } else if (value == 'end') {
                      _endSleepRecord(context, record);
                    } else if (value == 'delete') {
                      _deleteRecord(context, record.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          const Text('编辑'),
                        ],
                      ),
                    ),
                    if (record.endTime == null)
                      PopupMenuItem(
                        value: 'end',
                        child: Row(
                          children: [
                            Icon(Icons.stop_circle_outlined, size: 18, color: Colors.green[600]),
                            const SizedBox(width: 8),
                            Text('结束', style: TextStyle(color: Colors.green[600])),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                          const SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red[400])),
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

  void _quickRecord(String babyId, bool isNightSleep) {
    final record = SleepRecord(
      babyId: babyId,
      startTime: DateTime.now(),
    );
    Provider.of<RecordsProvider>(context, listen: false).addSleepRecord(record);
  }

  void _showAddRecordDialog(BuildContext context) {
    _startTime = DateTime.now();
    _endTime = null;
    _selectedQuality = 3;
    _notesController.clear();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '添加睡眠记录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDateTimePicker(context, setState),
                  const SizedBox(height: 20),
                  _buildQualitySelector(setState),
                  const SizedBox(height: 16),
                  _buildMinimalistTextField(controller: _notesController, label: '备注', hint: '选填', maxLines: 2),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildDialogButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogButton('保存', true, () => _saveRecord(context))),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditRecordDialog(BuildContext context, SleepRecord record) {
    _startTime = record.startTime;
    _endTime = record.endTime;
    _selectedQuality = record.quality ?? 3;
    _notesController.text = record.notes ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '编辑睡眠记录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDateTimePicker(context, setState),
                  if (record.endTime == null) ...[
                    const SizedBox(height: 16),
                    _buildEndSwitch(setState),
                  ],
                  const SizedBox(height: 16),
                  _buildQualitySelector(setState),
                  const SizedBox(height: 16),
                  _buildMinimalistTextField(controller: _notesController, label: '备注', hint: '选填', maxLines: 2),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildDialogButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDialogButton('保存', true, () => _updateRecord(context, record))),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('开始时间', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startTime,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFF64B5F6),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: const Color(0xFF2D2D2D),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_startTime),
              );
              if (time != null) {
                setState(() {
                  _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Text(
                  DateFormat('yyyy年MM月dd日 HH:mm').format(_startTime),
                  style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndSwitch(StateSetter setState) {
    return GestureDetector(
      onTap: () => setState(() => _endTime = _endTime == null ? DateTime.now() : null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _endTime != null ? Colors.green[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _endTime != null ? Colors.green[300]! : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              _endTime != null ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: _endTime != null ? Colors.green[600] : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Text(
              '睡眠已结束',
              style: TextStyle(
                fontSize: 15,
                color: _endTime != null ? Colors.green[700] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualitySelector(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('睡眠质量', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$_selectedQuality', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF64B5F6))),
              Row(
                children: [
                  _buildQualityButton(Icons.remove, () {
                    if (_selectedQuality > 1) setState(() => _selectedQuality--);
                  }),
                  const SizedBox(width: 16),
                  Text(_getQualityText(_selectedQuality), style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  const SizedBox(width: 16),
                  _buildQualityButton(Icons.add, () {
                    if (_selectedQuality < 5) setState(() => _selectedQuality++);
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQualityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF64B5F6).withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF64B5F6)),
      ),
    );
  }

  String _getQualityText(int quality) {
    switch (quality) {
      case 1: return '很差';
      case 2: return '较差';
      case 3: return '一般';
      case 4: return '良好';
      case 5: return '优秀';
      default: return '未知';
    }
  }

  Widget _buildMinimalistTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogButton(String text, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF64B5F6) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  void _saveRecord(BuildContext context) {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先添加宝宝档案'),
          backgroundColor: Colors.orange[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final record = SleepRecord(
      babyId: currentBaby.id,
      startTime: _startTime,
      endTime: _endTime,
      quality: _selectedQuality,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
    Provider.of<RecordsProvider>(context, listen: false).addSleepRecord(record);
    Navigator.pop(context);
  }

  void _updateRecord(BuildContext context, SleepRecord oldRecord) {
    final record = oldRecord.copyWith(
      startTime: _startTime,
      endTime: _endTime,
      quality: _selectedQuality,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );
    Provider.of<RecordsProvider>(context, listen: false).updateSleepRecord(record);
    Navigator.pop(context);
  }

  void _endSleepRecord(BuildContext context, SleepRecord record) {
    final updatedRecord = record.copyWith(endTime: DateTime.now());
    Provider.of<RecordsProvider>(context, listen: false).updateSleepRecord(updatedRecord);
  }

  void _deleteRecord(BuildContext context, String recordId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
              child: Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 32),
            ),
            const SizedBox(height: 16),
            const Text('确认删除', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
            const SizedBox(height: 8),
            Text('确定要删除这条睡眠记录吗？', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDialogButton('取消', false, () => Navigator.pop(context))),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Provider.of<RecordsProvider>(context, listen: false).deleteSleepRecord(recordId);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('删除', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
