import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/feeding_record.dart';
import '../../providers/records_provider.dart';
import '../../providers/baby_provider.dart';
import 'base_record_sheet.dart';
import 'components/components.dart';

class FeedingRecordSheet extends BaseRecordSheet<FeedingRecordState> {
  final FeedingRecord? recordToEdit;

  FeedingRecordSheet({
    super.key,
    this.recordToEdit,
  }) : super(
          title: recordToEdit != null ? '编辑喂养记录' : '添加喂养记录',
          initialData: recordToEdit != null
              ? FeedingRecordState.fromRecord(recordToEdit)
              : null,
        );

  @override
  FeedingRecordState createInitialState() {
    return FeedingRecordState();
  }

  @override
  List<Widget> buildForm(BuildContext context, FeedingRecordState state, StateSetter setState) {
    return [
      SheetDatePicker(
        label: '喂养时间',
        selectedDateTime: state.feedTime,
        onChanged: (dt) => setState(() => state.feedTime = dt),
        primaryColor: const Color(0xFFFF8A65),
      ),
      const SizedBox(height: 20),
      SheetChipSelector(
        label: '喂养类型',
        selectedValue: state.type,
        onChanged: (type) {
          if (type != null) {
            setState(() => state.type = type);
          }
        },
        options: const [
          SheetChipOption(value: 'breast', label: '母乳亲喂', icon: Icons.favorite, color: Color(0xFFF48FB1)),
          SheetChipOption(value: 'pumped', label: '母乳瓶喂', icon: Icons.local_drink, color: Color(0xFFE91E63)),
          SheetChipOption(value: 'bottle', label: '奶粉', icon: Icons.local_dining, color: Color(0xFFFF8A65)),
          SheetChipOption(value: 'solid', label: '辅食', icon: Icons.restaurant, color: Color(0xFF81C784)),
        ],
      ),
      if (state.type == 'breast') ...[
        const SizedBox(height: 16),
        SheetSegmentedSelector(
          label: '喂养方式',
          selectedValue: state.method,
          onChanged: (method) => setState(() => state.method = method),
          options: const [
            SheetSegmentOption(value: 'left', label: '左侧', color: Color(0xFFF48FB1)),
            SheetSegmentOption(value: 'right', label: '右侧', color: Color(0xFFF48FB1)),
            SheetSegmentOption(value: 'mixed', label: '混合', color: Color(0xFFF48FB1)),
          ],
        ),
        const SizedBox(height: 16),
        _DurationSelector(
          selectedDuration: state.duration,
          onChanged: (d) => setState(() => state.duration = d),
        ),
      ],
      if (state.type != 'breast') ...[
        const SizedBox(height: 16),
        SheetTextField(
          controller: state.amountController,
          label: '奶量',
          hint: 'ml',
          suffix: 'ml',
        ),
      ],
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
  Future<void> saveRecord(BuildContext context, FeedingRecordState state) async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) return;

    final record = FeedingRecord(
      id: recordToEdit?.id,
      babyId: currentBaby.id,
      feedTime: state.feedTime,
      amount: double.tryParse(state.amountController.text),
      type: state.type,
      method: state.type == 'breast' ? state.method : null,
      duration: state.type == 'breast' ? state.duration : null,
      notes: state.notesController.text.isEmpty ? null : state.notesController.text,
    );

    final recordsProvider = Provider.of<RecordsProvider>(context, listen: false);
    if (recordToEdit != null) {
      await recordsProvider.updateFeedingRecord(record);
    } else {
      await recordsProvider.addFeedingRecord(record);
    }
  }
}

class FeedingRecordState {
  DateTime feedTime;
  String type;
  String? method;
  int? duration;
  TextEditingController amountController;
  TextEditingController notesController;

  FeedingRecordState({
    DateTime? feedTime,
    this.type = 'breast',
    this.method,
    this.duration,
    TextEditingController? amountController,
    TextEditingController? notesController,
  })  : feedTime = feedTime ?? DateTime.now(),
        amountController = amountController ?? TextEditingController(),
        notesController = notesController ?? TextEditingController();

  factory FeedingRecordState.fromRecord(FeedingRecord record) {
    return FeedingRecordState(
      feedTime: record.feedTime,
      type: record.type,
      method: record.method,
      duration: record.duration,
      amountController: TextEditingController(text: record.amount?.toString() ?? ''),
      notesController: TextEditingController(text: record.notes ?? ''),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final int? selectedDuration;
  final ValueChanged<int?> onChanged;

  const _DurationSelector({
    required this.selectedDuration,
    required this.onChanged,
  });

  static const List<int> _presetDurations = [5, 10, 15, 20, 25, 30, 40, 50, 60];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '喂养时长',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetDurations.map((minutes) {
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
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF48FB1) : Colors.grey[200]!,
                    width: isSelected ? 1.5 : 1,
                  ),
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
}
