import '../chart_type.dart';
import 'chart_data_strategy.dart';

/// 辅食数据策略实现
/// 策略模式的具体策略类
class SolidFoodChartDataStrategy extends ChartDataStrategy<SolidFoodChartData> {
  @override
  String get title => '辅食统计';

  @override
  ChartType get type => ChartType.solidFood;

  @override
  SolidFoodChartData getChartData(List<dynamic> records, TimeRange range) {
    // 筛选时间范围内的记录
    final filteredRecords = filterByTimeRange(records, range);

    // 统计各质地类型次数
    final Map<String, int> textureCounts = {};
    for (var record in filteredRecords) {
      final solidFood = record as SolidFoodRecord;
      final texture = solidFood.texture;
      textureCounts[texture] = (textureCounts[texture] ?? 0) + 1;
    }

    // 找出使用最多的质地
    String mostUsedTexture = 'puree';
    int maxCount = 0;
    textureCounts.forEach((texture, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsedTexture = texture;
      }
    });

    return SolidFoodChartData(
      textureCounts: textureCounts,
      totalCount: filteredRecords.length,
      mostUsedTexture: mostUsedTexture,
    );
  }

  /// 获取质地显示名称
  static String getTextureDisplayName(String texture) {
    switch (texture) {
      case 'puree':
        return '泥糊';
      case 'soft':
        return '软烂';
      case 'piece':
        return '小块';
      case 'solid':
        return '固体';
      default:
        return texture;
    }
  }

  /// 获取质地图标
  static String getTextureEmoji(String texture) {
    switch (texture) {
      case 'puree':
        return '🫧';
      case 'soft':
        return '🥣';
      case 'piece':
        return '🍖';
      case 'solid':
        return '🍽️';
      default:
        return '🍽️';
    }
  }
}

/// 简化的辅食记录访问接口
class SolidFoodRecord {
  final DateTime mealTime;
  final String texture;

  SolidFoodRecord({
    required this.mealTime,
    required this.texture,
  });
}
