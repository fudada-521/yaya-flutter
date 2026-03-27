import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/growth_record.dart';
import 'package:intl/intl.dart';

class RecordBottomSheetHelper {
  // ==================== 喂养记录 BottomSheet ====================

  static void showAddFeedingRecord(BuildContext context) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();
    String selectedType = 'breast';
    String? selectedMethod;
    int? selectedDuration;

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
                    '添加喂养记录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDateTimePicker(context, selectedDateTime, (dt) => setState(() => selectedDateTime = dt)),
                  const SizedBox(height: 20),
                  _buildFeedingTypeSelector(selectedType, (type) => setState(() => selectedType = type)),
                  if (selectedType == 'breast') ...[
                    const SizedBox(height: 16),
                    _buildMethodSelector(selectedMethod, (m) => setState(() => selectedMethod = m)),
                    const SizedBox(height: 16),
                    _buildDurationSelector(selectedDuration, (d) => setState(() => selectedDuration = d)),
                  ],
                  if (selectedType != 'breast') ...[
                    const SizedBox(height: 16),
                    _buildTextField(amountController, '奶量', 'ml', suffix: 'ml'),
                  ],
                  const SizedBox(height: 16),
                  _buildTextField(notesController, '备注', '选填', maxLines: 2),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildButton('保存', true, () {
                        _saveFeedingRecord(
                          context,
                          selectedDateTime: selectedDateTime,
                          selectedType: selectedType,
                          selectedMethod: selectedMethod,
                          selectedDuration: selectedDuration,
                          amountController: amountController,
                          notesController: notesController,
                        );
                      })),
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

  static Widget _buildDateTimePicker(BuildContext context, DateTime selectedDateTime, ValueChanged<DateTime> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('喂养时间', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final navigator = Navigator.of(context);
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDateTime,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFFFF8A65),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: const Color(0xFF2D2D2D),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (!navigator.mounted || date == null) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(selectedDateTime),
            );
            if (time != null) {
              onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
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
                  DateFormat('yyyy年MM月dd日 HH:mm').format(selectedDateTime),
                  style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildFeedingTypeSelector(String selectedType, ValueChanged<String> onChanged) {
    final types = [
      {'value': 'breast', 'label': '母乳亲喂', 'icon': Icons.favorite, 'color': const Color(0xFFF48FB1)},
      {'value': 'pumped', 'label': '母乳瓶喂', 'icon': Icons.local_drink, 'color': const Color(0xFFE91E63)},
      {'value': 'bottle', 'label': '奶粉', 'icon': Icons.local_dining, 'color': const Color(0xFFFF8A65)},
      {'value': 'solid', 'label': '辅食', 'icon': Icons.restaurant, 'color': const Color(0xFF81C784)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('喂养类型', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types.map((type) {
            final isSelected = selectedType == type['value'];
            final color = type['color'] as Color;
            return GestureDetector(
              onTap: () => onChanged(type['value'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(25) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? color : Colors.grey[200]!, width: isSelected ? 1.5 : 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type['icon'] as IconData, color: isSelected ? color : Colors.grey[400], size: 20),
                    const SizedBox(width: 6),
                    Text(
                      type['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildMethodSelector(String? selectedMethod, ValueChanged<String?> onChanged) {
    final methods = [
      {'value': 'left', 'label': '左侧'},
      {'value': 'right', 'label': '右侧'},
      {'value': 'mixed', 'label': '混合'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('喂养方式', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: methods.map((method) {
            final isSelected = selectedMethod == method['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(method['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF48FB1).withAlpha(25) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? const Color(0xFFF48FB1) : Colors.grey[200]!, width: isSelected ? 1.5 : 1),
                  ),
                  child: Center(
                    child: Text(
                      method['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? const Color(0xFFF48FB1) : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildDurationSelector(int? selectedDuration, ValueChanged<int?> onChanged) {
    final presetDurations = [5, 10, 15, 20, 25, 30, 40, 50, 60];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('喂养时长', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetDurations.map((minutes) {
            final isSelected = selectedDuration == minutes;
            final hours = minutes ~/ 60;
            final mins = minutes % 60;
            final label = hours > 0 ? '${hours}h${mins > 0 ? '${mins}m' : ''}' : '${mins}m';

            return GestureDetector(
              onTap: () => onChanged(isSelected ? null : minutes),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF48FB1).withAlpha(25) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? const Color(0xFFF48FB1) : Colors.grey[200]!, width: isSelected ? 1.5 : 1),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? const Color(0xFFF48FB1) : Colors.grey[500],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static void _saveFeedingRecord(
    BuildContext context, {
    required DateTime selectedDateTime,
    required String selectedType,
    String? selectedMethod,
    int? selectedDuration,
    required TextEditingController amountController,
    required TextEditingController notesController,
  }) {
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
    final record = FeedingRecord(
      babyId: currentBaby.id,
      feedTime: selectedDateTime,
      amount: double.tryParse(amountController.text),
      type: selectedType,
      method: selectedMethod,
      duration: selectedType == 'breast' ? selectedDuration : null,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );
    Provider.of<RecordsProvider>(context, listen: false).addFeedingRecord(record);
    Navigator.pop(context);
  }

  // ==================== 睡眠记录 BottomSheet ====================

  static void showAddSleepRecord(BuildContext context) {
    DateTime startTime = DateTime.now();
    DateTime? endTime;
    int selectedQuality = 3;
    final notesController = TextEditingController();

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
                  _buildSleepDateTimePickers(context, startTime, endTime, (st, et) => setState(() {
                    startTime = st;
                    endTime = et;
                  })),
                  const SizedBox(height: 20),
                  _buildSleepQualitySelector(selectedQuality, (q) => setState(() => selectedQuality = q)),
                  const SizedBox(height: 16),
                  _buildTextField(notesController, '备注', '选填', maxLines: 2),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildButton('保存', true, () {
                        _saveSleepRecord(context, startTime, endTime, selectedQuality, notesController);
                      })),
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

  static Widget _buildSleepDateTimePickers(BuildContext context, DateTime startTime, DateTime? endTime, Function(DateTime, DateTime?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('睡眠时间', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDateTimeTile(context, '开始', startTime, (dt) => onChanged(dt, endTime))),
            const SizedBox(width: 12),
            Expanded(child: _buildDateTimeTile(context, '结束', endTime ?? DateTime.now(), endTime == null ? null : (dt) => onChanged(startTime, dt))),
          ],
        ),
      ],
    );
  }

  static Widget _buildDateTimeTile(BuildContext context, String label, DateTime dateTime, ValueChanged<DateTime>? onChanged) {
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        final date = await showDatePicker(
          context: context,
          initialDate: dateTime,
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
        if (!navigator.mounted || date == null || onChanged == null) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(dateTime),
        );
        if (time != null) {
          onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MM-dd HH:mm').format(dateTime),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF2D2D2D)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSleepQualitySelector(int selectedQuality, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('睡眠质量', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            final quality = index + 1;
            final isSelected = selectedQuality == quality;
            return GestureDetector(
              onTap: () => onChanged(quality),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF64B5F6).withAlpha(25) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? const Color(0xFF64B5F6) : Colors.grey[200]!, width: isSelected ? 1.5 : 1),
                ),
                child: Icon(
                  Icons.star,
                  color: isSelected ? const Color(0xFF64B5F6) : Colors.grey[300],
                  size: 20,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  static void _saveSleepRecord(BuildContext context, DateTime startTime, DateTime? endTime, int quality, TextEditingController notesController) {
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
      startTime: startTime,
      endTime: endTime,
      quality: quality,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );
    Provider.of<RecordsProvider>(context, listen: false).addSleepRecord(record);
    Navigator.pop(context);
  }

  // ==================== 尿布记录 BottomSheet ====================

  static void showAddDiaperRecord(BuildContext context) {
    DateTime selectedDateTime = DateTime.now();
    String selectedType = 'wet';
    String selectedStatus = 'normal';

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
                    '添加尿布记录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDiaperDateTimePicker(context, selectedDateTime, (dt) => setState(() => selectedDateTime = dt)),
                  const SizedBox(height: 20),
                  _buildDiaperTypeSelector(selectedType, (type) => setState(() => selectedType = type)),
                  const SizedBox(height: 16),
                  _buildDiaperStatusSelector(selectedStatus, (status) => setState(() => selectedStatus = status)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildButton('保存', true, () {
                        _saveDiaperRecord(context, selectedDateTime, selectedType, selectedStatus);
                      })),
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

  static Widget _buildDiaperDateTimePicker(BuildContext context, DateTime selectedDateTime, ValueChanged<DateTime> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('更换时间', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final navigator = Navigator.of(context);
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDateTime,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFF81C784),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: const Color(0xFF2D2D2D),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (!navigator.mounted || date == null) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(selectedDateTime),
            );
            if (time != null) {
              onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
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
                  DateFormat('yyyy年MM月dd日 HH:mm').format(selectedDateTime),
                  style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildDiaperTypeSelector(String selectedType, ValueChanged<String> onChanged) {
    final types = [
      {'value': 'wet', 'label': '湿尿布', 'icon': Icons.water_drop, 'color': const Color(0xFF64B5F6)},
      {'value': 'dirty', 'label': '脏尿布', 'icon': Icons.cloud, 'color': const Color(0xFF81C784)},
      {'value': 'both', 'label': '都有', 'icon': Icons.all_inclusive, 'color': const Color(0xFFFF8A65)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('尿布类型', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: types.map((type) {
            final isSelected = selectedType == type['value'];
            final color = type['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(type['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(25) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? color : Colors.grey[200]!, width: isSelected ? 1.5 : 1),
                  ),
                  child: Column(
                    children: [
                      Icon(type['icon'] as IconData, color: isSelected ? color : Colors.grey[400], size: 20),
                      const SizedBox(height: 4),
                      Text(
                        type['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? color : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static Widget _buildDiaperStatusSelector(String selectedStatus, ValueChanged<String> onChanged) {
    final statuses = [
      {'value': 'normal', 'label': '正常', 'color': const Color(0xFF81C784)},
      {'value': 'loose', 'label': '稀便', 'color': const Color(0xFFFF8A65)},
      {'value': 'constipation', 'label': '便秘', 'color': const Color(0xFFBA68C8)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('状态', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: statuses.map((status) {
            final isSelected = selectedStatus == status['value'];
            final color = status['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(status['value'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(25) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? color : Colors.grey[200]!, width: isSelected ? 1.5 : 1),
                  ),
                  child: Center(
                    child: Text(
                      status['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static void _saveDiaperRecord(BuildContext context, DateTime selectedDateTime, String selectedType, String selectedStatus) {
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
    final record = DiaperRecord(
      babyId: currentBaby.id,
      changeTime: selectedDateTime,
      type: selectedType,
      status: selectedStatus,
    );
    Provider.of<RecordsProvider>(context, listen: false).addDiaperRecord(record);
    Navigator.pop(context);
  }

  // ==================== 成长记录 BottomSheet ====================

  static void showAddGrowthRecord(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final headCircumferenceController = TextEditingController();
    final notesController = TextEditingController();

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
                    '添加成长记录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGrowthDatePicker(context, selectedDate, (dt) => setState(() => selectedDate = dt)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(weightController, '体重', 'kg', suffix: 'kg')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTextField(heightController, '身高', 'cm', suffix: 'cm')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(headCircumferenceController, '头围', 'cm', suffix: 'cm'),
                  const SizedBox(height: 16),
                  _buildTextField(notesController, '备注', '选填', maxLines: 2),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildButton('保存', true, () {
                        _saveGrowthRecord(
                          context,
                          selectedDate: selectedDate,
                          weightController: weightController,
                          heightController: heightController,
                          headCircumferenceController: headCircumferenceController,
                          notesController: notesController,
                        );
                      })),
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

  static Widget _buildGrowthDatePicker(BuildContext context, DateTime selectedDate, ValueChanged<DateTime> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('测量日期', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFFBA68C8),
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
              onChanged(date);
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
                  DateFormat('yyyy年MM月dd日').format(selectedDate),
                  style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static void _saveGrowthRecord(
    BuildContext context, {
    required DateTime selectedDate,
    required TextEditingController weightController,
    required TextEditingController heightController,
    required TextEditingController headCircumferenceController,
    required TextEditingController notesController,
  }) {
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
    final record = GrowthRecord(
      babyId: currentBaby.id,
      recordDate: selectedDate,
      weight: double.tryParse(weightController.text),
      height: double.tryParse(heightController.text),
      headCircumference: double.tryParse(headCircumferenceController.text),
      notes: notesController.text.isEmpty ? null : notesController.text,
    );
    Provider.of<RecordsProvider>(context, listen: false).addGrowthRecord(record);
    Navigator.pop(context);
  }

  // ==================== 通用组件 ====================

  static Widget _buildTextField(TextEditingController controller, String label, String hint, {String? suffix, int maxLines = 1}) {
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
              suffixText: suffix,
              suffixStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildButton(String text, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFF8A65) : Colors.grey[100],
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
}
