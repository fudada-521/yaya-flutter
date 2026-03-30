import 'package:flutter/material.dart';

/// 记录分类列表页面
///
/// 显示四大记录类型的分类卡片：
/// 喂养记录、睡眠记录、换尿布记录、成长记录。
/// 点击可跳转到对应的详细记录页面。
class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        _buildRecordCategoryCard(
          context,
          icon: Icons.restaurant,
          title: '喂养记录',
          subtitle: '记录喂奶时间、奶量、方式',
          color: const Color(0xFFFF8A65),
          onTap: () => Navigator.pushNamed(context, '/feeding'),
        ),
        const SizedBox(height: 12),
        _buildRecordCategoryCard(
          context,
          icon: Icons.bedtime,
          title: '睡眠记录',
          subtitle: '记录睡眠时间、质量',
          color: const Color(0xFF64B5F6),
          onTap: () => Navigator.pushNamed(context, '/sleep'),
        ),
        const SizedBox(height: 12),
        _buildRecordCategoryCard(
          context,
          icon: Icons.baby_changing_station,
          title: '换尿布记录',
          subtitle: '记录更换时间、状态',
          color: const Color(0xFF81C784),
          onTap: () => Navigator.pushNamed(context, '/diaper'),
        ),
        const SizedBox(height: 12),
        _buildRecordCategoryCard(
          context,
          icon: Icons.trending_up,
          title: '成长记录',
          subtitle: '记录身高、体重、头围',
          color: const Color(0xFFBA68C8),
          onTap: () => Navigator.pushNamed(context, '/growth'),
        ),
      ],
    );
  }

  Widget _buildRecordCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
