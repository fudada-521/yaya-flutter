import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/solid_food_record.dart';
import '../../providers/records_provider.dart';
import '../../providers/baby_provider.dart';
import '../../services/food_ingredient_service.dart';
import 'components/components.dart';

/// 辅食记录表单包装组件
///
/// 在打开时加载用户自定义食材列表
class SolidFoodRecordSheetWrapper extends StatefulWidget {
  final SolidFoodRecord? recordToEdit;

  const SolidFoodRecordSheetWrapper({
    super.key,
    this.recordToEdit,
  });

  @override
  State<SolidFoodRecordSheetWrapper> createState() => _SolidFoodRecordSheetWrapperState();

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => this,
    );
  }
}

class _SolidFoodRecordSheetWrapperState extends State<SolidFoodRecordSheetWrapper> {
  List<String> _allIngredients = FoodIngredientService.defaultIngredients;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final ingredients = await FoodIngredientService().getIngredients();
    if (mounted) {
      setState(() {
        _allIngredients = ingredients;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _SolidFoodRecordForm(
                  recordToEdit: widget.recordToEdit,
                  allIngredients: _allIngredients,
                ),
        ),
      ),
    );
  }
}

/// 辅食记录表单内部组件
class _SolidFoodRecordForm extends StatefulWidget {
  final SolidFoodRecord? recordToEdit;
  final List<String> allIngredients;

  const _SolidFoodRecordForm({
    this.recordToEdit,
    required this.allIngredients,
  });

  @override
  State<_SolidFoodRecordForm> createState() => _SolidFoodRecordFormState();
}

class _SolidFoodRecordFormState extends State<_SolidFoodRecordForm> {
  late SolidFoodRecordState _state;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      _state = SolidFoodRecordState.fromRecord(widget.recordToEdit!);
    } else {
      _state = SolidFoodRecordState();
    }
    _state.allIngredients = widget.allIngredients;
  }

  Future<void> _handleSave() async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;

    if (currentBaby == null) {
      _showNoBabyPrompt();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.tryParse(_state.amountController.text);

      final record = SolidFoodRecord(
        id: widget.recordToEdit?.id,
        babyId: currentBaby.id,
        mealTime: _state.mealTime,
        foodName: _state.foodNameController.text.isEmpty ? null : _state.foodNameController.text,
        amount: amount,
        texture: _state.texture,
        ingredients: _state.ingredients.isEmpty ? null : _state.ingredients,
        notes: _state.notesController.text.isEmpty ? null : _state.notesController.text,
      );

      final recordsProvider = Provider.of<RecordsProvider>(context, listen: false);
      if (widget.recordToEdit != null) {
        await recordsProvider.updateSolidFoodRecord(record);
      } else {
        await recordsProvider.addSolidFoodRecord(record);
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showNoBabyPrompt() {
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
            SheetActionButtons(
              onCancel: () => Navigator.pop(context),
              onSave: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetHandle(),
        const SizedBox(height: 20),
        SheetHeader(
          title: widget.recordToEdit != null ? '编辑辅食记录' : '添加辅食记录',
          subtitle: '记录宝宝辅食喂养情况',
          primaryColor: const Color(0xFFBA68C8),
        ),
        const SizedBox(height: 24),
        SheetDatePicker(
          label: '用餐时间',
          selectedDateTime: _state.mealTime,
          onChanged: (dt) => setState(() => _state.mealTime = dt),
          primaryColor: const Color(0xFFBA68C8),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SheetTextField(
                controller: _state.foodNameController,
                label: '食物名称',
                hint: '如：米粉',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: SheetTextField(
                controller: _state.amountController,
                label: '份量',
                hint: 'g',
                suffix: 'g',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TextureSelector(
          selectedValue: _state.texture,
          onChanged: (texture) => setState(() => _state.texture = texture),
        ),
        const SizedBox(height: 16),
        _IngredientSelector(
          selectedIngredients: _state.ingredients,
          allIngredients: _state.allIngredients,
          onChanged: (ingredients) => setState(() => _state.ingredients = ingredients),
          onAddCustom: (ingredient) async {
            await FoodIngredientService().addIngredient(ingredient);
            final allIngredients = await FoodIngredientService().getIngredients();
            setState(() => _state.allIngredients = allIngredients);
          },
          onDelete: (ingredient) async {
            await FoodIngredientService().removeIngredient(ingredient);
            final allIngredients = await FoodIngredientService().getIngredients();
            setState(() {
              _state.allIngredients = allIngredients;
              // 如果被删除的食材在选中列表中，也要移除
              if (_state.ingredients.contains(ingredient)) {
                _state.ingredients = List.from(_state.ingredients)..remove(ingredient);
              }
            });
          },
          onReset: () async {
            await FoodIngredientService().resetToDefault();
            final allIngredients = await FoodIngredientService().getIngredients();
            setState(() {
              _state.allIngredients = allIngredients;
              // 清理已选中列表中不在新列表里的食材
              _state.ingredients = _state.ingredients
                  .where((i) => allIngredients.contains(i))
                  .toList();
            });
          },
        ),
        const SizedBox(height: 16),
        SheetTextField(
          controller: _state.notesController,
          label: '备注',
          hint: '添加备注...',
          maxLines: 1,
        ),
        const SizedBox(height: 24),
        SheetActionButtons(
          onCancel: () => Navigator.pop(context),
          onSave: _handleSave,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// 质地选择器
class _TextureSelector extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const _TextureSelector({
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '质地',
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
          children: SolidFoodRecord.textureOptions.map((option) {
            final isSelected = selectedValue == option['value'];
            const color = Color(0xFFBA68C8);

            return GestureDetector(
              onTap: () => onChanged(option['value']!),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option['icon']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      option['label']!,
                      style: TextStyle(
                        fontSize: 12,
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
}

/// 食材多选器（支持添加、删除、恢复默认）
class _IngredientSelector extends StatefulWidget {
  final List<String> selectedIngredients;
  final List<String> allIngredients;
  final ValueChanged<List<String>> onChanged;
  final Function(String) onAddCustom;
  final Function(String) onDelete;
  final VoidCallback onReset;

  const _IngredientSelector({
    required this.selectedIngredients,
    required this.allIngredients,
    required this.onChanged,
    required this.onAddCustom,
    required this.onDelete,
    required this.onReset,
  });

  @override
  State<_IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<_IngredientSelector> {
  bool _isAddingCustom = false;
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _addCustomIngredient() {
    final text = _customController.text.trim();
    if (text.isNotEmpty) {
      widget.onAddCustom(text);
      _customController.clear();
      setState(() => _isAddingCustom = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '食材（可多选）',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isAddingCustom = !_isAddingCustom),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isAddingCustom ? Icons.close : Icons.add,
                        size: 16,
                        color: const Color(0xFFBA68C8),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _isAddingCustom ? '收起' : '添加',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBA68C8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: widget.onReset,
                  child: const Text(
                    '恢复默认',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isAddingCustom) ...[
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA68C8).withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBA68C8).withAlpha(50)),
                  ),
                  child: TextField(
                    controller: _customController,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '输入自定义食材',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _addCustomIngredient(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addCustomIngredient,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA68C8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '添加',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: widget.allIngredients.map((ingredient) {
            final isSelected = widget.selectedIngredients.contains(ingredient);
            const color = Color(0xFFBA68C8);

            return GestureDetector(
              onTap: () {
                final newList = List<String>.from(widget.selectedIngredients);
                if (isSelected) {
                  newList.remove(ingredient);
                } else {
                  newList.add(ingredient);
                }
                widget.onChanged(newList);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6, right: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(25) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey[200]!,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ingredient,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 2),
                    GestureDetector(
                      onTap: () => widget.onDelete(ingredient),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.grey[400],
                        ),
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
}

/// 辅食记录表单状态
///
/// 存储辅食记录表单的临时数据，
/// 包括用餐时间、食物名称、份量、质地和食材。
class SolidFoodRecordState {
  DateTime mealTime;
  String texture;
  List<String> ingredients;
  List<String> allIngredients;
  final TextEditingController foodNameController;
  final TextEditingController amountController;
  final TextEditingController notesController;

  SolidFoodRecordState({
    DateTime? mealTime,
    this.texture = 'puree',
    List<String>? ingredients,
    List<String>? allIngredients,
  })  : mealTime = mealTime ?? DateTime.now(),
        ingredients = ingredients ?? [],
        allIngredients = allIngredients ?? FoodIngredientService.defaultIngredients,
        foodNameController = TextEditingController(),
        amountController = TextEditingController(),
        notesController = TextEditingController();

  factory SolidFoodRecordState.fromRecord(SolidFoodRecord record) {
    final state = SolidFoodRecordState(
      mealTime: record.mealTime,
      texture: record.texture,
      ingredients: record.ingredients ?? [],
    );
    state.foodNameController.text = record.foodName ?? '';
    state.amountController.text = record.amount?.toString() ?? '';
    state.notesController.text = record.notes ?? '';
    return state;
  }
}
