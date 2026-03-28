import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/growth_record.dart';
import '../../providers/records_provider.dart';
import '../../providers/baby_provider.dart';
import 'base_record_sheet.dart';
import 'components/components.dart';

class GrowthRecordSheet extends BaseRecordSheet<GrowthRecordState> {
  final GrowthRecord? recordToEdit;

  GrowthRecordSheet({
    super.key,
    this.recordToEdit,
  }) : super(
          title: recordToEdit != null ? '编辑成长记录' : '添加成长记录',
          primaryColor: const Color(0xFFBA68C8),
          initialData: recordToEdit != null
              ? GrowthRecordState.fromRecord(recordToEdit)
              : null,
        );

  @override
  GrowthRecordState createInitialState() {
    return GrowthRecordState();
  }

  @override
  List<Widget> buildForm(BuildContext context, GrowthRecordState state, StateSetter setState) {
    return [
      _GrowthDatePicker(
        selectedDate: state.recordDate,
        onChanged: (dt) => setState(() => state.recordDate = dt),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: SheetTextField(
              controller: state.weightController,
              label: '体重',
              hint: 'kg',
              suffix: 'kg',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SheetTextField(
              controller: state.heightController,
              label: '身高',
              hint: 'cm',
              suffix: 'cm',
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      SheetTextField(
        controller: state.headCircumferenceController,
        label: '头围',
        hint: 'cm',
        suffix: 'cm',
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
  Future<void> saveRecord(BuildContext context, GrowthRecordState state) async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) return;

    final record = GrowthRecord(
      id: recordToEdit?.id,
      babyId: currentBaby.id,
      recordDate: state.recordDate,
      weight: double.tryParse(state.weightController.text),
      height: double.tryParse(state.heightController.text),
      headCircumference: double.tryParse(state.headCircumferenceController.text),
      notes: state.notesController.text.isEmpty ? null : state.notesController.text,
    );

    final recordsProvider = Provider.of<RecordsProvider>(context, listen: false);
    if (recordToEdit != null) {
      await recordsProvider.updateGrowthRecord(record);
    } else {
      await recordsProvider.addGrowthRecord(record);
    }
  }
}

class GrowthRecordState {
  DateTime recordDate;
  TextEditingController weightController;
  TextEditingController heightController;
  TextEditingController headCircumferenceController;
  TextEditingController notesController;

  GrowthRecordState({
    DateTime? recordDate,
    TextEditingController? weightController,
    TextEditingController? heightController,
    TextEditingController? headCircumferenceController,
    TextEditingController? notesController,
  })  : recordDate = recordDate ?? DateTime.now(),
        weightController = weightController ?? TextEditingController(),
        heightController = heightController ?? TextEditingController(),
        headCircumferenceController = headCircumferenceController ?? TextEditingController(),
        notesController = notesController ?? TextEditingController();

  factory GrowthRecordState.fromRecord(GrowthRecord record) {
    return GrowthRecordState(
      recordDate: record.recordDate,
      weightController: TextEditingController(text: record.weight?.toString() ?? ''),
      heightController: TextEditingController(text: record.height?.toString() ?? ''),
      headCircumferenceController: TextEditingController(text: record.headCircumference?.toString() ?? ''),
      notesController: TextEditingController(text: record.notes ?? ''),
    );
  }
}

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
