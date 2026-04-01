import 'dart:developer';

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
  final CustomVaccineScheduleItem? customVaccineItem; // 从自定义疫苗待接种项添加

  const VaccineRecordSheet({
    super.key,
    this.recordToEdit,
    this.scheduleItem,
    this.customVaccineItem,
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
  final _hospitalController = TextEditingController();
  final _injectionSiteController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  // 自定义疫苗相关
  bool _isCustomVaccine = false;
  final _vaccineNameController = TextEditingController();
  final _diseaseController = TextEditingController();
  int _totalDoses = 1;
  int _doseIntervalMonths = 1;
  int _firstDoseMonth = 0;

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      _selectedVaccine = VaccinePlanData.findByName(widget.recordToEdit!.vaccineName);
      _vaccinationTime = widget.recordToEdit!.vaccinationTime;
      _hospitalController.text = widget.recordToEdit!.hospital ?? '';
      _injectionSiteController.text = widget.recordToEdit!.injectionSite ?? '';
      _notesController.text = widget.recordToEdit!.notes ?? '';
      // 如果是编辑自定义疫苗
      if (widget.recordToEdit!.isCustom) {
        _isCustomVaccine = true;
        _vaccineNameController.text = widget.recordToEdit!.vaccineName;
        _diseaseController.text = widget.recordToEdit!.disease ?? '';
        _totalDoses = widget.recordToEdit!.totalDoses ?? 1;
        _doseIntervalMonths = widget.recordToEdit!.doseIntervalMonths ?? 1;
        _firstDoseMonth = widget.recordToEdit!.firstDoseMonth ?? 0;
      }
    } else if (widget.scheduleItem != null) {
      _selectedVaccine = widget.scheduleItem!.vaccine;
      _vaccinationTime = DateTime.now();
    } else if (widget.customVaccineItem != null) {
      // 从自定义疫苗待接种项添加
      _isCustomVaccine = true;
      _vaccineNameController.text = widget.customVaccineItem!.record.vaccineName;
      _diseaseController.text = widget.customVaccineItem!.record.disease ?? '';
      _totalDoses = widget.customVaccineItem!.record.totalDoses ?? 1;
      _doseIntervalMonths = widget.customVaccineItem!.record.doseIntervalMonths ?? 1;
      _firstDoseMonth = widget.customVaccineItem!.record.firstDoseMonth ?? 0;
      _vaccinationTime = DateTime.now();
    } else {
      _selectedVaccine = null;
      _vaccinationTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _injectionSiteController.dispose();
    _notesController.dispose();
    _vaccineNameController.dispose();
    _diseaseController.dispose();
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
                title: widget.recordToEdit != null ? '编辑疫苗记录' : '记录接种',
                subtitle: _isCustomVaccine
                    ? '${_vaccineNameController.text} ${_totalDoses > 1 ? '第${_getDoseNumber()}针' : ''}'
                    : (_selectedVaccine != null
                        ? '${_selectedVaccine!.name} ${_selectedVaccine!.totalDoses > 1 ? '第${_getDoseNumber()}针' : ''}'
                        : '记录宝宝疫苗接种情况'),
                primaryColor: const Color(0xFF26A69A),
              ),
              const SizedBox(height: 24),

              // 如果不是编辑模式，显示自定义疫苗开关
              if (widget.recordToEdit == null && widget.scheduleItem == null) ...[
                _buildCustomVaccineToggle(),
                const SizedBox(height: 16),
              ],

              // 自定义疫苗表单
              if (_isCustomVaccine) ...[
                _buildCustomVaccineFields(),
                const SizedBox(height: 16),
              ] else ...[
                // 内置疫苗选择（仅在非编辑模式显示）
                if (widget.recordToEdit == null) ...[
                  _buildVaccineSelector(),
                  const SizedBox(height: 16),
                ],
              ],

              // 接种时间
              SheetDatePicker(
                label: '接种时间',
                selectedDateTime: _vaccinationTime,
                onChanged: (dt) => setState(() => _vaccinationTime = dt),
                primaryColor: const Color(0xFF26A69A),
              ),
              const SizedBox(height: 16),

              // 接种机构
              SheetTextField(
                controller: _hospitalController,
                label: '接种机构',
                hint: '选填',
              ),
              const SizedBox(height: 16),

              // 接种位置
              SheetTextField(
                controller: _injectionSiteController,
                label: '接种位置',
                hint: '如：左上臂',
              ),
              const SizedBox(height: 16),

              // 备注（仅自定义疫苗显示）
              if (_isCustomVaccine) ...[
                SheetTextField(
                  controller: _notesController,
                  label: '备注',
                  hint: '选填',
                ),
                const SizedBox(height: 16),
              ],

              SheetActionButtons(
                onCancel: () => Navigator.pop(context),
                onSave: _handleSave,
                isLoading: _isLoading,
              ),
              // 编辑时显示删除按钮
              if (widget.recordToEdit != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _handleDelete,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '删除接种记录',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建自定义疫苗开关
  Widget _buildCustomVaccineToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.add_circle_outlined, color: Colors.purple[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '自定义疫苗（免疫规划/非免疫规划之外的疫苗）',
              style: TextStyle(
                fontSize: 14,
                color: Colors.purple[700],
              ),
            ),
          ),
          Switch(
            value: _isCustomVaccine,
            onChanged: (value) => setState(() => _isCustomVaccine = value),
            activeTrackColor: Colors.purple[200],
          ),
        ],
      ),
    );
  }

  /// 构建自定义疫苗表单字段
  Widget _buildCustomVaccineFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 疫苗名称
        SheetTextField(
          controller: _vaccineNameController,
          label: '疫苗名称',
          hint: '请输入疫苗名称',
        ),
        const SizedBox(height: 16),

        // 预防疾病
        SheetTextField(
          controller: _diseaseController,
          label: '预防疾病',
          hint: '选填，如：手足口病',
        ),
        const SizedBox(height: 16),

        // 总剂次和间隔月数
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                label: '总剂次',
                value: _totalDoses,
                min: 1,
                max: 10,
                onChanged: (v) => setState(() => _totalDoses = v),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                label: '间隔月数',
                value: _doseIntervalMonths,
                min: 1,
                max: 24,
                onChanged: (v) => setState(() => _doseIntervalMonths = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 首剂推荐月龄
        _buildNumberField(
          label: '首剂推荐月龄',
          value: _firstDoseMonth,
          min: 0,
          max: 72,
          onChanged: (v) => setState(() => _firstDoseMonth = v),
          suffix: '月龄',
        ),
      ],
    );
  }

  /// 构建数字选择字段
  Widget _buildNumberField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                iconSize: 20,
              ),
              Expanded(
                child: Text(
                  suffix != null ? '$value$suffix' : '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: value < max ? () => onChanged(value + 1) : null,
                iconSize: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建内置疫苗选择器
  Widget _buildVaccineSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择疫苗',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VaccinePlanItem>(
              value: _selectedVaccine,
              isExpanded: true,
              hint: const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text('请选择疫苗'),
              ),
              items: VaccinePlanData.allVaccines.map((vaccine) {
                return DropdownMenuItem(
                  value: vaccine,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${vaccine.name}（${vaccine.isFree ? "免费" : "自费"}）',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedVaccine = value),
            ),
          ),
        ),
      ],
    );
  }

  int _getDoseNumber() {
    // 从 scheduleItem 或 recordToEdit 或 customVaccineItem 获取剂次
    if (widget.scheduleItem != null) {
      return widget.scheduleItem!.doseNumber;
    }
    if (widget.customVaccineItem != null) {
      return widget.customVaccineItem!.doseNumber;
    }
    if (widget.recordToEdit != null) {
      return widget.recordToEdit!.doseNumber ?? 1;
    }
    return 1;
  }

  Future<void> _handleSave() async {
    // 验证
    if (_isCustomVaccine) {
      if (_vaccineNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请输入疫苗名称'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } else if (_selectedVaccine == null) {
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

    // 在 await 之前保存 ScaffoldMessenger 和 Navigator 引用
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      VaccineRecord record;
      if (_isCustomVaccine) {
        record = VaccineRecord(
          id: widget.recordToEdit?.id,
          babyId: currentBaby.id,
          vaccinationTime: _vaccinationTime,
          vaccineName: _vaccineNameController.text,
          vaccineCode: null, // 自定义疫苗没有code
          status: VaccineRecord.statusCompleted,
          hospital: _hospitalController.text.isEmpty ? null : _hospitalController.text,
          injectionSite: _injectionSiteController.text.isEmpty ? null : _injectionSiteController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          doseNumber: _getDoseNumber(),
          isCustom: true,
          totalDoses: _totalDoses,
          doseIntervalMonths: _doseIntervalMonths,
          firstDoseMonth: _firstDoseMonth,
          disease: _diseaseController.text.isEmpty ? null : _diseaseController.text,
        );
      } else {
        record = VaccineRecord(
          id: widget.recordToEdit?.id,
          babyId: currentBaby.id,
          vaccinationTime: _vaccinationTime,
          vaccineName: _selectedVaccine!.name,
          vaccineCode: _selectedVaccine!.code,
          status: VaccineRecord.statusCompleted,
          hospital: _hospitalController.text.isEmpty ? null : _hospitalController.text,
          injectionSite: _injectionSiteController.text.isEmpty ? null : _injectionSiteController.text,
          doseNumber: _getDoseNumber(),
        );
      }

      final vaccineProvider = Provider.of<VaccineProvider>(context, listen: false);
      if (widget.recordToEdit != null) {
        await vaccineProvider.updateVaccineRecord(record);
      } else {
        await vaccineProvider.addVaccineRecord(record);
      }

      // 刷新提醒
      await vaccineProvider.refreshReminders(currentBaby);
    } catch (e) {
      log("保存疫苗记录失败: $e");
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    // 在 finally 之后关闭 sheet（无论成功或失败）
    if (mounted) {
      navigator.pop();
    }
  }

  /// 删除接种记录
  Future<void> _handleDelete() async {
    if (widget.recordToEdit == null) return;

    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除接种记录'),
        content: Text('确定要删除 ${widget.recordToEdit!.vaccineName} 的接种记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // 关闭对话框
              final vaccineProvider = Provider.of<VaccineProvider>(context, listen: false);
              final babyProvider = Provider.of<BabyProvider>(context, listen: false);
              final currentBaby = babyProvider.currentBaby;

              await vaccineProvider.deleteVaccineRecord(widget.recordToEdit!.id);

              if (currentBaby != null) {
                await vaccineProvider.refreshReminders(currentBaby);
              }

              navigator.pop(); // 关闭编辑表单
            },
            child: Text('删除', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}
