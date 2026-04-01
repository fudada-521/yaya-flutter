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
  late int _selectedDoseNumber; // 选中的剂次
  late DateTime _vaccinationTime;
  final _hospitalController = TextEditingController();
  final _injectionSiteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      _selectedVaccine = VaccinePlanData.findByName(widget.recordToEdit!.vaccineName);
      _selectedDoseNumber = widget.recordToEdit!.doseNumber ?? 1;
      _vaccinationTime = widget.recordToEdit!.vaccinationTime;
      _hospitalController.text = widget.recordToEdit!.hospital ?? '';
      _injectionSiteController.text = widget.recordToEdit!.injectionSite ?? '';
    } else if (widget.scheduleItem != null) {
      _selectedVaccine = widget.scheduleItem!.vaccine;
      _selectedDoseNumber = widget.scheduleItem!.doseNumber;
      _vaccinationTime = DateTime.now();
    } else {
      _selectedVaccine = null;
      _selectedDoseNumber = 1;
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

              // 内置疫苗选择（仅在非编辑模式显示）
              if (widget.recordToEdit == null) ...[
                _buildVaccineSelector(),
                const SizedBox(height: 16),
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

  /// 构建内置疫苗选择器
  Widget _buildVaccineSelector() {
    final hasVaccine = _selectedVaccine != null;
    final totalDoses = _selectedVaccine?.totalDoses ?? 0;
    final showDose = hasVaccine && totalDoses > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择疫苗',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showVaccinePicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasVaccine ? const Color(0xFF26A69A) : Colors.grey[300]!,
                width: hasVaccine ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.vaccines,
                    color: Color(0xFF26A69A),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedVaccine?.name ?? '请选择疫苗',
                        style: TextStyle(
                          fontSize: 15,
                          color: hasVaccine
                              ? const Color(0xFF2D2D2D)
                              : Colors.grey[400],
                          fontWeight: hasVaccine
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      if (showDose)
                        Text(
                          '第$_selectedDoseNumber / $totalDoses 剂',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasVaccine)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedVaccine!.isFree
                          ? Colors.green[50]
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _selectedVaccine!.isFree ? '免费' : '自费',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _selectedVaccine!.isFree
                            ? Colors.green[600]
                            : Colors.blue[600],
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 显示疫苗选择弹窗
  void _showVaccinePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VaccinePickerSheet(
        selectedVaccine: _selectedVaccine,
        selectedDoseNumber: _selectedDoseNumber,
        onSelected: (vaccine, doseNumber) {
          setState(() {
            _selectedVaccine = vaccine;
            _selectedDoseNumber = doseNumber;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  int _getDoseNumber() {
    // 优先使用用户选择的剂次
    if (_selectedVaccine != null) {
      return _selectedDoseNumber;
    }
    // 从 scheduleItem 或 recordToEdit 获取剂次
    if (widget.scheduleItem != null) {
      return widget.scheduleItem!.doseNumber;
    }
    if (widget.recordToEdit != null) {
      return widget.recordToEdit!.doseNumber ?? 1;
    }
    return 1;
  }

  Future<void> _handleSave() async {
    // 验证
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
        status: VaccineRecord.statusCompleted,
        hospital: _hospitalController.text.isEmpty ? null : _hospitalController.text,
        injectionSite: _injectionSiteController.text.isEmpty ? null : _injectionSiteController.text,
        doseNumber: _getDoseNumber(),
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

/// 疫苗选择弹窗
class _VaccinePickerSheet extends StatefulWidget {
  final VaccinePlanItem? selectedVaccine;
  final int selectedDoseNumber;
  final Function(VaccinePlanItem vaccine, int doseNumber) onSelected;

  const _VaccinePickerSheet({
    this.selectedVaccine,
    required this.selectedDoseNumber,
    required this.onSelected,
  });

  @override
  State<_VaccinePickerSheet> createState() => _VaccinePickerSheetState();
}

class _VaccinePickerSheetState extends State<_VaccinePickerSheet> {
  String _searchQuery = '';
  bool _showOnlyFree = false;

  List<VaccinePlanItem> get _filteredVaccines {
    return VaccinePlanData.allVaccines.where((vaccine) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!vaccine.name.toLowerCase().contains(query)) {
          return false;
        }
      }
      // 免费过滤
      if (_showOnlyFree && !vaccine.isFree) {
        return false;
      }
      return true;
    }).toList();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const SheetHandle(),
          const SizedBox(height: 16),
          // 标题
          const Text(
            '选择疫苗',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: '搜索疫苗名称',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 免费/全部切换
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildFilterChip('全部', !_showOnlyFree, () {
                  setState(() => _showOnlyFree = false);
                }),
                const SizedBox(width: 8),
                _buildFilterChip('仅免费', _showOnlyFree, () {
                  setState(() => _showOnlyFree = true);
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 疫苗列表
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filteredVaccines.length,
                itemBuilder: (context, index) {
                  final vaccine = _filteredVaccines[index];
                  final isSelected = widget.selectedVaccine?.name == vaccine.name;
                  return _buildVaccineItem(vaccine, isSelected);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26A69A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildVaccineItem(VaccinePlanItem vaccine, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (vaccine.totalDoses > 1) {
          // 多剂次疫苗，弹出剂次选择
          _showDosePicker(vaccine);
        } else {
          // 单剂次疫苗，直接返回
          widget.onSelected(vaccine, 1);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26A69A).withAlpha(13) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF26A69A) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: vaccine.isFree
                    ? Colors.green.withAlpha(25)
                    : Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                vaccine.isFree ? Icons.shield_outlined : Icons.vaccines_outlined,
                color: vaccine.isFree ? Colors.green : Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vaccine.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '共${vaccine.totalDoses}剂',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: vaccine.isFree ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vaccine.isFree ? '免费' : '自费',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: vaccine.isFree ? Colors.green[600] : Colors.blue[600],
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle,
                color: Color(0xFF26A69A),
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 显示剂次选择弹窗
  void _showDosePicker(VaccinePlanItem vaccine) {
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
            const SizedBox(height: 12),
            const SheetHandle(),
            const SizedBox(height: 16),
            Text(
              '选择 ${vaccine.name} 的剂次',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(vaccine.totalDoses, (index) {
                  final doseNumber = index + 1;
                  final isSelected = doseNumber == widget.selectedDoseNumber;
                  return GestureDetector(
                    onTap: () {
                      widget.onSelected(vaccine, doseNumber);
                      Navigator.pop(context); // 关闭剂次选择
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF26A69A)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF26A69A)
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '第$doseNumber',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                          Text(
                            '剂',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white.withAlpha(204)
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            // 取消按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '取消',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
