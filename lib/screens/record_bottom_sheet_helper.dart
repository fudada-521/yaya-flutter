import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/baby.dart';
import '../models/feeding_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/growth_record.dart';
import '../models/solid_food_record.dart';
import '../models/vaccine_record.dart';
import '../models/vaccine_plan.dart';
import '../providers/baby_provider.dart';
import '../providers/records_provider.dart';
import '../widgets/sheet/solid_food_record_sheet.dart';
import '../widgets/sheet/vaccine_record_sheet.dart';
import '../widgets/sheet/sheets.dart';
import '../widgets/sheet/components/components.dart';

/// 记录底部弹窗辅助类（工厂模式）
///
/// 提供统一的入口来显示各种记录类型的添加/编辑底部弹窗。
/// 包含喂养、睡眠、尿布、成长、辅食记录的添加和编辑方法，
/// 以及宝宝信息添加、快速成长记录和删除确认等辅助方法。
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
            const SheetHandle(),
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
                Expanded(child: _buildButton('添加宝宝', true, () {
                  Navigator.pop(context);
                  showAddBaby(context);
                })),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==================== 喂养记录 ====================

  static void showAddFeedingRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;
    FeedingRecordSheet().show(context);
  }

  static void showEditFeedingRecord(BuildContext context, FeedingRecord record) {
    FeedingRecordSheet(recordToEdit: record).show(context);
  }

  // ==================== 睡眠记录 ====================

  static void showAddSleepRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;
    SleepRecordSheet().show(context);
  }

  static void showEditSleepRecord(BuildContext context, SleepRecord record) {
    SleepRecordSheet(recordToEdit: record).show(context);
  }

  // ==================== 尿布记录 ====================

  static void showAddDiaperRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;
    DiaperRecordSheet().show(context);
  }

  static void showEditDiaperRecord(BuildContext context, DiaperRecord record) {
    DiaperRecordSheet(recordToEdit: record).show(context);
  }

  // ==================== 成长记录 ====================

  static void showAddGrowthRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;
    GrowthRecordSheet().show(context);
  }

  static void showEditGrowthRecord(BuildContext context, GrowthRecord record) {
    GrowthRecordSheet(recordToEdit: record).show(context);
  }

  // ==================== 辅食记录 ====================

  static void showAddSolidFoodRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;
    SolidFoodRecordSheetWrapper().show(context);
  }

  static void showEditSolidFoodRecord(BuildContext context, SolidFoodRecord record) {
    SolidFoodRecordSheetWrapper(recordToEdit: record).show(context);
  }

  // ==================== 疫苗记录 ====================

  static void showAddVaccineRecord(BuildContext context, {VaccineScheduleItem? scheduleItem}) {
    if (!_checkBabyExists(context)) return;
    VaccineRecordSheet(scheduleItem: scheduleItem).show(context);
  }

  static void showEditVaccineRecord(BuildContext context, VaccineRecord record) {
    VaccineRecordSheet(recordToEdit: record).show(context);
  }

  // 快速成长记录
  static void showQuickHeightRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;
    _showQuickGrowthRecord(context, focusHeight: true);
  }

  static void showQuickWeightRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;
    _showQuickGrowthRecord(context, focusWeight: true);
  }

  static void showQuickHeadCircumferenceRecord(BuildContext context) {
    if (!_checkBabyExists(context)) return;
    _showQuickGrowthRecord(context, focusHeadCircumference: true);
  }

  static void _showQuickGrowthRecord(
    BuildContext context, {
    bool focusHeight = false,
    bool focusWeight = false,
    bool focusHeadCircumference = false,
  }) {
    final controller = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SheetHandle(),
                  const SizedBox(height: 20),
                  SheetHeader(
                    title: focusHeight ? '快速记录身高'
                        : focusWeight ? '快速记录体重'
                        : '快速记录头围',
                    primaryColor: const Color(0xFFBA68C8),
                  ),
                  const SizedBox(height: 24),
                  _GrowthDatePicker(
                    selectedDate: selectedDate,
                    onChanged: (dt) => setState(() => selectedDate = dt),
                  ),
                  const SizedBox(height: 16),
                  SheetTextField(
                    controller: controller,
                    label: focusHeight ? '身高' : focusWeight ? '体重' : '头围',
                    hint: 'cm',
                    suffix: 'cm',
                  ),
                  const SizedBox(height: 24),
                  SheetActionButtons(
                    onCancel: () => Navigator.pop(ctx),
                    onSave: () => _saveQuickGrowthRecord(ctx, selectedDate, focusWeight ? double.tryParse(controller.text) : null, focusHeight ? double.tryParse(controller.text) : null, focusHeadCircumference ? double.tryParse(controller.text) : null),
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
    if (currentBaby == null) return;

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

  // ==================== 添加宝宝 ====================

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
                  const SheetHandle(),
                  const SizedBox(height: 20),
                  const SheetHeader(
                    title: '添加宝宝信息',
                    subtitle: '记录宝宝的基本信息',
                  ),
                  const SizedBox(height: 32),
                  SheetTextField(
                    controller: nameController,
                    label: '宝宝姓名',
                    hint: '请输入宝宝姓名',
                  ),
                  const SizedBox(height: 24),
                  _buildBabyDatePicker(
                    context: context,
                    selectedDate: selectedDate,
                    onDateChanged: (date) => setState(() => selectedDate = date),
                  ),
                  const SizedBox(height: 24),
                  _buildBabyGenderSelector(
                    selectedGender: selectedGender,
                    onGenderChanged: (gender) => setState(() => selectedGender = gender),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SheetTextField(
                          controller: birthWeightController,
                          label: '出生体重',
                          hint: 'kg',
                          suffix: 'kg',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SheetTextField(
                          controller: birthHeightController,
                          label: '出生身高',
                          hint: 'cm',
                          suffix: 'cm',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SheetTextField(
                    controller: notesController,
                    label: '备注',
                    hint: '选填，可添加备注信息',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),
                  SheetActionButtons(
                    onCancel: () => Navigator.pop(context),
                    onSave: () async {
                      final navigator = Navigator.of(context);
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
                        navigator.pop();
                      }
                    },
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

  // ==================== 删除确认 ====================

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
            const SheetHandle(),
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

  // ==================== 通用组件 ====================

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

  // ==================== 宝宝日期选择器 ====================

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
                    '${selectedDate.year}年${selectedDate.month.toString().padLeft(2, '0')}月${selectedDate.day.toString().padLeft(2, '0')}日',
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

  // ==================== 宝宝性别选择器 ====================

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

// Helper widget for quick growth record date picker
class _GrowthDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const _GrowthDatePicker({
    required this.selectedDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '测量日期',
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
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFBA68C8),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Color(0xFF2D2D2D),
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
                  '${selectedDate.year}年${selectedDate.month.toString().padLeft(2, '0')}月${selectedDate.day.toString().padLeft(2, '0')}日',
                  style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
