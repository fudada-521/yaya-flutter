import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/solid_food_record.dart';
import '../../providers/records_provider.dart';
import '../../providers/baby_provider.dart';
import 'base_record_sheet.dart';
import 'components/components.dart';

/// 辅食记录表单组件（策略模式）
///
/// 支持添加和编辑辅食记录，
/// 包含用餐时间、食物名称、份量、质地、食材等字段。
class SolidFoodRecordSheet extends BaseRecordSheet<SolidFoodRecordState> {
  final SolidFoodRecord? recordToEdit;

  SolidFoodRecordSheet({
    super.key,
    this.recordToEdit,
  }) : super(
          title: recordToEdit != null ? '编辑辅食记录' : '添加辅食记录',
          subtitle: '记录宝宝辅食喂养情况',
          primaryColor: const Color(0xFFBA68C8), // 紫色，与成长记录区分
          initialData: recordToEdit != null
              ? SolidFoodRecordState.fromRecord(recordToEdit)
              : null,
        );

  @override
  SolidFoodRecordState createInitialState() {
    return SolidFoodRecordState();
  }

  @override
  List<Widget> buildForm(BuildContext context, SolidFoodRecordState state, StateSetter setState) {
    return [
      SheetDatePicker(
        label: '用餐时间',
        selectedDateTime: state.mealTime,
        onChanged: (dt) => setState(() => state.mealTime = dt),
        primaryColor: const Color(0xFFBA68C8),
      ),
      const SizedBox(height: 20),
      SheetTextField(
        controller: state.foodNameController,
        label: '食物名称',
        hint: '如：米粉、南瓜泥',
      ),
      const SizedBox(height: 20),
      SheetTextField(
        controller: state.amountController,
        label: '份量',
        hint: '输入份量',
        suffix: 'g',
      ),
      const SizedBox(height: 20),
      _TextureSelector(
        selectedValue: state.texture,
        onChanged: (texture) => setState(() => state.texture = texture),
      ),
      const SizedBox(height: 20),
      _IngredientSelector(
        selectedIngredients: state.ingredients,
        onChanged: (ingredients) => setState(() => state.ingredients = ingredients),
      ),
      const SizedBox(height: 20),
      SheetTextField(
        controller: state.notesController,
        label: '备注',
        hint: '添加备注...',
        maxLines: 2,
      ),
    ];
  }

  @override
  Future<void> saveRecord(BuildContext context, SolidFoodRecordState state) async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final currentBaby = babyProvider.currentBaby;
    if (currentBaby == null) return;

    final amount = double.tryParse(state.amountController.text);

    final record = SolidFoodRecord(
      id: recordToEdit?.id,
      babyId: currentBaby.id,
      mealTime: state.mealTime,
      foodName: state.foodNameController.text.isEmpty ? null : state.foodNameController.text,
      amount: amount,
      texture: state.texture,
      ingredients: state.ingredients.isEmpty ? null : state.ingredients,
      notes: state.notesController.text.isEmpty ? null : state.notesController.text,
    );

    final recordsProvider = Provider.of<RecordsProvider>(context, listen: false);
    if (recordToEdit != null) {
      await recordsProvider.updateSolidFoodRecord(record);
    } else {
      await recordsProvider.addSolidFoodRecord(record);
    }
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
            final color = const Color(0xFFBA68C8);

            return GestureDetector(
              onTap: () => onChanged(option['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(25) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
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
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      option['label']!,
                      style: TextStyle(
                        fontSize: 13,
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

/// 食材多选器
class _IngredientSelector extends StatelessWidget {
  final List<String> selectedIngredients;
  final ValueChanged<List<String>> onChanged;

  const _IngredientSelector({
    required this.selectedIngredients,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '食材（可多选）',
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
          children: SolidFoodRecord.commonIngredients.map((ingredient) {
            final isSelected = selectedIngredients.contains(ingredient);
            final color = const Color(0xFFBA68C8);

            return GestureDetector(
              onTap: () {
                final newList = List<String>.from(selectedIngredients);
                if (isSelected) {
                  newList.remove(ingredient);
                } else {
                  newList.add(ingredient);
                }
                onChanged(newList);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withAlpha(25) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey[200]!,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  ingredient,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? color : Colors.grey[600],
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

/// 辅食记录表单状态
///
/// 存储辅食记录表单的临时数据，
/// 包括用餐时间、食物名称、份量、质地和食材。
class SolidFoodRecordState {
  DateTime mealTime;
  String texture;
  List<String> ingredients;
  final TextEditingController foodNameController;
  final TextEditingController amountController;
  final TextEditingController notesController;

  SolidFoodRecordState({
    DateTime? mealTime,
    this.texture = 'puree',
    List<String>? ingredients,
  })  : mealTime = mealTime ?? DateTime.now(),
        ingredients = ingredients ?? [],
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
