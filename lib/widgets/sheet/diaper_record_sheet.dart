import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/diaper_record.dart';
import '../../providers/records_provider.dart';
import '../../providers/baby_provider.dart';
import 'base_record_sheet.dart';
import 'components/components.dart';

class DiaperRecordSheet extends BaseRecordSheet<DiaperRecordState> {
  final DiaperRecord? recordToEdit;

  DiaperRecordSheet({
    super.key,
    this.recordToEdit,
  }) : super(
          title: recordToEdit != null ? '编辑换尿布记录' : '添加尿布记录',
          primaryColor: const Color(0xFF81C784),
          initialData: recordToEdit != null
              ? DiaperRecordState.fromRecord(recordToEdit)
              : null,
        );

  @override
  DiaperRecordState createInitialState() {
    return DiaperRecordState();
  }

  @override
  List<Widget> buildForm(BuildContext context, DiaperRecordState state, StateSetter setState) {
    return [
      SheetDatePicker(
        label: '更换时间',
        selectedDateTime: state.changeTime,
        onChanged: (dt) => setState(() => state.changeTime = dt),
        primaryColor: const Color(0xFF81C784),
      ),
      const SizedBox(height: 20),
      SheetSegmentedSelector(
        label: '尿布类型',
        selectedValue: state.type,
        onChanged: (type) {
          if (type != null) setState(() => state.type = type);
        },
        allowDeselect: false,
        options: const [
          SheetSegmentOption(value: 'wet', label: '湿尿布', icon: Icons.water_drop, color: Color(0xFF64B5F6)),
          SheetSegmentOption(value: 'dirty', label: '脏尿布', icon: Icons.cloud, color: Color(0xFF81C784)),
          SheetSegmentOption(value: 'both', label: '都有', icon: Icons.all_inclusive, color: Color(0xFFFF8A65)),
        ],
      ),
      const SizedBox(height: 16),
      SheetSegmentedSelector(
        label: '状态',
        selectedValue: state.status,
        onChanged: (status) {
          if (status != null) setState(() => state.status = status);
        },
        allowDeselect: false,
        options: const [
          SheetSegmentOption(value: 'normal', label: '正常', color: Color(0xFF81C784)),
          SheetSegmentOption(value: 'loose', label: '稀便', color: Color(0xFFFF8A65)),
          SheetSegmentOption(value: 'constipation', label: '便秘', color: Color(0xFFBA68C8)),
        ],
      ),
    ];
  }

  @override
  Future<void> saveRecord(BuildContext context, DiaperRecordState state) async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) return;

    final record = DiaperRecord(
      id: recordToEdit?.id,
      babyId: currentBaby.id,
      changeTime: state.changeTime,
      type: state.type,
      status: state.status,
    );

    final recordsProvider = Provider.of<RecordsProvider>(context, listen: false);
    if (recordToEdit != null) {
      await recordsProvider.updateDiaperRecord(record);
    } else {
      await recordsProvider.addDiaperRecord(record);
    }
  }
}

class DiaperRecordState {
  DateTime changeTime;
  String type;
  String status;

  DiaperRecordState({
    DateTime? changeTime,
    this.type = 'wet',
    this.status = 'normal',
  }) : changeTime = changeTime ?? DateTime.now();

  factory DiaperRecordState.fromRecord(DiaperRecord record) {
    return DiaperRecordState(
      changeTime: record.changeTime,
      type: record.type,
      status: record.status,
    );
  }
}
