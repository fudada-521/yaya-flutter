import 'package:flutter/material.dart';

class RecordStatsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<StatItem> stats;

  const RecordStatsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats.map((stat) => _buildStatItem(stat)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(StatItem stat) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: stat.color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            stat.value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: stat.color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stat.label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

class StatItem {
  final String label;
  final String value;
  final Color color;

  const StatItem({
    required this.label,
    required this.value,
    required this.color,
  });
}
