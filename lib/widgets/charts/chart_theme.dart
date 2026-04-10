import 'package:flutter/material.dart';
import 'chart_type.dart';

/// 图表主题配置类
/// 统一管理所有图表的配色方案和样式
class ChartTheme {
  /// 获取图表类型对应的主题配置
  static ChartThemeConfig getConfig(ChartType type) {
    switch (type) {
      case ChartType.feeding:
        return feedingTheme;
      case ChartType.sleep:
        return sleepTheme;
      case ChartType.diaper:
        return diaperTheme;
      case ChartType.growth:
        return growthTheme;
      case ChartType.solidFood:
        return solidFoodTheme;
    }
  }

  /// 喂养主题 - 粉色系
  static const ChartThemeConfig feedingTheme = ChartThemeConfig(
    type: ChartType.feeding,
    title: '喂养趋势',
    primaryColor: Color(0xFFE91E63),
    lightColor: Color(0xFFF8BBD9),
    gradientColors: [Color(0xFFE91E63), Color(0xFFF8BBD9)],
  );

  /// 睡眠主题 - 蓝色系
  static const ChartThemeConfig sleepTheme = ChartThemeConfig(
    type: ChartType.sleep,
    title: '睡眠趋势',
    primaryColor: Color(0xFF2196F3),
    lightColor: Color(0xFFBBDEFB),
    gradientColors: [Color(0xFF2196F3), Color(0xFFBBDEFB)],
  );

  /// 尿布主题 - 绿色系
  static const ChartThemeConfig diaperTheme = ChartThemeConfig(
    type: ChartType.diaper,
    title: '尿布分布',
    primaryColor: Color(0xFF4CAF50),
    lightColor: Color(0xFFC8E6C9),
    gradientColors: [Color(0xFF4CAF50), Color(0xFFC8E6C9)],
  );

  /// 成长主题 - 紫色系
  static const ChartThemeConfig growthTheme = ChartThemeConfig(
    type: ChartType.growth,
    title: '成长曲线',
    primaryColor: Color(0xFF9C27B0),
    lightColor: Color(0xFFE1BEE7),
    gradientColors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
  );

  /// 辅食主题 - 橙色系
  static const ChartThemeConfig solidFoodTheme = ChartThemeConfig(
    type: ChartType.solidFood,
    title: '辅食统计',
    primaryColor: Color(0xFFFF9800),
    lightColor: Color(0xFFFFE0B2),
    gradientColors: [Color(0xFFFF9800), Color(0xFFFFE0B2)],
  );

  /// 图表容器样式
  static BoxDecoration get containerDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  /// 图表标题样式
  static TextStyle get titleStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      );

  /// 图表副标题样式
  static TextStyle get subtitleStyle => const TextStyle(
        fontSize: 12,
        color: Color(0xFF999999),
      );

  /// 空数据样式
  static Widget get emptyWidget => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              '暂无数据',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
}

/// 图表主题配置数据类
class ChartThemeConfig {
  final ChartType type;
  final String title;
  final Color primaryColor;
  final Color lightColor;
  final List<Color> gradientColors;

  const ChartThemeConfig({
    required this.type,
    required this.title,
    required this.primaryColor,
    required this.lightColor,
    required this.gradientColors,
  });

  /// 创建渐变
  LinearGradient get gradient => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// 创建深色渐变（用于选中状态）
  LinearGradient get darkGradient => LinearGradient(
        colors: [
          primaryColor,
          primaryColor.withAlpha((0.8 * 255).round()),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
