import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/records_provider.dart';
import '../providers/baby_provider.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/growth_record.dart';
import '../models/baby.dart';
import 'package:intl/intl.dart';

class RecordBottomSheetHelper {
  // ==================== 检查宝宝是否存在 ====================

  static bool _checkBabyExists(BuildContext context) {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) {
      _showNoBabyPrompt(context);
      return false;
    }
    return true;
  }

  static void _showNoBabyPrompt(BuildContext context) {
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
              decoration: BoxDecoration(color: Colors.orange[50], shape: BoxShape.circle),
              child: Icon(Icons.child_care, color: Colors.orange[400], size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              '请先添加宝宝信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D)),
            ),
            const SizedBox(height: 8),
            Text(
              '添加宝宝信息后才能记录喂养、睡眠、尿布等数据',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showAddBaby(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8A65),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('添加宝宝', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
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

  // ==================== 喂养记录 BottomSheet ====================

  static void showAddFeedingRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;

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
    if (!_checkBabyExists(context)) return;

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
    if (!_checkBabyExists(context)) return;

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
    if (!_checkBabyExists(context)) return;

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

  // ==================== 通用删除确认 ====================

  static void showDeleteConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
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
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onConfirm();
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

  // ==================== 喂养记录编辑 ====================

  static void showEditFeedingRecord(BuildContext context, FeedingRecord record) {
    final amountController = TextEditingController(text: record.amount?.toString() ?? '');
    final notesController = TextEditingController(text: record.notes ?? '');
    DateTime selectedDateTime = record.feedTime;
    String selectedType = record.type;
    String? selectedMethod = record.method;
    int? selectedDuration = record.duration;

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
                    '编辑喂养记录',
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
                        _updateFeedingRecord(context, record.id, selectedDateTime, selectedType, selectedMethod, selectedDuration, amountController, notesController);
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

  static void _updateFeedingRecord(
    BuildContext context,
    String recordId,
    DateTime selectedDateTime,
    String selectedType,
    String? selectedMethod,
    int? selectedDuration,
    TextEditingController amountController,
    TextEditingController notesController,
  ) {
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
      id: recordId,
      babyId: currentBaby.id,
      feedTime: selectedDateTime,
      amount: double.tryParse(amountController.text),
      type: selectedType,
      method: selectedMethod,
      duration: selectedType == 'breast' ? selectedDuration : null,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );
    Provider.of<RecordsProvider>(context, listen: false).updateFeedingRecord(record);
    Navigator.pop(context);
  }

  // ==================== 睡眠记录编辑 ====================

  static void showEditSleepRecord(BuildContext context, SleepRecord record) {
    DateTime startTime = record.startTime;
    DateTime? endTime = record.endTime;
    int selectedQuality = record.quality ?? 3;
    final notesController = TextEditingController(text: record.notes ?? '');

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
                  _buildSleepDateTimePickers(context, startTime, endTime, (st, et) => setState(() {
                    startTime = st;
                    endTime = et;
                  })),
                  const SizedBox(height: 16),
                  _buildEndSwitchForEdit(context, startTime, endTime, (et) => setState(() => endTime = et)),
                  const SizedBox(height: 16),
                  _buildSleepQualitySelector(selectedQuality, (q) => setState(() => selectedQuality = q)),
                  const SizedBox(height: 16),
                  _buildTextField(notesController, '备注', '选填', maxLines: 2),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildButton('保存', true, () {
                        _updateSleepRecord(context, record.id, startTime, endTime, selectedQuality, notesController);
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

  static Widget _buildEndSwitchForEdit(BuildContext context, DateTime startTime, DateTime? endTime, ValueChanged<DateTime?> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(endTime == null ? DateTime.now() : null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: endTime != null ? Colors.green[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: endTime != null ? Colors.green[300]! : Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              endTime != null ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: endTime != null ? Colors.green[600] : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Text(
              '睡眠已结束',
              style: TextStyle(
                fontSize: 15,
                color: endTime != null ? Colors.green[700] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _updateSleepRecord(
    BuildContext context,
    String recordId,
    DateTime startTime,
    DateTime? endTime,
    int quality,
    TextEditingController notesController,
  ) {
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
      id: recordId,
      babyId: currentBaby.id,
      startTime: startTime,
      endTime: endTime,
      quality: quality,
      notes: notesController.text.isEmpty ? null : notesController.text,
    );
    Provider.of<RecordsProvider>(context, listen: false).updateSleepRecord(record);
    Navigator.pop(context);
  }

  // ==================== 尿布记录编辑 ====================

  static void showEditDiaperRecord(BuildContext context, DiaperRecord record) {
    DateTime selectedDateTime = record.changeTime;
    String selectedType = record.type;
    String selectedStatus = record.status;

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
                    '编辑换尿布记录',
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
                        _updateDiaperRecord(context, record.id, selectedDateTime, selectedType, selectedStatus);
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

  static void _updateDiaperRecord(
    BuildContext context,
    String recordId,
    DateTime selectedDateTime,
    String selectedType,
    String selectedStatus,
  ) {
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
      id: recordId,
      babyId: currentBaby.id,
      changeTime: selectedDateTime,
      type: selectedType,
      status: selectedStatus,
    );
    Provider.of<RecordsProvider>(context, listen: false).updateDiaperRecord(record);
    Navigator.pop(context);
  }

  // ==================== 成长记录编辑 ====================

  static void showEditGrowthRecord(BuildContext context, GrowthRecord record) {
    DateTime selectedDate = record.recordDate;
    final weightController = TextEditingController(text: record.weight?.toString() ?? '');
    final heightController = TextEditingController(text: record.height?.toString() ?? '');
    final headCircumferenceController = TextEditingController(text: record.headCircumference?.toString() ?? '');
    final notesController = TextEditingController(text: record.notes ?? '');

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
                    '编辑成长记录',
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
                        _updateGrowthRecord(
                          context,
                          record.id,
                          selectedDate,
                          weightController,
                          heightController,
                          headCircumferenceController,
                          notesController,
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

  static void _updateGrowthRecord(
    BuildContext context,
    String recordId,
    DateTime selectedDate,
    TextEditingController weightController,
    TextEditingController heightController,
    TextEditingController headCircumferenceController,
    TextEditingController notesController,
  ) {
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
      id: recordId,
      babyId: currentBaby.id,
      recordDate: selectedDate,
      weight: double.tryParse(weightController.text),
      height: double.tryParse(heightController.text),
      headCircumference: double.tryParse(headCircumferenceController.text),
      notes: notesController.text.isEmpty ? null : notesController.text,
    );
    Provider.of<RecordsProvider>(context, listen: false).updateGrowthRecord(record);
    Navigator.pop(context);
  }

  // ==================== 快速成长记录 ====================

  static void showQuickHeightRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;

    final heightController = TextEditingController();
    DateTime selectedDate = DateTime.now();

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
                    '快速记录身高',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGrowthDatePicker(context, selectedDate, (dt) => setState(() => selectedDate = dt)),
                  const SizedBox(height: 16),
                  _buildTextField(heightController, '身高', 'cm', suffix: 'cm'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildButton('保存', true, () {
                        _saveQuickGrowthRecord(context, selectedDate, null, double.tryParse(heightController.text), null);
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

  static void showQuickWeightRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;

    final weightController = TextEditingController();
    DateTime selectedDate = DateTime.now();

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
                    '快速记录体重',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGrowthDatePicker(context, selectedDate, (dt) => setState(() => selectedDate = dt)),
                  const SizedBox(height: 16),
                  _buildTextField(weightController, '体重', 'kg', suffix: 'kg'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildButton('保存', true, () {
                        _saveQuickGrowthRecord(context, selectedDate, double.tryParse(weightController.text), null, null);
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

  static void showQuickHeadCircumferenceRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;

    final headController = TextEditingController();
    DateTime selectedDate = DateTime.now();

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
                    '快速记录头围',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGrowthDatePicker(context, selectedDate, (dt) => setState(() => selectedDate = dt)),
                  const SizedBox(height: 16),
                  _buildTextField(headController, '头围', 'cm', suffix: 'cm'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildButton('取消', false, () => Navigator.pop(context))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildButton('保存', true, () {
                        _saveQuickGrowthRecord(context, selectedDate, null, null, double.tryParse(headController.text));
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

  static void _saveQuickGrowthRecord(
    BuildContext context,
    DateTime selectedDate,
    double? weight,
    double? height,
    double? headCircumference,
  ) {
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
      weight: weight,
      height: height,
      headCircumference: headCircumference,
    );
    Provider.of<RecordsProvider>(context, listen: false).addGrowthRecord(record);
    Navigator.pop(context);
  }

  // ==================== 添加宝宝信息 BottomSheet ====================

  static void showAddBaby(BuildContext context) {
    final nameController = TextEditingController();
    final birthWeightController = TextEditingController();
    final birthHeightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedGender = 'male';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部拖动条
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
                  // 标题
                  const Text(
                    '添加宝宝信息',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '记录宝宝的基本信息',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 宝宝姓名
                  _buildTextField(nameController, '宝宝姓名', '请输入宝宝姓名'),
                  const SizedBox(height: 24),

                  // 出生日期
                  _buildBabyDatePicker(
                    context: context,
                    selectedDate: selectedDate,
                    onDateChanged: (date) => setState(() => selectedDate = date),
                  ),
                  const SizedBox(height: 24),

                  // 性别选择
                  _buildBabyGenderSelector(
                    selectedGender: selectedGender,
                    onGenderChanged: (gender) => setState(() => selectedGender = gender),
                  ),
                  const SizedBox(height: 24),

                  // 出生体重和身高
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(birthWeightController, '出生体重', 'kg', suffix: 'kg'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(birthHeightController, '出生身高', 'cm', suffix: 'cm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 备注
                  _buildTextField(notesController, '备注', '选填，可添加备注信息', maxLines: 2),
                  const SizedBox(height: 32),

                  // 按钮组
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton('取消', false, () => Navigator.pop(context)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildButton('保存', true, () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('请输入宝宝姓名'),
                                backgroundColor: Colors.orange[400],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }
                          final baby = Baby(
                            name: nameController.text.trim(),
                            birthDate: selectedDate,
                            gender: selectedGender,
                            birthWeight: double.tryParse(birthWeightController.text),
                            birthHeight: double.tryParse(birthHeightController.text),
                            notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          );
                          await Provider.of<BabyProvider>(context, listen: false).addBaby(baby);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('宝宝信息添加成功！'),
                                backgroundColor: Colors.green[400],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                          Navigator.pop(context);
                        }),
                      ),
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

  // 宝宝日期选择器
  static Widget _buildBabyDatePicker({
    required BuildContext context,
    required DateTime selectedDate,
    required Function(DateTime) onDateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '出生日期',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFFF8A65),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onDateChanged(date);
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
                Expanded(
                  child: Text(
                    DateFormat('yyyy年MM月dd日').format(selectedDate),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[500]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 宝宝性别选择器
  static Widget _buildBabyGenderSelector({
    required String selectedGender,
    required Function(String) onGenderChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性别',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onGenderChanged('male'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selectedGender == 'male' ? const Color(0xFF64B5F6).withAlpha(25) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedGender == 'male' ? const Color(0xFF64B5F6) : Colors.grey[200]!,
                      width: selectedGender == 'male' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        color: selectedGender == 'male' ? const Color(0xFF64B5F6) : Colors.grey[400],
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '男宝宝',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selectedGender == 'male' ? FontWeight.w600 : FontWeight.w500,
                          color: selectedGender == 'male' ? const Color(0xFF64B5F6) : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () => onGenderChanged('female'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selectedGender == 'female' ? const Color(0xFFF48FB1).withAlpha(25) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedGender == 'female' ? const Color(0xFFF48FB1) : Colors.grey[200]!,
                      width: selectedGender == 'female' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: selectedGender == 'female' ? const Color(0xFFF48FB1) : Colors.grey[400],
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '女宝宝',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selectedGender == 'female' ? FontWeight.w600 : FontWeight.w500,
                          color: selectedGender == 'female' ? const Color(0xFFF48FB1) : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
