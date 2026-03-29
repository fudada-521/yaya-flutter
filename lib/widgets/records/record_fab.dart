import 'package:flutter/material.dart';

/// 记录悬浮按钮组件
///
/// 渐变色背景的浮动操作按钮，用于打开添加记录页面。
/// 支持 primaryColor 和 secondaryColor 配置渐变效果。
class RecordFab extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback onPressed;

  const RecordFab({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
