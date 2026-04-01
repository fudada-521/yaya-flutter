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
  final _hospitalController = TextEditingController();
  final _injectionSiteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      _selectedVaccine = VaccinePlanData.findByName(widget.recordToEdit!.vaccineName);
      _vaccinationTime = widget.recordToEdit!.vaccinationTime;
      _hospitalController.text = widget.recordToEdit!.hospital ?? '';
      _injectionSiteController.text = widget.recordToEdit!.injectionSite ?? '';
    } else if (widget.scheduleItem != null) {
      _selectedVaccine = widget.scheduleItem!.vaccine;
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
                subtitle: _selectedVaccine != null
                    ? '${_selectedVaccine!.name} ${_selectedVaccine!.totalDoses > 1 ? '第${_getDoseNumber()}针' : ''}'
                    : '记录宝宝疫苗接种情况',
                primaryColor: const Color(0xFF26A69A),
              ),
              const SizedBox(height: 24),

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
              const SizedBox(height: 24),

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

  int _getDoseNumber() {
    // 从 scheduleItem 或 recordToEdit 获取剂次
    if (widget.scheduleItem != null) {
      return widget.scheduleItem!.doseNumber;
    }
    if (widget.recordToEdit != null) {
      // 优先使用记录中存储的 doseNumber
      if (widget.recordToEdit!.doseNumber != null) {
        return widget.recordToEdit!.doseNumber!;
      }
      // 回退到日期推断逻辑（兼容旧数据）
      final vaccine = VaccinePlanData.findByName(widget.recordToEdit!.vaccineName);
      if (vaccine != null) {
        for (int i = 0; i < vaccine.recommendedMonths.length; i++) {
          if (vaccine.recommendedMonths[i] == widget.recordToEdit!.vaccinationTime.month) {
            return i + 1;
          }
        }
      }
    }
    return 1;
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

    // 在 await 之前保存 ScaffoldMessenger 和 Navigator 引用
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final record = VaccineRecord(
        id: widget.recordToEdit?.id,
        babyId: currentBaby.id,
        vaccinationTime: _vaccinationTime,
        vaccineName: _selectedVaccine!.name,
        vaccineCode: _selectedVaccine!.code,
        status: VaccineRecord.statusCompleted, // 默认已完成
        hospital: _hospitalController.text.isEmpty ? null : _hospitalController.text,
        injectionSite: _injectionSiteController.text.isEmpty ? null : _injectionSiteController.text,
        doseNumber: widget.scheduleItem?.doseNumber ?? widget.recordToEdit?.doseNumber,
      );

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
