import 'package:flutter/material.dart';

/// 记录分类列表页面
///
/// 显示五大记录类型的分类卡片：
/// 喂养记录、睡眠记录、换尿布记录、成长记录、辅食记录。
/// 点击可跳转到对应的详细记录页面。
class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, // 两列布局
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      padding: const EdgeInsets.all(16),
      childAspectRatio: 1.0, // 调整为更方的卡片
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // 外部滚动时禁用
      children: [
        _buildRecordCategoryCard(
          context,
          icon: Icons.restaurant,
          title: '喂养',
          subtitle: '记录喂奶时间、奶量、方式',
          color: const Color(0xFFFF8A65),
          onTap: () => Navigator.pushNamed(context, '/feeding'),
        ),
        _buildRecordCategoryCard(
          context,
          icon: Icons.bedtime,
          title: '睡眠',
          subtitle: '记录睡眠时间、质量',
          color: const Color(0xFF64B5F6),
          onTap: () => Navigator.pushNamed(context, '/sleep'),
        ),
        _buildRecordCategoryCard(
          context,
          icon: Icons.baby_changing_station,
          title: '换尿布',
          subtitle: '记录更换时间、状态',
          color: const Color(0xFF81C784),
          onTap: () => Navigator.pushNamed(context, '/diaper'),
        ),

        _buildRecordCategoryCard(
          context,
          icon: Icons.icecream,
          title: '辅食',
          subtitle: '记录辅食、食材、质地',
          color: const Color(0xFFFFB74D),
          onTap: () => Navigator.pushNamed(context, '/solid-food'),
        ),
        _buildRecordCategoryCard(
          context,
          icon: Icons.vaccines,
          title: '疫苗接种',
          subtitle: '记录疫苗、接种时间',
          color: const Color(0xFF26A69A),
          onTap: () => Navigator.pushNamed(context, '/vaccine'),
        ),
        _buildRecordCategoryCard(
          context,
          icon: Icons.trending_up,
          title: '成长',
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
