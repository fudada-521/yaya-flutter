import 'package:flutter/material.dart';

class SheetChipSelector extends StatelessWidget {
  final String label;
  final List<SheetChipOption> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final bool allowDeselect;

  const SheetChipSelector({
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option.value;
            final color = option.color ?? Colors.grey;

            return GestureDetector(
              onTap: () {
                if (allowDeselect && isSelected) {
                  onChanged(null);
                } else {
                  onChanged(option.value);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: option.icon != null ? 12 : 16,
                  vertical: 10,
                ),
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
                    if (option.icon != null) ...[
                      Icon(
                        option.icon,
                        color: isSelected ? color : Colors.grey[400],
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      option.label,
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

class SheetChipOption {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  const SheetChipOption({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });
}
