import 'package:flutter/material.dart';

/// 记录空状态组件
///
/// 当列表为空时显示的空状态提示，
/// 包含图标、标题和副标题。
class RecordsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const RecordsEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
