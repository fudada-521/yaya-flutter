import 'package:flutter/material.dart';

/// 底部表单分段选择器组件
///
/// Row 布局的水平分段选择器，每项等宽。
/// 选中状态有颜色和边框区分，支持图标展示。
class SheetSegmentedSelector extends StatelessWidget {
  final String label;
  final List<SheetSegmentOption> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final bool allowDeselect;

  const SheetSegmentedSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.allowDeselect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.map((option) {
            final isSelected = selectedValue == option.value;
            final color = option.color ?? const Color(0xFFFF8A65);

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (allowDeselect && isSelected) {
                    onChanged(null);
                  } else {
                    onChanged(option.value);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withAlpha(25) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey[200]!,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          color: isSelected ? color : Colors.grey[400],
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Center(
                        child: Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? color : Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
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

/// 分段选项数据模型
///
/// 用于 SheetSegmentedSelector 组件的选项配置，
/// 包含值、标签、图标和颜色。
class SheetSegmentOption {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  const SheetSegmentOption({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });
}
