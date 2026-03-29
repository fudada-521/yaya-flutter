import 'package:flutter/material.dart';

/// 底部表单头部组件
///
/// 显示表单的标题和副标题，
/// 用于底部弹窗中标识当前操作的类型。
class SheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? primaryColor;

  const SheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}
