import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 底部表单日期时间选择器组件
///
/// 使用 iOS 滚轮风格一次性选择日期和时间。
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
          onTap: () {
            showCupertinoModalPopup<void>(
              context: context,
              builder: (BuildContext context) {
                DateTime tempDate = selectedDateTime;
                return Container(
                  height: 300,
                  padding: const EdgeInsets.only(top: 6),
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground.resolveFrom(context),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        // 顶部栏
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  '取消',
                                  style: TextStyle(color: CupertinoColors.systemGrey),
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  onChanged(tempDate);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  '完成',
                                  style: TextStyle(color: primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // 滚轮选择器
                        Expanded(
                          child: CupertinoDatePicker(
                            mode: showTime
                                ? CupertinoDatePickerMode.dateAndTime
                                : CupertinoDatePickerMode.date,
                            initialDateTime: selectedDateTime,
                            minimumDate: effectiveFirstDate,
                            maximumDate: effectiveLastDate,
                            use24hFormat: true,
                            onDateTimeChanged: (DateTime newDate) {
                              tempDate = newDate;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
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
