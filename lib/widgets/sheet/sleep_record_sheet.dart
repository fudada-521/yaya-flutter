import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/sleep_record.dart';
import '../../providers/records_provider.dart';
import '../../providers/baby_provider.dart';
import 'base_record_sheet.dart';
import 'components/components.dart';

/// 睡眠记录表单组件（策略模式）
///
/// 支持添加和编辑睡眠记录，
/// 包含开始时间、结束时间、睡眠质量、备注等字段。
class SleepRecordSheet extends BaseRecordSheet<SleepRecordState> {
  final SleepRecord? recordToEdit;

  SleepRecordSheet({
    super.key,
    this.recordToEdit,
  }) : super(
          title: recordToEdit != null ? '编辑睡眠记录' : '添加睡眠记录',
          primaryColor: const Color(0xFF64B5F6),
          initialData: recordToEdit != null
              ? SleepRecordState.fromRecord(recordToEdit)
              : null,
        );

  @override
  SleepRecordState createInitialState() {
    return SleepRecordState();
  }

  @override
  List<Widget> buildForm(BuildContext context, SleepRecordState state, StateSetter setState) {
    return [
      _SleepDateTimePickers(
        startTime: state.startTime,
        endTime: state.endTime,
        onChanged: (st, et) => setState(() {
          state.startTime = st;
          state.endTime = et;
        }),
      ),
      if (recordToEdit != null) ...[
        const SizedBox(height: 16),
        _EndSwitch(
          endTime: state.endTime,
          onChanged: (et) => setState(() => state.endTime = et),
        ),
      ],
      const SizedBox(height: 16),
      _QualitySelector(
        selectedQuality: state.quality,
        onChanged: (q) => setState(() => state.quality = q),
      ),
      const SizedBox(height: 16),
      SheetTextField(
        controller: state.notesController,
        label: '备注',
        hint: '选填',
        maxLines: 2,
      ),
    ];
  }

  @override
  Future<void> saveRecord(BuildContext context, SleepRecordState state) async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) return;

    final record = SleepRecord(
      id: recordToEdit?.id,
      babyId: currentBaby.id,
      startTime: state.startTime,
      endTime: state.endTime,
      quality: state.quality,
      notes: state.notesController.text.isEmpty ? null : state.notesController.text,
    );

    final recordsProvider = Provider.of<RecordsProvider>(context, listen: false);
    if (recordToEdit != null) {
      await recordsProvider.updateSleepRecord(record);
    } else {
      await recordsProvider.addSleepRecord(record);
    }
  }
}

/// 睡眠记录表单状态
///
/// 存储睡眠记录表单的临时数据，
/// 包括开始时间、结束时间、睡眠质量和备注。
class SleepRecordState {
  DateTime startTime;
  DateTime? endTime;
  int quality;
  TextEditingController notesController;

  SleepRecordState({
    DateTime? startTime,
    this.endTime,
    this.quality = 3,
    TextEditingController? notesController,
  })  : startTime = startTime ?? DateTime.now(),
        notesController = notesController ?? TextEditingController();

  factory SleepRecordState.fromRecord(SleepRecord record) {
    return SleepRecordState(
      startTime: record.startTime,
      endTime: record.endTime,
      quality: record.quality ?? 3,
      notesController: TextEditingController(text: record.notes ?? ''),
    );
  }
}

/// 睡眠日期时间选择器组组件
///
/// 同时显示开始时间和结束时间的两个选择器。
class _SleepDateTimePickers extends StatelessWidget {
  final DateTime startTime;
  final DateTime? endTime;
  final void Function(DateTime start, DateTime? end) onChanged;

  const _SleepDateTimePickers({
    required this.startTime,
    required this.endTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '睡眠时间',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _DateTimeTile(
              label: '开始',
              dateTime: startTime,
              primaryColor: const Color(0xFF64B5F6),
              onChanged: (dt) => onChanged(dt, endTime),
            )),
            const SizedBox(width: 12),
            Expanded(child: _DateTimeTile(
              label: '结束',
              dateTime: endTime ?? DateTime.now(),
              primaryColor: const Color(0xFF64B5F6),
              enabled: endTime != null,
              onChanged: endTime != null ? (dt) => onChanged(startTime, dt) : null,
            )),
          ],
        ),
      ],
    );
  }
}

/// 日期时间选择瓦片组件
///
/// 显示日期和时间的单个选择器。
class _DateTimeTile extends StatelessWidget {
  final String label;
  final DateTime dateTime;
  final Color primaryColor;
  final bool enabled;
  final ValueChanged<DateTime>? onChanged;

  const _DateTimeTile({
    required this.label,
    required this.dateTime,
    required this.primaryColor,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () async {
              final date = await showDatePicker(
                context: context,
                initialDate: dateTime,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: primaryColor,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: const Color(0xFF2D2D2D),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date == null || onChanged == null) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(dateTime),
              );
              if (time != null) {
                onChanged!(DateTime(date.year, date.month, date.day, time.hour, time.minute));
              }
            }
          : null,
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
                  style: TextStyle(
                    fontSize: 13,
                    color: enabled ? const Color(0xFF2D2D2D) : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 睡眠结束开关组件
///
/// 切换睡眠是否已结束的状态。
class _EndSwitch extends StatelessWidget {
  final DateTime? endTime;
  final ValueChanged<DateTime?> onChanged;

  const _EndSwitch({
    required this.endTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
}

/// 睡眠质量选择器组件
///
/// 5星评分选择器，用于评价睡眠质量。
class _QualitySelector extends StatelessWidget {
  final int selectedQuality;
  final ValueChanged<int> onChanged;

  const _QualitySelector({
    required this.selectedQuality,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '睡眠质量',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
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
                  border: Border.all(
                    color: isSelected ? const Color(0xFF64B5F6) : Colors.grey[200]!,
                    width: isSelected ? 1.5 : 1,
                  ),
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
}
