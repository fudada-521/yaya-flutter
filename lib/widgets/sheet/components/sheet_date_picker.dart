import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 底部表单日期时间选择器组件
///
/// 点击弹出日期选择器（可选时间选择），
/// 显示格式化为"yyyy年MM月dd日 HH:mm"。
class SheetDatePicker extends StatelessWidget {
  final String label;
  final DateTime selectedDateTime;
  final ValueChanged<DateTime> onChanged;
  final Color primaryColor;
  final bool showTime;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const SheetDatePicker({
    super.key,
    required this.label,
    required this.selectedDateTime,
    required this.onChanged,
    this.primaryColor = const Color(0xFFFF8A65),
    this.showTime = true,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFirstDate = firstDate ?? DateTime.now().subtract(const Duration(days: 30));
    final effectiveLastDate = lastDate ?? DateTime.now();

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
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDateTime,
              firstDate: effectiveFirstDate,
              lastDate: effectiveLastDate,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: const Color(0xFF2D2D2D),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date == null) return;

            if (showTime) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(selectedDateTime),
              );
              if (time != null) {
                onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
              }
            } else {
              onChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Text(
                  showTime
                      ? DateFormat('yyyy年MM月dd日 HH:mm').format(selectedDateTime)
                      : DateFormat('yyyy年MM月dd日').format(selectedDateTime),
                  style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
