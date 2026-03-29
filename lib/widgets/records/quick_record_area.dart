import 'package:flutter/material.dart';

/// 快速记录区域组件
///
/// 显示多个快速记录按钮的卡片区域，
/// 用于快速添加常用记录（如母乳亲喂、奶粉、尿布类型等）。
class QuickRecordArea extends StatelessWidget {
  final Color primaryColor;
  final List<QuickRecordButton> buttons;

  const QuickRecordArea({
    super.key,
    required this.primaryColor,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(38),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '快速记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons.map((button) => _buildQuickButton(button)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(QuickRecordButton button) {
    return GestureDetector(
      onTap: button.onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: button.color.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(button.icon, size: 28, color: button.color),
          ),
          const SizedBox(height: 8),
          Text(
            button.label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// 快速记录按钮数据模型
///
/// 包含标签、图标、颜色和点击回调，
/// 用于 QuickRecordArea 组件展示多个快速按钮。
class QuickRecordButton {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickRecordButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
