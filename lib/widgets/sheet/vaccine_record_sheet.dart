import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vaccine_record.dart';
import '../../models/vaccine_plan.dart';
import '../../providers/vaccine_provider.dart';
import '../../providers/baby_provider.dart';
import 'components/components.dart';

/// 疫苗接种记录表单
class VaccineRecordSheet extends StatefulWidget {
  final VaccineRecord? recordToEdit;
  final VaccineScheduleItem? scheduleItem; // 从计划项快速添加

  const VaccineRecordSheet({
    super.key,
    this.recordToEdit,
    this.scheduleItem,
  });

  @override
  State<VaccineRecordSheet> createState() => _VaccineRecordSheetState();

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => this,
    );
  }
}

class _VaccineRecordSheetState extends State<VaccineRecordSheet> {
  late VaccinePlanItem? _selectedVaccine;
  late DateTime _vaccinationTime;
  late String _status;
  final _hospitalController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      _selectedVaccine = VaccinePlanData.findByName(widget.recordToEdit!.vaccineName);
      _vaccinationTime = widget.recordToEdit!.vaccinationTime;
      _status = widget.recordToEdit!.status;
      _hospitalController.text = widget.recordToEdit!.hospital ?? '';
      _batchNumberController.text = widget.recordToEdit!.batchNumber ?? '';
      _notesController.text = widget.recordToEdit!.notes ?? '';
    } else if (widget.scheduleItem != null) {
      _selectedVaccine = widget.scheduleItem!.vaccine;
      _vaccinationTime = DateTime.now();
      _status = VaccineRecord.statusCompleted;
    } else {
      _selectedVaccine = null;
      _vaccinationTime = DateTime.now();
      _status = VaccineRecord.statusPending;
    }
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              SheetHeader(
                title: widget.recordToEdit != null ? '编辑疫苗记录' : '添加疫苗记录',
                subtitle: '记录宝宝疫苗接种情况',
                primaryColor: const Color(0xFF26A69A),
              ),
              const SizedBox(height: 24),

              // 疫苗选择器
              _buildVaccineSelector(),
              const SizedBox(height: 16),

              // 接种时间
              SheetDatePicker(
                label: '接种时间',
                selectedDateTime: _vaccinationTime,
                onChanged: (dt) => setState(() => _vaccinationTime = dt),
                primaryColor: const Color(0xFF26A69A),
              ),
              const SizedBox(height: 16),

              // 接种状态
              _buildStatusSelector(),
              const SizedBox(height: 16),

              // 接种机构
              SheetTextField(
                controller: _hospitalController,
                label: '接种机构',
                hint: '选填',
              ),
              const SizedBox(height: 16),

              // 疫苗批号
              SheetTextField(
                controller: _batchNumberController,
                label: '疫苗批号',
                hint: '选填',
              ),
              const SizedBox(height: 16),

              // 备注
              SheetTextField(
                controller: _notesController,
                label: '备注',
                hint: '添加备注...',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              SheetActionButtons(
                onCancel: () => Navigator.pop(context),
                onSave: _handleSave,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVaccineSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '疫苗',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showVaccinePicker,
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
                    _selectedVaccine?.name ?? '请选择疫苗',
                    style: TextStyle(
                      fontSize: 15,
                      color: _selectedVaccine != null ? Colors.grey[700] : Colors.grey[400],
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[500]),
              ],
            ),
          ),
        ),
        if (_selectedVaccine != null) ...[
          const SizedBox(height: 8),
          Text(
            '${_selectedVaccine!.englishName ?? ''} - ${_selectedVaccine!.notes}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '接种状态',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatusChip('已完成', VaccineRecord.statusCompleted, const Color(0xFF26A69A)),
            const SizedBox(width: 8),
            _buildStatusChip('待接种', VaccineRecord.statusPending, Colors.orange[400]!),
            const SizedBox(width: 8),
            _buildStatusChip('已过期', VaccineRecord.statusOverdue, Colors.red[400]!),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    final isSelected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? color : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showVaccinePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            const SheetHandle(),
            const SizedBox(height: 16),
            const Text(
              '选择疫苗',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: VaccinePlanData.nationalVaccines.length,
                itemBuilder: (context, index) {
                  final vaccine = VaccinePlanData.nationalVaccines[index];
                  return ListTile(
                    title: Text(vaccine.name),
                    subtitle: Text(
                      '${vaccine.englishName ?? ''} - ${vaccine.notes}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    trailing: _selectedVaccine?.code == vaccine.code
                        ? const Icon(Icons.check, color: Color(0xFF26A69A))
                        : null,
                    onTap: () {
                      setState(() => _selectedVaccine = vaccine);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_selectedVaccine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请选择疫苗'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先添加宝宝信息'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final record = VaccineRecord(
        id: widget.recordToEdit?.id,
        babyId: currentBaby.id,
        vaccinationTime: _vaccinationTime,
        vaccineName: _selectedVaccine!.name,
        vaccineCode: _selectedVaccine!.code,
        status: _status,
        hospital: _hospitalController.text.isEmpty ? null : _hospitalController.text,
        batchNumber: _batchNumberController.text.isEmpty ? null : _batchNumberController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final vaccineProvider = Provider.of<VaccineProvider>(context, listen: false);
      if (widget.recordToEdit != null) {
        await vaccineProvider.updateVaccineRecord(record);
      } else {
        await vaccineProvider.addVaccineRecord(record);
      }

      // 如果是已完成状态，刷新提醒
      if (_status == VaccineRecord.statusCompleted && currentBaby != null) {
        await vaccineProvider.refreshReminders(currentBaby);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
